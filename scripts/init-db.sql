-- Max Loyalty — Database Initialization Script
-- Запускается автоматически при первом старте PostgreSQL контейнера

-- Создаём дополнительные расширения
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "unaccent";  -- для нечёткого поиска по имени

-- Тестовая база для интеграционных тестов
CREATE DATABASE maxloyalty_test;
GRANT ALL PRIVILEGES ON DATABASE maxloyalty_test TO postgres;
