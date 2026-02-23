# Seguridad robusta (NPM + Cloudflare + Odoo)

## Objetivo
Cerrar la exposición directa del VPS y publicar Odoo solo detrás de Cloudflare y Nginx Proxy Manager.

## Recomendación de arquitectura
1. Cloudflare Proxy (nube naranja) para `odoo.tudominio.com`.
2. Cloudflare WAF + Rate Limit + Bot Fight Mode.
3. Origin Certificate de Cloudflare instalado en NPM (SSL Full Strict).
4. Firewall VPS permitiendo 80/443 solo desde rangos IP de Cloudflare.
5. Odoo y pgAdmin sin exposición pública directa (`127.0.0.1`).

## Reglas mínimas
1. Bloquear `/web/database/*` salvo IPs administrativas.
2. Limitar `POST` a `/web/login` con rate-limit.
3. Desactivar challenge para sesiones autenticadas válidas.
4. Habilitar HSTS y TLS 1.2+.

## Datos críticos
1. PostgreSQL no debe publicar puertos públicos.
2. pgAdmin solo por túnel o localhost.
3. Backups cifrados en repositorio externo (B2/S3) opcional.
