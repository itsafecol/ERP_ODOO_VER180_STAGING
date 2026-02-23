# Runbook Escalamiento ITSAFE

Fecha: 2026-02-23

## 1) Levantar producción actual (Odoo 18)
```bash
docker compose -f docker-compose.secure.yml up -d postgresql_itsafe_ver18 odoo_itsafe_ver18 pgadmin_itsafe_ver18 backup_postgresql_itsafe_ver18
```

## 2) Crear bases de ambiente
```bash
./scripts_secure/create_environment_dbs.sh
```

## 3) Levantar UAT (Odoo 19)
```bash
docker compose -f docker-compose.secure.yml --profile uat up -d odoo_itsafe_uat_ver19
```

## 4) Levantar STAGING (Odoo 19)
```bash
docker compose -f docker-compose.secure.yml --profile staging up -d odoo_itsafe_staging_ver19
```

## 5) Backup
- Programado diario a las 02:00 AM (America/Bogota).
- Conserva solo el último dump completo (`pg_dumpall`).
- Ruta local persistente: `vol_db_postgres_proyectoitsafe/`.

## 6) Migración controlada 18 -> 19
1. Ejecutar OpenUpgrade en STAGING.
2. Validar módulos críticos y flujos funcionales.
3. Repetir en UAT con datos consistentes.
4. Ejecutar corte productivo solo con aprobación funcional.

## 7) Puertos locales
- Odoo PROD: `127.0.0.1:8004`
- Odoo UAT: `127.0.0.1:8014`
- Odoo STAGING: `127.0.0.1:18004`
- pgAdmin: `127.0.0.1:5010`
