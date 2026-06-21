# Backup index pre migracion Supabase

Fecha: 2026-06-21

Antes de reemplazar el catalogo principal, se conserva como referencia el `index.html` actual.

## SHA actual de index.html

`430618d9ed2a8919147ff901d751d365032192ac`

## Archivo productivo actual

- `index.html`

## Motivo

Preparar corte controlado hacia catalogo con pedidos directos en Supabase.

## Rollback

Si el nuevo catalogo falla, restaurar `index.html` usando este SHA o la rama backup disponible antes del corte.

## Estado antes del corte

- Catalogo actual opera con Apps Script / Google Sheets.
- Catalogo Supabase directo validado con pedidos:
  - Galletas
  - Pan
  - Mixto
- Dashboard Supabase v3 validado para lectura y edicion.
