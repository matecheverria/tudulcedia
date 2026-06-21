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

## Validacion de pedidos test

Validado en Google Sheets con tres casos reales de prueba:

- `TD-0013`: pedido de galletas.
- `TD-0014`: pedido de pan de masa madre.
- `TD-0015`: pedido mixto pan + galletas.

Resultado: los tres pedidos llegaron correctamente a la hoja de pedidos.

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

Preparar una copia productiva controlada del catalogo principal usando Supabase para catalogo y el backend actual para registro de pedidos.

Despues de revisar esa copia con el diseño real, se puede decidir si se reemplaza `index.html` o si se mantiene como version paralela por mas tiempo.
