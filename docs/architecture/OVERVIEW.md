# Архитектура Max Loyalty — Технический обзор

---

## Принципы архитектуры

1. **Monorepo** — единый репозиторий, npm workspaces, единый lock-файл
2. **Modular Monolith** — NestJS с чётко выделенными модулями (не микросервисы на MVP)
3. **Multi-tenancy** — Shared DB + `tenantId` на каждой таблице
4. **Defense in depth** — Prisma middleware (Layer 1) + PostgreSQL RLS (Layer 2)
5. **Offline-first POS** — плагины работают без сети, синхронизируются при восстановлении
6. **Event-driven notifications** — BullMQ очереди, не синхронные HTTP вызовы
7. **Free-first infrastructure** — MVP полностью на бесплатных тирах

---

## Компоненты системы

```
┌─────────────────────────────────────────────────────────────────────┐
│                           CLIENTS                                   │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────┐  │
│  │ Owner Browser│  │Admin Browser │  │Telegram App  │  │POS     │  │
│  │ (Next.js 14) │  │(Next.js 14)  │  │(Mini App)    │  │Plugin  │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └───┬────┘  │
└─────────┼─────────────────┼─────────────────┼──────────────┼───────┘
          │                 │                 │              │
          └─────────────────┴────────┬────────┴──────────────┘
                                     │ HTTPS/WSS
                 ┌───────────────────▼──────────────────────────┐
                 │           BACKEND API (Fly.io fra)            │
                 │                                              │
                 │     NestJS 10 — Modular Monolith             │
                 │  ┌──────────┐ ┌──────────┐ ┌─────────────┐  │
                 │  │ REST API │ │ Webhooks │ │ SSE Stream  │  │
                 │  │  v1      │ │ (HMAC)   │ │ (Analytics) │  │
                 │  └────┬─────┘ └────┬─────┘ └──────┬──────┘  │
                 │       └────────────┴───────────────┘         │
                 │                    │                          │
                 │         ┌──────────▼──────────┐              │
                 │         │  BullMQ Workers      │              │
                 │         │  (Notifications,     │              │
                 │         │   POS sync, Analytics│              │
                 │         │   Cron jobs)         │              │
                 │         └─────────────────────┘              │
                 └──────────────────┬───────────────────────────┘
                                    │
             ┌──────────────────────┼────────────────────────┐
             │                      │                        │
  ┌──────────▼───────┐  ┌──────────▼───────┐  ┌────────────▼──────┐
  │   PostgreSQL      │  │   Redis           │  │  Cloudflare R2    │
  │   (Neon.tech)     │  │   (Upstash)       │  │  (S3 Storage)     │
  │   eu-central-1    │  │   10K cmd/day     │  │  10GB free        │
  └───────────────────┘  └──────────────────┘  └───────────────────┘
```

---

## Слои Backend (NestJS)

```
HTTP Request
    │
    ▼
┌─────────────────────────────┐
│  Guards (JwtAuthGuard,      │  ← Проверка токена, RBAC
│  RolesGuard, TenantGuard)   │
└──────────────┬──────────────┘
               │
    ▼
┌─────────────────────────────┐
│  Interceptors               │  ← Logging, Transform, Cache
│  (MetricsInterceptor,       │
│   VersionInterceptor)       │
└──────────────┬──────────────┘
               │
    ▼
┌─────────────────────────────┐
│  Pipes                      │  ← Validation (class-validator)
│  (ValidationPipe,           │
│   ParseUUIDPipe)            │
└──────────────┬──────────────┘
               │
    ▼
┌─────────────────────────────┐
│  Controller                 │  ← Route handlers
└──────────────┬──────────────┘
               │
    ▼
┌─────────────────────────────┐
│  Service                    │  ← Business Logic
└──────────────┬──────────────┘
               │
    ▼
┌─────────────────────────────┐
│  PrismaService + Redis      │  ← Data Access
│  (+ Prisma middleware RLS)  │
└─────────────────────────────┘
```

---

## Multi-tenancy схема

```typescript
// prisma.middleware.ts — Layer 1: Prisma middleware
prisma.$use(async (params, next) => {
  const tenantId = AsyncLocalStorage.getStore()?.tenantId;
  if (!tenantId) return next(params);

  // Автоматически добавляем tenantId к каждому запросу
  if (params.action === 'findMany' || params.action === 'findFirst') {
    params.args.where = { ...params.args.where, tenantId };
  }
  if (params.action === 'create') {
    params.args.data = { ...params.args.data, tenantId };
  }
  return next(params);
});
```

```sql
-- Layer 2: PostgreSQL RLS
ALTER TABLE "GuestCard" ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON "GuestCard"
  USING ("tenantId" = current_setting('app.tenant_id')::uuid);
```

---

## Loyalty Engine логика

```
POS Webhook (JSON + HMAC)
         │
         ▼
  Идемпотентность ──► Redis SET NX (posCheckId)
         │               └─► DB UNIQUE (posCheckId, tenantId)
         ▼
  Идентификация гостя
         │
         ├─► по телефону (приоритет)
         ├─► по posGuestId
         └─► Авто-создание (если не найден)
         │
         ▼
  Расчёт баллов
         │
         ├─► Получить правила (Redis cache, TTL 5 мин)
         ├─► Применить категории (blacklist check)
         ├─► Применить уровневые бонусы
         └─► Применить активные промо-акции
         │
         ▼
  Транзакция (Prisma transaction)
         │
         ├─► BallTransaction.create (earn/redeem)
         ├─► GuestCard.balance += earned
         ├─► GuestCard.lifetimeSpent += checkAmount
         ├─► POSTransaction.create (raw data)
         └─► Level upgrade check (GuestCard.loyaltyLevelId)
         │
         ▼
  BullMQ Queue → Notification
         │
         ├─► Telegram: «Начислено 285 баллов! Баланс: 3,185»
         ├─► Email (если подписан)
         └─► SMS (если нет Telegram)
```

---

## Процессы Fly.io (3 VM, 1 образ)

```typescript
// apps/backend/src/main.ts
async function bootstrap() {
  const processType = process.env.PROCESS_TYPE ?? 'api';

  if (processType === 'api') {
    // HTTP сервер — REST API, Webhooks, SSE
    const app = await NestFactory.create(AppModule);
    await app.listen(3000);

  } else if (processType === 'worker') {
    // BullMQ Processor — Email/SMS/Telegram отправка,
    //                    POS sync, analytics aggregation
    const app = await NestFactory.createApplicationContext(WorkerModule);

  } else if (processType === 'cron') {
    // Cron Jobs — начисление баллов за день рождения,
    //             пересчёт уровней, очистка истёкших сессий,
    //             прогрев кэша, автоматические бэкапы
    const app = await NestFactory.createApplicationContext(CronModule);
  }
}
```

---

## Auth Flow

```
POST /auth/login
  │
  ├─► Validate credentials (bcrypt)
  ├─► Check rate limit (5 attempts / 15 min / IP)
  ├─► Generate Access Token (JWT, 15m, payload: userId, tenantId, role, permissions)
  ├─► Generate Refresh Token (JWT, 30d) → save hash in UserSession
  ├─► Set Refresh Token in HttpOnly Secure Cookie
  └─► Return Access Token in response body

POST /auth/refresh
  │
  ├─► Read Refresh Token from Cookie
  ├─► Verify JWT signature (dual-secret: current + previous)
  ├─► Validate hash in UserSession (не отозван)
  ├─► Rotate: generate new Refresh Token, invalidate old
  └─► Return new Access Token

Protected request
  │
  ├─► JwtAuthGuard: verify Access Token
  ├─► TenantGuard: inject tenantId в Prisma context
  ├─► RolesGuard: проверить role
  ├─► PermissionsGuard: проверить fine-grained permissions
  └─► Controller handler
```

---

## Уровни лояльности (дефолт, настраивается Admin)

| Уровень | Порог (Lifetime Spent) | Бонус к начислению |
|---------|------------------------|--------------------|
| Bronze  | 0 ₽ | базовый % |
| Silver  | 150,000 ₽ | +2% |
| Gold    | 400,000 ₽ | +5% |
| Platinum | 1,000,000 ₽ | +10% |

**One-way up**: понижение уровня невозможно (даже при ручной корректировке Admin).

---

## Безопасность (краткий обзор)

| Категория | Реализация |
|-----------|------------|
| Auth | JWT dual-secret, HttpOnly cookie, refresh rotation |
| RBAC | Role + fine-grained permissions, guard chain |
| Multi-tenant | Prisma middleware + PostgreSQL RLS |
| API Keys | AES-256 шифрование, Machine-ID binding (R-Keeper) |
| POS Webhooks | HMAC-SHA256 + timestamp replay protection (5 мин) |
| Rate limiting | Redis, 5/15min login; 100/min API |
| Input validation | class-validator DTOs, Zod config |
| Secrets | Fly.io encrypted secrets, Dual-secret JWT rotation |
| GDPR/152-ФЗ | Right to erasure, data export, consent logging |
| Logging | Structured JSON, no sensitive data (masked phone/email) |

*Полный список 51 контроля — в [SECURITY.md](SECURITY.md)*

---

*[← Назад к INDEX](../INDEX.md)*
