# Revision movil y archivos temporales

## Revision movil del catalogo final

URL principal:

`/`

Estado revisado desde el codigo activo:

- El catalogo principal carga la version final de pedidos.
- En pantallas pequenas los productos pasan a una columna.
- El formulario queda debajo del catalogo.
- Los botones mantienen tamano tactil adecuado.
- El resumen queda visible en columna unica.
- Las reglas de anticipacion se muestran en el bloque del pedido.

## Punto a observar

La entrada principal carga el catalogo final dentro de una capa contenedora para aplicar textos finales sin reescribir el archivo grande.

Esto es aceptable como solucion temporal para pasar pedidos reales, pero despues del lunes conviene dejar el HTML final directo en `index.html`.

## No borrar hasta despues del lunes

Mantener estos archivos porque sirven para rollback, comparacion o respaldo:

- `index-supabase-final.html`
- `catalogo-supabase-pedido.html`
- `catalogo-supabase-form-test.html`
- `catalogo-supabase-carrito-test.html`
- `catalogo-supabase.html`
- `index-supabase-test.html`
- `admin-dashboard-supabase-v2.html`
- `admin-dashboard-supabase-v3.html`
- `admin-dashboard.html`
- `admin-dashboard-fase3.html`
- `admin-dashboard-supabase.html`

## Mantener documentacion

- `docs/backup-index-pre-supabase-2026-06-21.md`
- `docs/operacion-diaria-supabase.md`
- `docs/migracion-definitiva-supabase-lunes.md`
- `docs/estado-fase-2-supabase.md`
- `docs/fase-3-dashboard-validacion.md`

## Pendiente despues del lunes

- Consolidar `index.html` sin capa contenedora.
- Eliminar o archivar pruebas antiguas.
- Dejar solo dashboard principal y respaldo minimo.
- Revisar si se mantiene o no el dashboard Sheets.
