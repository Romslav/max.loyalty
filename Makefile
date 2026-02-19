.PHONY: help setup dev dev-bg stop logs logs-backend logs-frontend seed reset-db clean shell-postgres shell-redis db-studio type-check lint test

help: ## Показать все команды
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# ========== SETUP ==========

setup: ## 🚀 Первоначальная настройка (один раз)
	@echo "\n🚀 Setting up Max Loyalty development environment...\n"
	cp -n .env.example .env.local 2>/dev/null || echo "  .env.local already exists"
	docker-compose -f docker-compose.dev.yml up -d postgres redis minio mailhog
	@echo "\n⏳ Waiting for databases (5s)..."
	@sleep 5
	npm install
	npm run db:generate
	npm run db:migrate
	$(MAKE) seed
	@echo "\n✅ Setup complete!"
	@echo "\n  Next: make dev\n"

# ========== DEV ==========

dev: ## 🔥 Запустить все сервисы (foreground)
	docker-compose -f docker-compose.dev.yml up

dev-bg: ## 🔥 Запустить все сервисы в фоне
	docker-compose -f docker-compose.dev.yml up -d
	@echo "\n✅ Services started:"
	@echo "  Frontend:  http://localhost:3001"
	@echo "  Backend:   http://localhost:3000"
	@echo "  Mailhog:   http://localhost:8025"
	@echo "  MinIO:     http://localhost:9001\n"

stop: ## ⏹  Остановить все сервисы
	docker-compose -f docker-compose.dev.yml down

restart: stop dev-bg ## 🔄 Перезапустить

# ========== LOGS ==========

logs: ## 📋 Логи всех сервисов
	docker-compose -f docker-compose.dev.yml logs -f

logs-backend: ## 📋 Логи backend
	docker-compose -f docker-compose.dev.yml logs -f backend

logs-frontend: ## 📋 Логи frontend
	docker-compose -f docker-compose.dev.yml logs -f frontend

# ========== DATABASE ==========

seed: ## 🌱 Заполнить БД тестовыми данными
	@echo "🌱 Seeding database..."
	npm run db:seed
	@echo "✅ Done"

reset-db: ## ⚠️  Сбросить БД (УДАЛЯЕТ ВСЕ ДАННЫЕ)
	@echo "⚠️  WARNING: This will delete ALL data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	cd packages/database && npx prisma migrate reset --force
	$(MAKE) seed
	@echo "✅ Database reset"

db-studio: ## 🔍 Открыть Prisma Studio
	npm run db:studio

shell-postgres: ## 🐘 psql shell
	docker-compose -f docker-compose.dev.yml exec postgres \
		psql -U postgres -d maxloyalty_dev

shell-redis: ## 🔴 Redis CLI
	docker-compose -f docker-compose.dev.yml exec redis redis-cli

# ========== QUALITY ==========

type-check: ## 🔎 TypeScript type check
	npm run type-check

lint: ## 🔎 ESLint
	npm run lint

lint-fix: ## 🔧 ESLint fix
	npm run lint:fix

test: ## 🧪 Запустить все тесты
	npm run test

test-unit: ## 🧪 Только unit тесты
	npm run test:unit

test-e2e: ## 🧪 E2E тесты
	npm run test:e2e

# ========== CLEANUP ==========

clean: ## 🗑  Полная очистка (volumes, node_modules, dist)
	@echo "🗑  Cleaning..."
	docker-compose -f docker-compose.dev.yml down -v
	rm -rf apps/*/node_modules apps/*/dist apps/*/.next
	rm -rf packages/*/node_modules
	rm -rf node_modules
	@echo "✅ Cleaned"
