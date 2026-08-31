#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL

    -- 1. Criação dos grupos (Roles)
    CREATE ROLE grupo_leitura;
    CREATE ROLE grupo_escrita;

    -- 2. Permissões para o grupo de leitura
    GRANT CONNECT ON DATABASE "$POSTGRES_DB" TO grupo_leitura;
    GRANT USAGE ON SCHEMA public TO grupo_leitura;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO grupo_leitura;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO grupo_leitura;

    -- 3. Permissões para o grupo de escrita
    GRANT CONNECT ON DATABASE "$POSTGRES_DB" TO grupo_escrita;
    GRANT USAGE, CREATE ON SCHEMA public TO grupo_escrita;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO grupo_escrita;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO grupo_escrita;

    -- 4. Criação dos usuários lendo as variáveis de ambiente do Docker
    CREATE USER "$APP_USER" WITH PASSWORD '$APP_PASSWORD';
    CREATE USER "$REPORT_USER" WITH PASSWORD '$REPORT_PASSWORD';

    -- 5. Vinculação dos usuários aos grupos
    GRANT grupo_escrita TO "$APP_USER";
    GRANT grupo_leitura TO "$REPORT_USER";

EOSQL
