# Cierre operativo migración Tu Dulce Día

## Estado general

La operación principal está migrada a Supabase y GitHub Pages.

## Crítico completo

- Catálogo público.
- Carrito editable.
- Pedido público.
- Envío a Supabase.
- WhatsApp de confirmación.
- Dashboard de pedidos.
- Estados de pedido.
- Estados de pago.
- Anulación de pedidos.
- Inventario, costos y márgenes.
- Backoffice base para productos, insumos, compras, recetas, ingredientes y producción.

## No crítico importante avanzado

### Disponibilidad avanzada

Archivo SQL:

- `database/backoffice-rpc-04-disponibilidad.sql`

Interfaz:

- `admin-disponibilidad-supabase.html`

Permite administrar fecha, estado, cupo máximo y nota.

### Stock detallado

Archivo SQL:

- `database/backoffice-rpc-05-stock.sql`

Interfaz:

- `admin-stock-supabase.html`

Permite movimientos manuales de entrada, salida, ajuste y merma.

### Consumo automático por producción

Archivo SQL:

- `database/backoffice-rpc-06-produccion-consumo.sql`

Reemplaza la función de producción para registrar consumos de ingredientes y salida de stock.

### Reportes

Archivo SQL:

- `database/backoffice-rpc-07-reportes.sql`

Interfaz:

- `admin-reportes-supabase.html`

Entrega resumen por periodo: pedidos, ventas, compras y resultado bruto.

### Edición fina de recetas

La lógica base existe en:

- `admin-backoffice-supabase.html`
- `admin_reemplazar_ingredientes_receta`

Pendiente recomendado:

- Mejorar una interfaz separada para cargar ingredientes actuales con edición visual más cómoda.

## Provisorio / respaldo

No borrar todavía:

- Google Sheets.
- Apps Script.
- `admin-dashboard.html`.
- `admin-inventario.html`.
- páginas de test Supabase antiguas.

Motivo: respaldo temporal ante fallas durante los primeros días de operación real.

## Links formales

Cliente:

- `https://tudulcediacl-gh.github.io/tudulcedia/`

Panel privado:

- `https://tudulcediacl-gh.github.io/tudulcedia/panel-td-privado-2026.html`

Backoffice base:

- `https://tudulcediacl-gh.github.io/tudulcedia/admin-backoffice-supabase.html`

Disponibilidad:

- `https://tudulcediacl-gh.github.io/tudulcedia/admin-disponibilidad-supabase.html`

Stock:

- `https://tudulcediacl-gh.github.io/tudulcedia/admin-stock-supabase.html`

Reportes:

- `https://tudulcediacl-gh.github.io/tudulcedia/admin-reportes-supabase.html`

Dashboard:

- `https://tudulcediacl-gh.github.io/tudulcedia/admin-dashboard-supabase-v3.html`

Inventario / márgenes:

- `https://tudulcediacl-gh.github.io/tudulcedia/admin-inventario-supabase.html`

## Validación pendiente recomendada

Ejecutar en Supabase los archivos SQL avanzados en este orden:

1. `database/backoffice-rpc-04-disponibilidad.sql`
2. `database/backoffice-rpc-05-stock.sql`
3. `database/backoffice-rpc-06-produccion-consumo.sql`
4. `database/backoffice-rpc-07-reportes.sql`

Después validar:

1. Guardar una fecha bloqueada.
2. Registrar entrada manual de stock.
3. Registrar merma manual.
4. Registrar producción y confirmar salida automática de stock.
5. Generar reporte del periodo.

## Seguridad

- Mantener operación admin vía token interno y RPC.
- No exponer service role key en frontend.
- Mantener vistas públicas limitadas al catálogo activo.
- No subir datos privados de clientes al repositorio.
