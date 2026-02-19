<div align="center">

# 🎯 Max Loyalty

**Multi-tenant SaaS платформа лояльности для ресторанов**

[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript)](https://www.typescriptlang.org/)
[![NestJS](https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs)](https://nestjs.com/)
[![Next.js](https://img.shields.io/badge/Next.js-14-black?logo=next.js)](https://nextjs.org/)
[![Prisma](https://img.shields.io/badge/Prisma-5.x-2D3748?logo=prisma)](https://www.prisma.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](https://opensource.org/licenses/MIT)

</div>

---

## 📋 Содержание

- [О проекте](#о-проекте)
- [Архитектура](#архитектура)
- [Технологии](#технологии)
- [Роли](#роли)
- [Структура репозитория](#структура-репозитория)
- [Быстрый старт](#быстрый-старт)
- [Документация](#документация)

---

## О проекте

**Max Loyalty** — полноценная SaaS-платформа программы лояльности для ресторанного бизнеса.  
Владельцы ресторанов настраивают баллы, уровни и промо-акции; гости используют Telegram Mini App; кассиры работают через плагины к POS-системам (iiko, R-Keeper).

### Ключевые возможности

- 🏗️ **Multi-tenant SaaS** — каждый ресторан или сеть работает в изолированном пространстве
- 💳 **Loyalty Engine** — баллы (1 балл = 1 ₽ при списании), уровни Bronze→Silver→Gold→Platinum, промо-акции
- 🔗 **POS-интеграции** — плагин для iiko (C# WPF) и DLL для R-Keeper (C++)
- 📱 **Telegram Mini App** — кабинет гостя: баланс, история, QR-код, уровень
- 📊 **Аналитика** — Owner/Admin/Manager дашборды, RFM-сегментация, ROI лояльности
- 💰 **Биллинг** — 6 тарифов (Free/Standard/Medium/Pro/Ultimate/Custom), YooKassa, Stripe
- 🔔 **Уведомления** — Telegram-бот, Email (Resend), SMS (SMS.RU)
- 🛡️ **Безопасность** — JWT, RBAC, HMAC, RLS, шифрование API-ключей, 51 контроль

---

## Архитектура

```
┌──────────────────────────────────────────────────────────────────┐
│                          КЛИЕНТЫ                                 │
│  Owner Browser  │ Admin Browser │ Telegram App  │  POS Plugin    │
└──────┬──────────┴───────┬───────┴───────┬───────┴──────┬─────────┘
       │                  │               │              │
       └──────────────────┼───────────────┼──────────────┘
                          ▼               ▼
           ┌──────────────────────────────────────────────┐
           │          Backend API (Fly.io)                │
           │      NestJS 10 — Modular Monolith             │
           │  REST API v1  │ Webhooks │ SSE │ BullMQ Queue │
           └──────┬──────────────────────────┬────────────┘
                  │                          │
    ┌─────────────▼──────┐    ┌──────────────▼──────────┐
    │  PostgreSQL         │    │  Redis (Upstash)         │
    │  Neon.tech          │    │  Cache + Sessions + BullMQ│
    └────────────────────┘    └─────────────────────────┘
```

**Принципы:**
- **Monorepo** (npm workspaces): `apps/*` + `packages/*`
- **Multi-tenancy**: shared DB + `tenantId` на каждой таблице + Prisma middleware RLS
- **Offline-first POS**: очередь offline-операций в плагинах, синхронизация при восстановлении
- **Dual-secret JWT**: горячая ротация секретов без downtime

---

## Технологии

### Backend
| Слой | Технология |
|------|------------|
| Framework | NestJS 10 (Modular Monolith) |
| ORM | Prisma 5 + PostgreSQL |
| Cache | Redis (Upstash) + ioredis |
| Queue | BullMQ |
| Auth | JWT (access 15m + refresh 30d) + RBAC |
| Validation | class-validator + Zod (config) |
| Logging | Winston + Better Stack (Logtail) |
| Email | Resend + React Email |
| SMS | SMS.RU (~1 ₽/SMS) |
| Payments | YooKassa, Stripe, CloudPayments, CryptoCloud |

### Frontend (Admin Panel)
| Слой | Технология |
|------|------------|
| Framework | Next.js 14 (App Router) |
| UI Kit | shadcn/ui + Radix UI + Tailwind CSS |
| State | Zustand + TanStack Query v5 |
| Tables | TanStack Table v8 |
| Charts | Recharts |
| Forms | React Hook Form + Zod |
| Theme | Тёмная тема, CSS переменные, Inter / JetBrains Mono |

### Telegram Mini App
| Слой | Технология |
|------|------------|
| Bot | grammY (TypeScript) |
| Mini App | React + Vite |
| Auth | Telegram WebApp API + OTP (4 цифры, 5 мин) |

### POS Plugins
| Плагин | Технология |
|--------|------------|
| iiko Front | C# (.NET 4.7.2) + WPF, кнопка «ДОПОЛНЕНИЯ» |
| R-Keeper | C++ DLL + C# WPF UI, Floating Button поверх кассы |

### Infrastructure
| Компонент | Решение |
|-----------|---------|
| Backend Deploy | Fly.io (3 VM: API + Worker + Cron), region `fra` |
| Frontend Deploy | Vercel |
| Database | Neon.tech (PostgreSQL), region `eu-central-1` |
| Cache | Upstash Redis |
| Storage | Cloudflare R2 (S3-совместимый) |
| CI/CD | GitHub Actions |
| Monitoring | Better Stack (logs + uptime) |
| DNS/CDN | Cloudflare |

---

## Роли

| Роль | Описание |
|------|----------|
| **Owner** | Суперадмин платформы: видит все тенанты, MRR/ARR, может impersonate любого пользователя |
| **Admin** | Владелец/Администратор ресторана или сети: настраивает loyalty, управляет командой |
| **Manager** | Управляет одним/несколькими ресторанами: гости, баллы, аналитика своего ресторана |
| **Cashier** | Кассир: начисление/списание баллов через POS (PIN-auth, touch UI) |
| **Guest** | Гость ресторана: Telegram Mini App — карта, баланс, история, QR-код |

---

## Структура репозитория

```
max.loyalty/
├── apps/
│   ├── backend/             # NestJS 10 API — основной бэкенд
│   ├── frontend/            # Next.js 14 — Admin/Manager/Owner Panel
│   ├── telegram-bot/        # Telegram Bot + Mini App (grammY + React/Vite)
│   ├── iiko-plugin/         # C# WPF плагин для iiko Front
│   └── rkeeper-plugin/      # C++ DLL + C# WPF UI для R-Keeper
├── packages/
│   ├── shared/              # Общие типы, утилиты, константы
│   └── database/            # Prisma schema + migrations
├── docs/
│   ├── INDEX.md             # 📚 Главный индекс всей документации
│   ├── architecture/        # Архитектурные решения
│   └── sessions/            # Сессии детализации (S-00 → S-14)
├── scripts/                 # Утилиты: seed, backup, rotate-secrets
├── .github/
│   └── workflows/           # CI/CD: test, deploy-backend, deploy-frontend
├── docker-compose.dev.yml   # Локальная разработка (5 сервисов)
├── Makefile                 # make setup | make dev | make logs
├── package.json             # Root workspace
└── README.md
```

---

## Быстрый старт

```bash
# 1. Клонировать
git clone https://github.com/Romslav/max.loyalty.git
cd max.loyalty

# 2. Первоначальная настройка (один раз)
make setup

# 3. Запустить все сервисы
make dev

# 4. Открыть в браузере
#  Frontend:  http://localhost:3001
#  Backend:   http://localhost:3000
#  Mailhog:   http://localhost:8025
#  MinIO:     http://localhost:9001
#  pgAdmin:   psql через docker exec
```

**Требования:** Node.js 20+, Docker Desktop, `make`

---

## Документация

📚 **[→ Полный индекс документации](docs/INDEX.md)**

| Блок | Описание | Решений |
|------|----------|---------|
| [S-00](docs/sessions/S-00-setup.md) | Setup — структура, стек, конфиги | — |
| [S-01](docs/sessions/S-01-db-schema.md) | Database Schema (Prisma) | 35 |
| [S-02](docs/sessions/S-02-backend-api.md) | Backend API (NestJS) | 30 |
| [S-03](docs/sessions/S-03-pos-integration.md) | POS Integration iiko + R-Keeper | 36 |
| [S-04](docs/sessions/S-04-frontend-admin.md) | Frontend Admin Panel | 31 |
| [S-05](docs/sessions/S-05-manager-dashboard.md) | Manager Dashboard | 25 |
| [S-06](docs/sessions/S-06-cashier-interface.md) | Cashier POS Interface | 25 |
| [S-07](docs/sessions/S-07-telegram-mini-app.md) | Guest Telegram Mini App | 41 |
| [S-08](docs/sessions/S-08-notifications.md) | Notifications System | 36 |
| [S-09](docs/sessions/S-09-analytics.md) | Analytics & Reporting | 21 |
| [S-10](docs/sessions/S-10-billing.md) | Billing & Subscriptions | 23 |
| [S-11](docs/sessions/S-11-testing.md) | Testing Strategy | 40 |
| [S-12](docs/sessions/S-12-infrastructure.md) | Infrastructure & DevOps | 47 |
| [S-13](docs/sessions/S-13-owner-dashboard.md) | Owner Platform Dashboard | 35 |
| [S-14](docs/sessions/S-14-api-docs.md) | API Documentation & Webhooks | 30 |

**Итого: ~450 решений по 14 блокам**

---

*MIT © Max Loyalty*
