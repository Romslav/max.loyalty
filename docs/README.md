# 📚 Max Loyalty — Полная Документация Проекта

> **Max Loyalty** — многопользовательская (multi-tenant) SaaS-платформа лояльности для сети ресторанов.  
> Документация охватывает все аспекты системы: от архитектурных решений до кода конкретных компонентов.

---

## 🗂️ Структура документации

```
docs/
├── README.md                          ← Вы здесь: навигация
│
├── 00_SYSTEM_OVERVIEW.md             ← Полное описание всей системы
│
├── blocks/
│   ├── 01_DATABASE_SCHEMA.md         ← Prisma-схема, модели, миграции
│   ├── 02_BACKEND_API.md             ← NestJS API, модули, эндпоинты
│   ├── 03_POS_INTEGRATION.md         ← iiko, R-Keeper, Webhook/PULL
│   ├── 04_FRONTEND_ADMIN.md          ← Next.js 14, shadcn/ui, stack
│   ├── 05_OWNER_DASHBOARD.md         ← Дашборд платформы (Owner)
│   ├── 06_MANAGER_DASHBOARD.md       ← Дашборд ресторана (Manager)
│   ├── 07_CASHIER_POS.md             ← Кассовый интерфейс (Cashier)
│   ├── 08_TELEGRAM_MINI_APP.md       ← Telegram Bot + Mini App
│   ├── 09_NOTIFICATIONS.md           ← Уведомления (BullMQ, 4 канала)
│   ├── 10_LOYALTY_ENGINE.md          ← Движок лояльности
│   ├── 11_ANALYTICS.md               ← Аналитика и отчёты
│   ├── 12_BILLING.md                 ← Биллинг и подписки
│   ├── 13_TESTING_STRATEGY.md        ← Стратегия тестирования
│   ├── 14_INFRASTRUCTURE_DEVOPS.md   ← DevOps, CI/CD, деплой
│   ├── 15_SECURITY_COMPLIANCE.md     ← Безопасность (51 контроль)
│   ├── 16_API_DOCUMENTATION.md       ← OpenAPI, Webhooks, SDK
│   ├── 17_IIKO_PLUGIN.md             ← Плагин iiko Front (.NET/WPF)
│   └── 18_RKEEPER_PLUGIN.md          ← Плагин R-Keeper (C++/WPF)
│
├── 19_DEVELOPMENT_ROADMAP.md         ← Путь разработки (32 недели)
├── 20_PROJECT_STRUCTURE.md           ← Структура файлов проекта
└── 21_PROJECT_ARCHITECTURE.md        ← Архитектура (C4, ER, Sequence)
```

---

## 🚀 Быстрый старт по документации

| Если вы... | Читайте... |
|---|---|
| Хотите понять систему целиком | [`00_SYSTEM_OVERVIEW.md`](./00_SYSTEM_OVERVIEW.md) |
| Настраиваете базу данных | [`blocks/01_DATABASE_SCHEMA.md`](./blocks/01_DATABASE_SCHEMA.md) |
| Разрабатываете backend API | [`blocks/02_BACKEND_API.md`](./blocks/02_BACKEND_API.md) |
| Интегрируете POS-систему | [`blocks/03_POS_INTEGRATION.md`](./blocks/03_POS_INTEGRATION.md) |
| Строите frontend | [`blocks/04_FRONTEND_ADMIN.md`](./blocks/04_FRONTEND_ADMIN.md) |
| Настраиваете Telegram бота | [`blocks/08_TELEGRAM_MINI_APP.md`](./blocks/08_TELEGRAM_MINI_APP.md) |
| Разворачиваете инфраструктуру | [`blocks/14_INFRASTRUCTURE_DEVOPS.md`](./blocks/14_INFRASTRUCTURE_DEVOPS.md) |
| Интегрируете iiko-плагин | [`blocks/17_IIKO_PLUGIN.md`](./blocks/17_IIKO_PLUGIN.md) |
| Планируете разработку | [`19_DEVELOPMENT_ROADMAP.md`](./19_DEVELOPMENT_ROADMAP.md) |

---

## 📄 Описание всех документов

### 🌐 Файл 1: `00_SYSTEM_OVERVIEW.md` — Полное описание системы
Концепция Max Loyalty от начала до конца. Все роли (Owner → Admin → Manager → Cashier → Guest),  
все 6 тарифных планов, пользовательские пути, технологический стек с обоснованием каждого выбора,  
глоссарий терминов, архитектурные решения, FAQ.

---

### 🗄️ Файл 2: `blocks/01_DATABASE_SCHEMA.md` — Database Schema
Полная Prisma-схема всех 35+ моделей. Multi-tenancy (pooled, `tenantId` в каждой таблице),  
все связи, индексы, constraints, enums, стратегия миграций, seed-данные, примеры запросов.

**Ключевые модели:** `User`, `GuestProfile`, `GuestCard`, `BallTransaction`, `LoyaltyRule`,  
`LoyaltyRuleVersion`, `PromoRule`, `POSTransaction`, `Subscription`, `Payment`, `Notification`

---

### 🔧 Файл 3: `blocks/02_BACKEND_API.md` — Backend API (NestJS)
Модульный монолит на NestJS. 80+ API-эндпоинтов, полный код Guards, Decorators, DTOs,  
Services. Loyalty Engine API (calculate, earn, redeem), Loyalty Builder (rules/levels/promos),  
Background Jobs (BullMQ), Analytics API (4 уровня), Notifications API, Error Handling (RFC 7807).

---

### 🏪 Файл 4: `blocks/03_POS_INTEGRATION.md` — POS Integration
Гибридная PUSH/PULL архитектура интеграции с кассовыми системами (iiko, R-Keeper, AirKeeper).  
Webhook обработка с HMAC-SHA256, BullMQ-очередь, idempotency, reconciliation,  
Adaptor pattern (`IPOSAdapter`), feature-матрица систем, Offline/CSV fallback.

---

### 🖥️ Файл 5: `blocks/04_FRONTEND_ADMIN.md` — Frontend Admin Panel
Next.js 14 App Router + shadcn/ui + Tailwind CSS + TanStack Query + Zustand.  
Dark design system (CSS variables), Server-Sent Events для real-time,  
Layout (Sidebar/Header/Breadcrumbs), все страницы по ролям.

---

### 📊 Файл 6: `blocks/05_OWNER_DASHBOARD.md` — Owner Platform Dashboard
35 детальных вопросов и ответов. KPI (MRR, Churn, Active Tenants), Tenant Table с действиями,  
Impersonation Flow, Tenant Details Modal (5 вкладок), Health Score алгоритм,  
Cohort Analysis, Predicted Churn, Real-time SSE, Mobile-responsive.

---

### 🍽️ Файл 7: `blocks/06_MANAGER_DASHBOARD.md` — Manager Dashboard
Аналитика одного ресторана: Revenue, Avg Check, RFM-сегментация гостей,  
управление лояльностью в рамках разрешений, отчёты и экспорт (CSV/Excel).

---

### 🖨️ Файл 8: `blocks/07_CASHIER_POS.md` — Cashier POS Interface
Отдельное веб-приложение `pos.maxloyalty.app`. PIN-авторизация (NumPad UI),  
Touch-оптимизированный поиск (debounce 200ms, barcode scanner), Earn/Redeem модалы,  
Offline-режим (IndexedDB), тепловая печать, защита от мошенничества.

---

### 📱 Файл 9: `blocks/08_TELEGRAM_MINI_APP.md` — Telegram Mini App
41 детальный вопрос и ответ. Telegraf-бот, UNIFIED/SEPARATE режимы, онбординг гостя,  
Mini App auth (HMAC-SHA256 → JWT), дизайн карты лояльности (QR 280px, цвета уровней),  
уведомления, edge-cases (бот заблокирован, восстановление аккаунта).

---

### 🔔 Файл 10: `blocks/09_NOTIFICATIONS.md` — Notifications System
16 типов уведомлений, 4 канала (Telegram/Email/SMS/Push), BullMQ-очереди с приоритетами,  
HTML-шаблоны email, SMS-провайдеры (SMSC.ru), opt-in/opt-out управление гостем,  
history с retry и Dead Letter Queue.

---

### 🎯 Файл 11: `blocks/10_LOYALTY_ENGINE.md` — Loyalty Engine
Полный движок лояльности: POINTS/DISCOUNT типы, UNIFIED/SEPARATE режимы,  
версионирование правил (`LoyaltyRuleVersion`), стратегии конфликта промо  
(COMBINE_ALL/MAX_ONLY/FIRST_ONLY), FIFO-экспирация баллов, уровни гостей (Bronze/Silver/Gold),  
миграции UNIFIED↔SEPARATE, reconciliation, Redis-кэш.

---

### 📈 Файл 12: `blocks/11_ANALYTICS.md` — Analytics & Reports
4 уровня аналитики: Platform (Owner) / Restaurant (Admin) / My Restaurant (Manager) / Personal (Guest).  
`AnalyticsDailySnapshot`, CRON pre-calculation, RFM-сегментация,  
Cohort Analysis, Retention curves, экспорт CSV/Excel.

---

### 💳 Файл 13: `blocks/12_BILLING.md` — Billing & Subscriptions
6 тарифных планов (FREE/STANDARD/MEDIUM/PRO/ULTIMATE/CUSTOM), Trial, grace period 90 дней,  
YooKassa + Stripe + CloudPayments + CryptoCloud, refund/chargeback,  
manual invoice, limit enforcement, upgrade/downgrade flow.

---

### 🧪 Файл 14: `blocks/13_TESTING_STRATEGY.md` — Testing Strategy
Пирамида тестов: 10 Unit + 10 Integration + 10 E2E + 5 Contract + 10 Load + 10 Security = 55 тестов.  
Jest, Supertest, k6, Artillery. GitHub Actions CI/CD матрица.

---

### 🏗️ Файл 15: `blocks/14_INFRASTRUCTURE_DEVOPS.md` — Infrastructure & DevOps
Fly.io (backend) + Vercel (frontend) + Neon.tech (PostgreSQL) + Upstash (Redis).  
Multi-stage Dockerfile, `PROCESS_TYPE` (api/worker/cron), GitHub Actions CI/CD,  
Prometheus + Grafana + Sentry + ELK, graceful shutdown, secrets management.

---

### 🔒 Файл 16: `blocks/15_SECURITY_COMPLIANCE.md` — Security & Compliance
51 контроль безопасности. JWT RS256, AES-256-GCM (PII), TLS 1.3, bcrypt(cost=12),  
GDPR (right-to-erasure, consent), PCI DSS, P1-P4 SLA, Incident Response Playbooks,  
Daily Snyk scan, penetration testing, $52,000 security budget Year 1.

---

### 📖 Файл 17: `blocks/16_API_DOCUMENTATION.md` — API Documentation
OpenAPI 3.0 + GitBook. 20 webhook-событий, HMAC-подпись, exponential backoff retry,  
TypeScript SDK (auto-gen через GitHub Actions), Postman Workspace,  
changelog automation, Sandbox (staging keys `mlk_test_...`), community `@maxloyaltydev`.

---

### 🔌 Файл 18: `blocks/17_IIKO_PLUGIN.md` — iiko Front Plugin (.NET/WPF)
C# .NET 4.7.2 плагин для iiko Front. `IFrontPlugin` интерфейс, полный lifecycle заказа,  
LoyaltyApiClient (Polly retry), OfflineQueueService (JSON файл, max 100 ops, TTL 24ч),  
WPF-окна (Search/Operation/Diagnostics), API Key шифрование AES-256, auto-update.

---

### 🔌 Файл 19: `blocks/18_RKEEPER_PLUGIN.md` — R-Keeper Plugin (C++/WPF)
Два компонента: `MaxLoyaltyRKeeper.dll` (C++ Native, External DLL) + `MaxLoyaltyRKeeperUI.exe` (C# WPF).  
Shared Memory (Memory-Mapped File, 1 MB JSON), FarCard protocol,  
Installer Wizard (7 шагов: автообнаружение R-Keeper, FarCard конфигурация), PBKDF2 API Key.

---

### 🗓️ Файл 20: `19_DEVELOPMENT_ROADMAP.md` — Development Roadmap
Путь разработки от нуля до production за 32 недели (8 фаз).  
Детальные задачи по каждой неделе в формате GitHub Issues,  
Definition of Done для каждого блока, риски и митигации.

---

### 📁 Файл 21: `20_PROJECT_STRUCTURE.md` — Project Structure
Полная структура Monorepo (Turborepo/pnpm workspaces).  
Каждая папка и файл с описанием: `apps/backend/`, `apps/frontend/`, `apps/cashier/`,  
`apps/telegram-mini-app/`, `apps/iiko-plugin/`, `apps/rkeeper-plugin/`, `packages/`, `libs/`.

---

### 🏛️ Файл 22: `21_PROJECT_ARCHITECTURE.md` — Project Architecture
C4 Model (Context/Container/Component), ER-диаграмма (Mermaid),  
Sequence диаграммы (Earn Balls, Webhook, Auth, Telegram onboarding),  
Deployment диаграмма, Data Flow, Security boundaries.

---

## 🔑 Ключевые технологии

| Слой | Технологии |
|---|---|
| **Backend** | NestJS 10 + TypeScript + Prisma 5 + PostgreSQL 15 |
| **Queue/Cache** | BullMQ + Redis 7 + Upstash |
| **Frontend** | Next.js 14 + shadcn/ui + Tailwind CSS + TanStack Query + Zustand |
| **Telegram** | Telegraf + Telegram Mini App (React) |
| **POS Plugins** | C# .NET 4.7.2 WPF (iiko) + C++ Native DLL + C# WPF (R-Keeper) |
| **Payments** | YooKassa + Stripe + CloudPayments + CryptoCloud |
| **Hosting** | Fly.io + Vercel + Neon.tech (PostgreSQL) + Upstash (Redis) |
| **CI/CD** | GitHub Actions + Docker multi-stage |
| **Monitoring** | Prometheus + Grafana + Sentry + ELK Stack + BetterStack |

---

## 👥 Роли системы

```
Owner
├── Управляет платформой целиком (тенанты, биллинг, аналитика платформы)
├── Может импersonate любого пользователя (с логированием)
│
Restaurant Admin
├── Управляет конкретным рестораном
├── Настраивает loyalty rules, levels, promos
├── Видит аналитику своего ресторана
│
Manager
├── Операционное управление рестораном
├── Может делать manual adjustment баллов (с причиной)
├── Видит аналитику своего ресторана (без billing)
│
Cashier
├── Работает с кассовым интерфейсом (pos.maxloyalty.app)
├── Earn/Redeem баллы для гостей
├── Регистрирует новых гостей
│
Guest
└── Пользуется Telegram Mini App
    └── Видит баланс, историю, QR-код карты
```

---

## 📊 Статус документации

| # | Документ | Статус | Сессий |
|---|---|---|---|
| 00 | System Overview | 🔄 В работе | 9 |
| 01 | Database Schema | ⏳ Ожидание | 7 |
| 02 | Backend API | ⏳ Ожидание | 8 |
| 03 | POS Integration | ⏳ Ожидание | 7 |
| 04 | Frontend Admin | ⏳ Ожидание | 7 |
| 05 | Owner Dashboard | ⏳ Ожидание | 7 |
| 06 | Manager Dashboard | ⏳ Ожидание | 6 |
| 07 | Cashier POS | ⏳ Ожидание | 7 |
| 08 | Telegram Mini App | ⏳ Ожидание | 7 |
| 09 | Notifications | ⏳ Ожидание | 6 |
| 10 | Loyalty Engine | ⏳ Ожидание | 7 |
| 11 | Analytics | ⏳ Ожидание | 6 |
| 12 | Billing | ⏳ Ожидание | 6 |
| 13 | Testing Strategy | ⏳ Ожидание | 6 |
| 14 | Infrastructure DevOps | ⏳ Ожидание | 7 |
| 15 | Security Compliance | ⏳ Ожидание | 7 |
| 16 | API Documentation | ⏳ Ожидание | 7 |
| 17 | iiko Plugin | ⏳ Ожидание | 6 |
| 18 | R-Keeper Plugin | ⏳ Ожидание | 6 |
| 19 | Development Roadmap | ⏳ Ожидание | 8 |
| 20 | Project Structure | ⏳ Ожидание | 7 |
| 21 | Project Architecture | ⏳ Ожидание | 7 |

**Легенда:** ✅ Завершён · 🔄 В работе · ⏳ Ожидание

---

## 🔗 Полезные ссылки

- **Репозиторий:** [github.com/Romslav/max.loyalty](https://github.com/Romslav/max.loyalty)
- **Сессии создания документации:** С-001 → С-152
- **Формат беседы:** 14 бесед + 2 файла плагинов = ~914 вопросов/решений

---

*Документация создана на основе 14 детальных проектировочных бесед и описаний плагинов iiko/R-Keeper.*  
*Каждый файл содержит минимум 400KB детального контента с примерами кода.*
