# 📚 Max Loyalty — Полный индекс документации

> **Версия:** 1.0.0 | **Обновлено:** Февраль 2026

---

## 🗺️ Сессии детализации

Каждая сессия (S-XX) — полностью детализированный блок системы: архитектурные решения, код, схемы, UI/UX.

| Сессия | Статус | Блок | Решений | Файл |
|--------|--------|------|---------|------|
| S-00 | ✅ | Setup — структура репозитория, технологии, конфиги | — | [S-00-setup.md](sessions/S-00-setup.md) |
| S-01 | ⏳ | Database Schema — Prisma models, индексы, миграции, RLS | 35 | [S-01-db-schema.md](sessions/S-01-db-schema.md) |
| S-02 | ⏳ | Backend API — контроллеры, сервисы, RBAC, guards | 30 | [S-02-backend-api.md](sessions/S-02-backend-api.md) |
| S-03 | ⏳ | POS Integration — iiko C# WPF + R-Keeper C++ DLL | 36 | [S-03-pos-integration.md](sessions/S-03-pos-integration.md) |
| S-04 | ⏳ | Frontend Admin Panel — UI/UX, компоненты, стейт | 31 | [S-04-frontend-admin.md](sessions/S-04-frontend-admin.md) |
| S-05 | ⏳ | Manager Dashboard — права, функционал менеджера | 25 | [S-05-manager-dashboard.md](sessions/S-05-manager-dashboard.md) |
| S-06 | ⏳ | Cashier Interface — PIN-auth, touch UI, POS экран | 25 | [S-06-cashier-interface.md](sessions/S-06-cashier-interface.md) |
| S-07 | ⏳ | Telegram Mini App — бот + веб-приложение гостя | 41 | [S-07-telegram-mini-app.md](sessions/S-07-telegram-mini-app.md) |
| S-08 | ⏳ | Notifications — Telegram/Email/SMS, BullMQ, шаблоны | 36 | [S-08-notifications.md](sessions/S-08-notifications.md) |
| S-09 | ⏳ | Analytics & Reporting — Owner/Admin/Manager отчёты | 21 | [S-09-analytics.md](sessions/S-09-analytics.md) |
| S-10 | ⏳ | Billing & Subscriptions — тарифы, YooKassa, Stripe | 23 | [S-10-billing.md](sessions/S-10-billing.md) |
| S-11 | ⏳ | Testing Strategy — Unit/Integration/E2E/Load | 40 | [S-11-testing.md](sessions/S-11-testing.md) |
| S-12 | ⏳ | Infrastructure & DevOps — Fly.io, Docker, CI/CD | 47 | [S-12-infrastructure.md](sessions/S-12-infrastructure.md) |
| S-13 | ⏳ | Owner Platform Dashboard — MRR/ARR/Churn/Impersonation | 35 | [S-13-owner-dashboard.md](sessions/S-13-owner-dashboard.md) |
| S-14 | ⏳ | API Documentation & Webhooks — OpenAPI, Swagger | 30 | [S-14-api-docs.md](sessions/S-14-api-docs.md) |

**Итого решений: ~450 | Статус: ✅ = готово, 🔄 = в работе, ⏳ = ожидает**

---

## 🏗️ Архитектурные документы

| Документ | Описание |
|----------|----------|
| [OVERVIEW.md](architecture/OVERVIEW.md) | Общая архитектура, принципы, полный tech-stack |
| [AUTH-FLOW.md](architecture/AUTH-FLOW.md) | Auth flow — JWT, refresh, RBAC, permissions |
| [MULTI-TENANCY.md](architecture/MULTI-TENANCY.md) | Multi-tenant решения — RLS, Prisma middleware |
| [LOYALTY-ENGINE.md](architecture/LOYALTY-ENGINE.md) | Движок лояльности — правила, уровни, баллы |
| [BILLING.md](architecture/BILLING.md) | Биллинговая логика — тарифы, платежи, вебхуки |
| [SECURITY.md](architecture/SECURITY.md) | Безопасность — 51 контроль, GDPR, -152, PCI DSS |
| [UI-DESIGN-SYSTEM.md](architecture/UI-DESIGN-SYSTEM.md) | Дизайн-система — тёмная тема, компоненты, токены |

---

## 📐 Финальные архитектурные решения

### Монорепозиторий
- **npm workspaces** — `apps/*` + `packages/*`, единый lock-файл
- **Backend** — NestJS Modular Monolith (не микросервисы на MVP)
- **Frontend** — Next.js 14 App Router, серверные компоненты где возможно

### База данных
- **PostgreSQL** (Neon.tech) — single shared DB, `tenantId` на каждой таблице
- **UUID** — первичные ключи (не auto-increment), безопасность в multi-tenant
- **Soft delete** — `deletedAt DateTime?` на User, GuestCard, Restaurant
- **Immutable history** — BallTransaction никогда не удаляется (hard, только audit)
- **JSONB** — `ruleSnapshot`, `promoConditions`, `rewardConfig`, `posRawPayload`
- **Decimal** — для денег `DECIMAL(10,2)`, Integer для баллов
- **Prisma middleware** (Layer 1) + **PostgreSQL RLS** (Layer 2) — двойная защита tenant-изоляции

### Аутентификация & Авторизация
- **Access token** — JWT, 15 мин, `Authorization: Bearer` header
- **Refresh token** — JWT, 30 дней, `HttpOnly Secure Cookie`
- **RBAC** — роль (базовые права) + мелкозернистые permissions от Admin
- **Rate limiting** — 5 попыток / 15 мин / IP (Redis)
- **Dual-secret JWT** — горячая ротация без downtime

### Система лояльности
- **1 балл = 1 ₽** при списании (базовое правило)
- **UNIFIED** — одна карта на всю сеть ресторанов
- **SEPARATE** — отдельные карты на каждый ресторан
- **Уровни** — Bronze (0₽) → Silver (150K₽) → Gold (400K₽) → Platinum (1M₽)
- **One-way up** — понижение уровня невозможно
- **Lifetime Spent** — пороги уровней по сумме всех покупок за всё время

### Тарифы платформы
- **6 тарифов**: Free (internal Owner), Standard, Medium, Pro, Ultimate, Custom
- **Предоплата**: месяц или год (скидка 20% за год)
- **Лимиты**: `max_restaurants`, `max_guests` — при превышении ограниченный режим
- **Ограниченный режим** при неоплате: данные сохраняются, операции заблокированы

### POS-интеграции
- **iiko Front** — C# WPF плагин, кнопка «МАКСИМУМ» в разделе «ДОПОЛНЕНИЯ»
- **R-Keeper** — C++ DLL, Floating Button 60×60px поверх кассового окна, C# WPF UI
- **Webhook HMAC-SHA256** — подпись + timestamp (replay protection 5 мин)
- **Идемпотентность** — Redis + DB UNIQUE constraint на `posCheckId + tenantId`
- **Forward-only** — исторические транзакции не импортируются; ручной CSV-импорт опционально

### Infrastructure (бесплатный MVP)
- **Backend** — Fly.io: 3 VM (API + Worker + Cron), `fra` Frankfurt, 256MB RAM каждая
- **DB** — Neon.tech PostgreSQL 3GB, `eu-central-1`
- **Redis** — Upstash 10K команд/день
- **Storage** — Cloudflare R2 10GB, unlimited bandwidth
- **Email** — Resend 3K/месяц
- **SMS** — SMS.RU ~1₽/SMS
- **CI/CD** — GitHub Actions 2K мин/месяц
- **Monitoring** — Better Stack (1GB logs + uptime)

---

## 🔢 Статистика проекта

| Метрика | Значение |
|---------|----------|
| Всего решений задокументировано | ~450 |
| Блоков детализации | 14 |
| Таблиц в базе данных | ~42 |
| API эндпоинтов (план) | 80+ |
| Контролей безопасности | 51 |
| GitHub Actions workflows | 5 |
| Сервисов в docker-compose.dev | 5 (PostgreSQL, Redis, MinIO, Mailhog) |
| Поддерживаемых POS-систем | 2 (iiko + R-Keeper) |
| Каналов уведомлений | 3 (Telegram, Email, SMS) |

---

## 🚀 Порядок разработки (рекомендуемый)

```
Phase 1 — Core (MVP)
├── S-01: Database Schema + Migrations
├── S-02: Backend API (Auth + Users + Tenants + Loyalty Engine)
├── S-10: Billing (YooKassa + Subscriptions)
└── S-12: Infrastructure (Fly.io + CI/CD + Secrets)

Phase 2 — Admin & Analytics
├── S-04: Frontend Admin Panel
├── S-09: Analytics (Owner + Admin)
└── S-13: Owner Dashboard (MRR/ARR/Churn)

Phase 3 — POS & Guest
├── S-03: POS Integration (iiko → R-Keeper)
├── S-07: Telegram Mini App
└── S-08: Notifications (Telegram/Email/SMS)

Phase 4 — Extended
├── S-05: Manager Dashboard
├── S-06: Cashier Interface
└── S-14: API Docs & Webhooks (публичный API)

Phase 5 — Quality & Scale
├── S-11: Testing Strategy (Unit/E2E/Load)
└── Security Hardening (51 controls)
```

---

*📌 Для навигации используй ссылки выше. Каждая сессия самодостаточна и независима.*
