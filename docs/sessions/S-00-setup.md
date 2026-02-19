# S-00 — Начальная настройка проекта (Setup)

> **Статус:** ✅ Готово  
> **Дата:** Февраль 2026  
> **Описание:** Структура монорепозитория, конфигурация, инструменты разработки

---

## 1. Что создано в этой сессии

| Файл | Описание |
|------|----------|
| `README.md` | Главная страница проекта — overview, tech stack, структура |
| `docs/INDEX.md` | Полный индекс документации всех 14 сессий |
| `docs/sessions/S-00-setup.md` | Этот файл — документация сессии S-00 |
| `docs/architecture/OVERVIEW.md` | Техническая архитектура системы |
| `.gitignore` | Монорепозиторий + TypeScript + .NET/C++ + Docker |
| `package.json` | Root workspace (npm workspaces) |
| `Makefile` | Developer команды: setup, dev, logs, seed, clean |
| `docker-compose.dev.yml` | 5 сервисов для локальной разработки |
| `apps/*/` | Директории приложений |
| `packages/*/` | Директории общих пакетов |

---

## 2. Структура монорепозитория

```
max.loyalty/
├── apps/
│   ├── backend/                 # NestJS 10 — основной API
│   │   ├── src/
│   │   │   ├── modules/
│   │   │   │   ├── auth/        # JWT, login, register, refresh
│   │   │   │   ├── users/       # User management + RBAC
│   │   │   │   ├── tenants/     # Multi-tenant logic
│   │   │   │   ├── restaurants/ # Restaurant CRUD
│   │   │   │   ├── guests/      # Guest profiles + cards
│   │   │   │   ├── loyalty/     # Rules, levels, transactions
│   │   │   │   ├── promos/      # Promo engine
│   │   │   │   ├── pos-integration/ # iiko + R-Keeper webhooks
│   │   │   │   ├── telegram/    # Bot + Mini App
│   │   │   │   ├── subscriptions/ # Billing + plans
│   │   │   │   ├── notifications/ # Email/SMS/Telegram
│   │   │   │   ├── analytics/   # Reports + dashboards
│   │   │   │   └── activity-log/ # Audit trail
│   │   │   ├── common/          # Guards, decorators, interceptors
│   │   │   ├── database/        # PrismaService
│   │   │   ├── redis/           # RedisService
│   │   │   ├── storage/         # S3Service (Cloudflare R2)
│   │   │   ├── health/          # Health checks
│   │   │   ├── config/          # Zod config validation
│   │   │   └── main.ts          # Bootstrap (api/worker/cron по PROCESS_TYPE)
│   │   ├── Dockerfile           # Multi-stage build
│   │   ├── fly.toml             # Fly.io deployment
│   │   └── package.json
│   │
│   ├── frontend/                # Next.js 14 App Router
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── (owner)/     # Owner Platform Dashboard
│   │   │   │   ├── (admin)/     # Admin Dashboard
│   │   │   │   ├── (manager)/   # Manager Dashboard
│   │   │   │   ├── (cashier)/   # Cashier Touch UI
│   │   │   │   └── (auth)/      # Login, Register
│   │   │   ├── components/      # shadcn/ui + кастомные компоненты
│   │   │   ├── hooks/           # useTanStackQuery hooks
│   │   │   ├── stores/          # Zustand stores
│   │   │   ├── lib/             # api client, utils
│   │   │   └── types/           # TypeScript типы
│   │   ├── Dockerfile
│   │   └── package.json
│   │
│   ├── telegram-bot/            # Telegram Bot + Mini App
│   │   ├── src/
│   │   │   ├── bot/             # grammY bot handlers
│   │   │   │   ├── scenes/      # Onboarding, menu, support
│   │   │   │   ├── keyboards/   # Inline keyboards
│   │   │   │   └── index.ts
│   │   │   ├── mini-app/        # React + Vite Mini App
│   │   │   │   ├── pages/       # Card, History, Profile, Promos
│   │   │   │   └── components/
│   │   │   └── main.ts
│   │   └── package.json
│   │
│   ├── iiko-plugin/             # C# .NET 4.7.2 WPF плагин iiko
│   │   ├── MaxLoyalty.iiko/
│   │   │   ├── Plugin.cs        # Точка входа IFrontPlugin
│   │   │   ├── Services/        # API client, Guest identification
│   │   │   ├── ViewModels/      # MVVM ViewModels
│   │   │   ├── Views/           # WPF XAML Windows
│   │   │   └── Config/          # config.json, шифрование
│   │   └── MaxLoyalty.iiko.sln
│   │
│   └── rkeeper-plugin/          # C++ DLL + C# WPF UI R-Keeper
│       ├── MaxLoyaltyRKeeper/   # C++ DLL
│       │   ├── MaxLoyaltyRKeeper.cpp
│       │   ├── MaxLoyaltyRKeeper.h   # Public API: Initialize, GetCardInfo, etc.
│       │   ├── HttpClient/
│       │   ├── SharedMemory/
│       │   └── OfflineQueue/
│       ├── MaxLoyaltyRKeeperUI/ # C# WPF Floating Button UI
│       │   ├── App.xaml.cs
│       │   ├── FloatingButtonWindow.xaml
│       │   ├── GuestSearchWindow.xaml
│       │   └── PointsOperationWindow.xaml
│       └── MaxLoyaltyRKeeper.sln
│
├── packages/
│   ├── shared/                  # Общие типы и утилиты
│   │   ├── src/
│   │   │   ├── types/           # Shared TypeScript типы
│   │   │   ├── constants/       # APP_CONSTANTS, LOYALTY_DEFAULTS
│   │   │   ├── utils/           # formatCurrency, maskPhone, etc.
│   │   │   └── index.ts
│   │   └── package.json
│   │
│   └── database/                # Prisma schema + migrations
│       ├── prisma/
│       │   ├── schema.prisma    # Полная схема ~42 модели
│       │   ├── migrations/      # История миграций
│       │   └── seed.ts          # Seed данные для разработки
│       └── package.json
│
├── scripts/
│   ├── rotate-secrets.sh        # Ротация JWT секретов
│   ├── backup-db.sh             # Ручной дамп PostgreSQL → S3
│   └── init-db.sql              # Начальная инициализация БД
│
├── .github/
│   └── workflows/
│       ├── test.yml             # PR: lint + type-check + tests
│       ├── deploy-backend.yml   # Push main → Fly.io deploy
│       ├── deploy-frontend.yml  # Push main → Vercel deploy
│       ├── deploy-bot.yml       # Push main → Bot deploy
│       └── cron-backup.yml      # Еженедельный backup DB
│
├── docker-compose.dev.yml       # PostgreSQL, Redis, MinIO, Mailhog
├── Makefile                     # make setup | dev | logs | seed
├── package.json                 # Root npm workspaces
├── .gitignore
└── README.md
```

---

## 3. Root package.json (npm workspaces)

```json
{
  "name": "max-loyalty",
  "version": "1.0.0",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "engines": {
    "node": ">=20.0.0",
    "npm": ">=10.0.0"
  },
  "scripts": {
    "dev": "docker-compose -f docker-compose.dev.yml up",
    "dev:backend": "cd apps/backend && npm run start:dev",
    "dev:frontend": "cd apps/frontend && npm run dev",
    "build": "npm run build --workspaces --if-present",
    "test": "npm run test --workspaces --if-present",
    "lint": "npm run lint --workspaces --if-present",
    "type-check": "npm run type-check --workspaces --if-present",
    "db:generate": "cd packages/database && npx prisma generate",
    "db:migrate": "cd packages/database && npx prisma migrate dev",
    "db:migrate:deploy": "cd packages/database && npx prisma migrate deploy",
    "db:seed": "cd packages/database && npx ts-node prisma/seed.ts",
    "db:studio": "cd packages/database && npx prisma studio"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0"
  }
}
```

---

## 4. docker-compose.dev.yml

```yaml
version: '3.8'

services:
  # PostgreSQL — основная база данных
  postgres:
    image: postgres:16-alpine
    container_name: max-loyalty-postgres
    restart: unless-stopped
    ports:
      - '5432:5432'
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: maxloyalty_dev
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U postgres']
      interval: 5s
      timeout: 5s
      retries: 5

  # Redis — кэш, очереди BullMQ, сессии
  redis:
    image: redis:7-alpine
    container_name: max-loyalty-redis
    restart: unless-stopped
    ports:
      - '6379:6379'
    volumes:
      - redis_data:/data
    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
      interval: 5s
      timeout: 3s
      retries: 5

  # MinIO — локальный S3 (замена Cloudflare R2 в dev)
  minio:
    image: minio/minio:latest
    container_name: max-loyalty-minio
    command: server /data --console-address ':9001'
    ports:
      - '9000:9000'  # S3 API
      - '9001:9001'  # Web Console
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio_data:/data
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:9000/minio/health/live']
      interval: 10s
      timeout: 5s
      retries: 5

  # Mailhog — перехват email в dev (не отправляет реальные письма)
  mailhog:
    image: mailhog/mailhog:latest
    container_name: max-loyalty-mailhog
    ports:
      - '1025:1025'  # SMTP
      - '8025:8025'  # Web UI
    logging:
      driver: none   # Отключаем логи, слишком verbose

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

**Доступ в браузере:**
- MinIO Console: http://localhost:9001 (login: minioadmin / minioadmin)
- Mailhog UI: http://localhost:8025

---

## 5. Makefile

```makefile
.PHONY: help setup dev dev-bg stop logs logs-backend seed reset-db clean shell-postgres shell-redis

help: ## Показать все команды
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Первоначальная настройка (один раз)
	@echo "🚀 Setting up Max Loyalty development environment..."
	cp -n .env.example .env.local 2>/dev/null || true
	docker-compose -f docker-compose.dev.yml up -d postgres redis minio mailhog
	@echo "⏳ Waiting for databases..."
	sleep 5
	npm install
	npm run db:generate
	npm run db:migrate
	$(MAKE) seed
	@echo ""
	@echo "✅ Setup complete! Run: make dev"

dev: ## Запустить все сервисы (foreground)
	docker-compose -f docker-compose.dev.yml up

dev-bg: ## Запустить все сервисы в фоне
	docker-compose -f docker-compose.dev.yml up -d
	@echo "✅ Services started:"
	@echo "  Frontend:  http://localhost:3001"
	@echo "  Backend:   http://localhost:3000"
	@echo "  Mailhog:   http://localhost:8025"
	@echo "  MinIO:     http://localhost:9001"

stop: ## Остановить все сервисы
	docker-compose -f docker-compose.dev.yml down

logs: ## Логи всех сервисов
	docker-compose -f docker-compose.dev.yml logs -f

logs-backend: ## Логи только backend
	docker-compose -f docker-compose.dev.yml logs -f backend

seed: ## Заполнить БД тестовыми данными
	@echo "🌱 Seeding database..."
	npm run db:seed
	@echo "✅ Database seeded"

reset-db: ## Сбросить БД (УДАЛЯЕТ ВСЕ ДАННЫЕ!)
	@echo "⚠️  Resetting database..."
	cd packages/database && npx prisma migrate reset --force
	$(MAKE) seed
	@echo "✅ Database reset complete"

clean: ## Полная очистка (volumes, node_modules, dist)
	docker-compose -f docker-compose.dev.yml down -v
	rm -rf apps/*/node_modules apps/*/dist
	rm -rf packages/*/node_modules
	rm -rf node_modules
	@echo "✅ Cleaned"

shell-postgres: ## Открыть psql
	docker-compose -f docker-compose.dev.yml exec postgres \
		psql -U postgres -d maxloyalty_dev

shell-redis: ## Открыть Redis CLI
	docker-compose -f docker-compose.dev.yml exec redis redis-cli

db-studio: ## Открыть Prisma Studio
	npm run db:studio
```

---

## 6. .gitignore

```gitignore
# Dependencies
node_modules/
.npm/

# Build outputs
dist/
.next/
.vercel/
build/
out/

# Environment
.env
.env.local
.env.*.local
!.env.example

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.suo
*.user

# TypeScript
*.tsbuildinfo

# Coverage
coverage/
.nyc_output/

# Testing
.playwright/
playwright-report/
test-results/

# Docker
.docker/

# C# / .NET
*.user
*.suo
[Oo]bj/
[Bb]in/
*.nupkg
*.snupkg
.vs/
*.DotSettings.user

# C++
*.obj
*.pdb
Debug/
Release/
x64/
x86/
ipch/
*.aps

# Uploads / temp
uploads/
tmp/
*.sql.gz

# Prisma
*.db
*.db-journal
```

---

## 7. .env.example

```dotenv
# === APPLICATION ===
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000
FRONTEND_URL=http://localhost:3001

# === DATABASE ===
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/maxloyalty_dev
DIRECT_DATABASE_URL=postgresql://postgres:postgres@localhost:5432/maxloyalty_dev

# === REDIS ===
REDIS_URL=redis://localhost:6379

# === JWT ===
JWT_SECRET=dev-secret-change-in-production-min-32-chars
JWT_REFRESH_SECRET=dev-refresh-secret-change-in-production-min-32
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=30d

# === S3 / STORAGE ===
S3_ENDPOINT=http://localhost:9000
S3_BUCKET=loyalty-dev
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_REGION=us-east-1

# === EMAIL (Resend) ===
RESEND_API_KEY=re_dev_placeholder
EMAIL_FROM=noreply@maxloyalty.local

# === SMS (SMS.RU) ===
SMSRU_API_KEY=smsru_dev_placeholder
SMSRU_SENDER=MAX-LOYALTY

# === TELEGRAM BOT ===
TELEGRAM_BOT_TOKEN=bot_dev_placeholder
TELEGRAM_MINI_APP_URL=http://localhost:5173

# === PAYMENTS ===
YOOKASSA_SHOP_ID=
YOOKASSA_SECRET_KEY=

# === MONITORING ===
BETTER_STACK_TOKEN=
SENTRY_DSN=

# === SMTP (Mailhog dev) ===
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASS=
```

---

## 8. GitHub Actions Workflows (структура)

### `.github/workflows/test.yml`
Запускается на каждый PR и push в `develop`/`main`:
- Lint (ESLint)
- Type-check (tsc)
- Unit tests
- Integration tests (c реальной PostgreSQL через service containers)
- Upload coverage → Codecov

### `.github/workflows/deploy-backend.yml`
Запускается при push в `main` с изменениями в `apps/backend/**`:
- Деплой на Fly.io через `flyctl deploy --remote-only`
- Release command: `npx prisma migrate deploy`
- Уведомление в Telegram/Discord

### `.github/workflows/deploy-frontend.yml`
Запускается при push в `main` с изменениями в `apps/frontend/**`:
- Деплой на Vercel через `amondnet/vercel-action`
- Preview deployments для PRs

### `.github/workflows/deploy-bot.yml`
Запускается при push в `main` с изменениями в `apps/telegram-bot/**`:
- Деплой на Fly.io (отдельный app `max-loyalty-bot`)

### `.github/workflows/cron-backup.yml`
Еженедельно (по воскресеньям в 3:00 UTC):
- `pg_dump` → gzip → загрузка в Cloudflare R2
- Очистка бэкапов старше 30 дней

---

## 9. Fly.io конфигурация (`apps/backend/fly.toml`)

```toml
app = "max-loyalty-prod"
primary_region = "fra"  # Frankfurt — ближайший к RU

[build]
  dockerfile = "Dockerfile"

[env]
  NODE_ENV = "production"
  PORT = "3000"

# 3 типа процессов из одного образа
[processes]
  api    = "node dist/main.js"
  worker = "node dist/main.js"
  cron   = "node dist/main.js"

[processes.env]
  api.PROCESS_TYPE    = "api"
  worker.PROCESS_TYPE = "worker"
  cron.PROCESS_TYPE   = "cron"

# HTTP сервис только для API процесса
[[services]]
  processes   = ["api"]
  internal_port = 3000
  protocol    = "tcp"

  [[services.ports]]
    port     = 80
    handlers = ["http"]
    force_https = true

  [[services.ports]]
    port     = 443
    handlers = ["tls", "http"]

  [services.concurrency]
    type       = "connections"
    hard_limit = 250
    soft_limit = 200

  [[services.http_checks]]
    interval   = "30s"
    timeout    = "5s"
    grace_period = "10s"
    method     = "get"
    path       = "/health/ready"

# Запуск миграций перед деплоем
[deploy]
  release_command = "sh -c 'npx prisma migrate deploy && npx prisma generate'"
  strategy = "rolling"

# VM настройки (free tier)
[[vm]]
  processes  = ["api"]
  memory     = "256mb"
  cpu_kind   = "shared"
  cpus       = 1

[[vm]]
  processes  = ["worker"]
  memory     = "256mb"
  cpu_kind   = "shared"
  cpus       = 1

[[vm]]
  processes  = ["cron"]
  memory     = "256mb"
  cpu_kind   = "shared"
  cpus       = 1
```

---

## 10. Следующий шаг

**→ [S-01: Database Schema](S-01-db-schema.md)** — Prisma schema со всеми ~42 моделями, индексами, RLS политиками и seed данными.

---

*[← Назад к INDEX](../INDEX.md)*
