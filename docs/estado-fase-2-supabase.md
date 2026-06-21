# Estado fase 2 Supabase

## Objetivo

Validar una migracion gradual donde Supabase entregue el catalogo, manteniendo el registro de pedidos en el backend actual hasta completar las pruebas.

## Estado validado

- Supabase entrega productos activos correctamente.
- La prueba de lectura publica funciona con RLS y permisos activos.
- El carrito de prueba permite seleccionar productos, cantidades y calcular total.
- La prueba de formulario genera estructura de pedido correcta.
- La regla de anticipacion quedo corregida:
  - Solo galletas: minimo 1 dia.
  - Solo pan de masa madre: minimo 3 dias.
  - Pedido mixto pan + galletas: minimo 3 dias.
- La opcion de separar pan y galletas solo aplica en pedido mixto.
- El flujo de prueba registra pedidos en el backend actual.
- El mensaje de WhatsApp fue corregido para que sea escrito desde el cliente hacia el negocio.

## Archivos de prueba

- `supabase-catalogo-test.html`: lectura aislada desde Supabase.
- `catalogo-supabase-carrito-test.html`: catalogo Supabase con carrito local.
- `catalogo-supabase-form-test.html`: catalogo Supabase con carrito, formulario y envio de prueba.
- `catalogo-supabase-enviar-test.js`: envio de prueba y armado de mensaje WhatsApp.

## Produccion

- `index.html` productivo sigue intacto.
- El catalogo principal aun no fue migrado.
- El backend actual sigue operativo.

## Proximo paso recomendado

Antes de tocar `index.html`, hacer una revision final del flujo test completo:

1. Pedido solo galletas.
2. Pedido solo pan.
3. Pedido mixto.
4. Validar folio y datos en dashboard.
5. Validar mensaje WhatsApp.

Cuando esos tres casos esten aprobados, se puede preparar una copia productiva controlada o aplicar el cambio final al catalogo principal.
