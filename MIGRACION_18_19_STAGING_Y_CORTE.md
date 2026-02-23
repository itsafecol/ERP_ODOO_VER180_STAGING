# Migracion Odoo 18 -> 19 (Staging + Corte Seguro)

Fecha de ejecucion: 2026-02-21

## Estado actual confirmado
- Produccion esta operativa en Odoo 18 con PostgreSQL 16.
- La validacion funcional en staging de Odoo 19 falla antes de modulos custom (fase base/core).
- Evidencia principal: conversion de columna a `jsonb` en base/core.

## Resultado de validacion por base (staging)

Archivo: `migration_backups/staging_upgrade_logs/by_db/results.tsv`

- `eficacia|255|base,muk_web_theme`
- `itsafe.com.co_contadores|255|base,base_accounting_kit,l10n_co_edi_jorels,muk_web_theme`
- `itsafe.com.co_dev|255|base,muk_web_theme`
- `itsafe.com.co_prueba|255|base,muk_web_theme`
- `itsafe.com.co_test|255|base,muk_web_theme,l10n_co_edi_jorels,om_account_accountant`

Error comun detectado:
- `psycopg2.errors.CannotCoerce: cannot cast type integer to jsonb`
- SQL asociado: conversion de `create_uid` a `jsonb` durante init/upgrade de modelos core.

Logs:
- `migration_backups/staging_upgrade_logs/by_db/eficacia.log`
- `migration_backups/staging_upgrade_logs/by_db/itsafe.com.co_contadores.log`
- `migration_backups/staging_upgrade_logs/by_db/itsafe.com.co_dev.log`
- `migration_backups/staging_upgrade_logs/by_db/itsafe.com.co_prueba.log`
- `migration_backups/staging_upgrade_logs/by_db/itsafe.com.co_test.log`

## Decision de avance
- No hacer corte a produccion con Odoo 19 hasta completar migracion funcional real de DB en staging.
- El bloqueo actual es de esquema base, no de modulo custom.

## Ruta operativa recomendada (sin riesgo)

## Fase 1: Staging limpio y repetible
1. Clonar backup reciente de produccion en staging.
2. Ejecutar migracion con framework compatible de migracion de version (OpenUpgrade para 18->19).
3. Correr upgrade base y luego modulos por lotes.
4. Validar negocio por DB (login, ventas, contabilidad, facturacion electronica, reportes).

## Fase 2: Validacion por modulo custom
1. `muk_web_theme`
2. `base_accounting_kit`
3. `l10n_co_edi_jorels`
4. `om_account_accountant`
5. `auto_database_backup`, `my_auto_backup`, `wk_backup_restore` (si aplican por DB)

Para cada modulo:
1. Instala/actualiza en staging.
2. Ejecuta flujo funcional real.
3. Registra resultado (OK/Falla, accion, evidencia).

## Fase 3: Go/No-Go
Checklist minima para `GO`:
1. Todas las DB abren login en Odoo 19.
2. Sin errores `CRITICAL/ERROR` en arranque por DB.
3. Flujos de negocio criticos aprobados por usuario funcional.
4. Backup final de corte validado con restore de prueba.

## Corte final a produccion (ventana controlada)

## Pre-corte (obligatorio)
1. Congelar cambios funcionales durante ventana.
2. Backup final:
   - `docker exec postgresqlitsafever18 pg_dumpall -U itsafedb > migration_backups/prod_cutover_final_$(date +%F_%H-%M-%S).sql`
3. Snapshot extra de archivos:
   - `cp docker-compose.yml migration_backups/docker-compose.pre_cutover_$(date +%F_%H-%M-%S).yml`
   - `cp odoo/Dockerfile migration_backups/Dockerfile.pre_cutover_$(date +%F_%H-%M-%S)`

## Ejecucion corte (solo si staging paso completo)
1. Cambiar imagen/build de Odoo productivo a 19.
2. `docker compose build --no-cache odoo_itsafe_ver18`
3. `docker compose up -d --force-recreate odoo_itsafe_ver18`
4. Validar por cada DB login y flujos criticos.

## Rollback inmediato (si hay incidente)
1. Revertir Odoo a 18:
   - Ajustar `odoo/Dockerfile` a `FROM odoo:18.0`
   - `docker compose build --no-cache odoo_itsafe_ver18`
   - `docker compose up -d --force-recreate odoo_itsafe_ver18`
2. Si requiere rollback de datos:
   - Restaurar dump de pre-corte sobre instancia objetivo.
3. Validar acceso funcional y logs sin errores.

## Nota de seguridad de datos
- Las pruebas de migracion se ejecutan en staging.
- No aplicar SQL de conversion manual en produccion sin evidencia validada en staging.
- Mantener siempre al menos 2 backups completos previos al corte.
