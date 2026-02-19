# 📚 MAX-LOYALTY — Документация платформы

> **MAX-LOYALTY** — Multi-tenant SaaS платформа системы лояльности для ресторанов.
> Поддерживает iiko, R-Keeper, Telegram Bot + Mini App, накопительную и скидочную систему баллов.

---

## 🗂️ Навигация по документации

### 📋 Главные документы

| Файл | Описание | Размер |
|------|----------|--------|
| [00_FULL_SYSTEM_DESCRIPTION.md](./00_FULL_SYSTEM_DESCRIPTION.md) | **Полное описание всей системы** — каждая деталь, бизнес-логика, примеры, edge-cases от начала до конца | ~600кб |
| [DEVELOPMENT_ROADMAP.md](./DEVELOPMENT_ROADMAP.md) | **Путь разработки** — фазы, задачи, зависимости, timeline, milestones, definition of done | ~450кб |
| [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md) | **Полная структура проекта** — каждый файл и папка Backend/Frontend/Plugins/DevOps с описанием | ~400кб |
| [PROJECT_ARCHITECTURE.md](./PROJECT_ARCHITECTURE.md) | **Полная архитектура** — C4-модель, слои, модули, потоки данных, паттерны | ~450кб |

---

### 🔷 Блоки системы (детальная документация)

| # | Файл | Блок | Ключевые темы |
|---|------|------|---------------|
| 01 | [blocks/01_ARCHITECTURE_RBAC.md](./blocks/01_ARCHITECTURE_RBAC.md) | **Архитектура + RBAC** | Multi-tenant, роли, permissions, impersonation, ActivityLog |
| 02 | [blocks/02_GUESTS_CARDS.md](./blocks/02_GUESTS_CARDS.md) | **Гости и карты** | Регистрация (3 способа), GuestCard, UNIFIED/SEPARATE, миграции, merge |
| 03 | [blocks/03_LOYALTY_ENGINE_RULES.md](./blocks/03_LOYALTY_ENGINE_RULES.md) | **Loyalty Engine: Правила** | Баллы, версионирование, атомарность, инварианты, RecalculationJob |
| 04 | [blocks/04_LOYALTY_ENGINE_PROMO.md](./blocks/04_LOYALTY_ENGINE_PROMO.md) | **Промо-конструктор** | ДР гостя/ребёнка, первый чек, конфликты промо, PromoBallGranted |
| 05 | [blocks/05_LOYALTY_LEVELS.md](./blocks/05_LOYALTY_LEVELS.md) | **Уровни лояльности** | lifetime_spent, one-way-up, CRON пересчёт, версионирование уровней |
| 06 | [blocks/06_POS_INTEGRATION.md](./blocks/06_POS_INTEGRATION.md) | **POS-интеграция** | HYBRID PUSH+PULL, HMAC, idempotency, reconciliation, sandbox |
| 07 | [blocks/07_POS_PLUGINS.md](./blocks/07_POS_PLUGINS.md) | **POS-плагины (iiko + R-Keeper)** | C#/WPF, FarCard, Shared Memory, offline-очередь, installer |
| 08 | [blocks/08_BILLING_SUBSCRIPTIONS.md](./blocks/08_BILLING_SUBSCRIPTIONS.md) | **Биллинг и подписки** | 6 тарифов, 4 провайдера, retry, refund/chargeback, trial |
| 09 | [blocks/09_TELEGRAM_BOT_MINIAPP.md](./blocks/09_TELEGRAM_BOT_MINIAPP.md) | **Telegram Bot + Mini App** | Команды, регистрация, все экраны, мультикарточность, дизайн |
| 10 | [blocks/10_BACKEND_API.md](./blocks/10_BACKEND_API.md) | **Backend API** | Все endpoints, Request/Response, middleware, error catalog |
| 11 | [blocks/11_DATABASE_SCHEMA.md](./blocks/11_DATABASE_SCHEMA.md) | **Database Schema** | Полная Prisma-схема 45+ таблиц, индексы, связи, enums |
| 12 | [blocks/12_FRONTEND_ADMIN.md](./blocks/12_FRONTEND_ADMIN.md) | **Frontend Admin Panel** | Next.js 14, shadcn/ui, все экраны, mobile UX, состояния |
| 13 | [blocks/13_SECURITY_AUTH.md](./blocks/13_SECURITY_AUTH.md) | **Security + Auth** | JWT RS256, MFA, argon2id, step-up auth, audit trail |
| 14 | [blocks/14_INFRASTRUCTURE.md](./blocks/14_INFRASTRUCTURE.md) | **Infrastructure** | Fly.io, Vercel, Neon, Redis, CI/CD, мониторинг, backup |
| 15 | [blocks/15_API_DOCS_SDK.md](./blocks/15_API_DOCS_SDK.md) | **API Docs + SDK** | OpenAPI, TypeScript SDK, Sandbox, Postman, Changelog |

---

## 🏗️ Архитектура в одном взгляде

```
┌─────────────────────────────────────────────────────────────────┐
│                        MAX-LOYALTY PLATFORM                     │
├─────────────┬──────────────────────┬───────────────────────────┤
│  FRONTEND   │     BACKEND API      │      INTEGRATIONS         │
│             │                      │                           │
│ Next.js 14  │   NestJS (Modular    │  iiko Plugin (C#/WPF)    │
│ shadcn/ui   │   Monolith)          │  R-Keeper Plugin          │
│ TanStack    │   + BullMQ Worker    │  (C++/WPF + FarCard)     │
│ Recharts    │   + CRON Jobs        │                           │
│             │                      │  Telegram Bot             │
├─────────────┴──────────────────────┤  + Mini App (TWA)         │
│           DATABASES                │                           │
│  PostgreSQL (Neon) + Redis         │  SMS: SMSC.ru / Twilio   │
│  (Upstash) + Cloudflare R2         │  Email: Resend            │
└────────────────────────────────────┴───────────────────────────┘
```

---

## ⚡ Ключевые бизнес-правила (запечатаны)

| Правило | Значение |
|---------|----------|
| Курс баллов | **1 балл = 1 рубль** (глобально, нельзя менять) |
| База начисления | Всегда от **исходной суммы чека** (до вычета баллов) |
| Порядок списания | Сначала **promo_balance**, затем **regular_balance** |
| Максимум баллов | **Безлимит** на карте |
| Минимум списания | **1 балл** |
| Максимум списания | **20%** от суммы чека (настраиваемый, диапазон 10–100%) |
| Минимум чека | **50 рублей** (фиксированный) |
| Уровни | **One-way up** — никогда не понижаются автоматически |
| Сгорание | По неактивности **≥90 дней** — все баллы карты |
| Тарифы | 6 штук: Free, Standard, Medium, Pro, Ultimate, Custom |

---

## 👥 Роли платформы

```
Owner (владелец платформы)
  └── Restaurant Admin (владелец ресторана/сети)
        ├── Manager (управляет рестораном)
        │     └── Cashier (работает на кассе)
        └── Guest (клиент ресторана — в Telegram/Web)
```

---

## 🔗 Быстрые ссылки

- 🌐 **Репозиторий**: https://github.com/Romslav/max.loyalty
- 📊 **Полная система**: [00_FULL_SYSTEM_DESCRIPTION.md](./00_FULL_SYSTEM_DESCRIPTION.md)
- 🛠️ **С чего начать разработку**: [DEVELOPMENT_ROADMAP.md](./DEVELOPMENT_ROADMAP.md)
- 🗄️ **База данных**: [blocks/11_DATABASE_SCHEMA.md](./blocks/11_DATABASE_SCHEMA.md)
- 🔌 **API контракты**: [blocks/10_BACKEND_API.md](./blocks/10_BACKEND_API.md)

---

## 📅 История обновлений

| Дата | Версия | Изменения |
|------|--------|-----------|
| 2026-02-19 | 1.0.0 | Первичное создание всей документации |

---

*Документация создана на основе 14 детальных бесед по проектированию системы.*
*Все бизнес-правила и технические решения зафиксированы и валидированы.*
