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

## Fase 1 - Cierre visual del catalogo Supabase

Estado: completada como version candidata.

Cambios aplicados:

- Flujo visual dividido en tres secciones:
  1. Productos.
  2. Datos del pedido.
  3. Resultado del pedido.
- Solo se muestra una seccion a la vez.
- La seccion de productos usa mejor el ancho en escritorio FHD.
- La seccion de datos usa ancho medio/amplio y formulario en dos columnas en escritorio.
- La seccion de resultado usa ancho medio/amplio, centrado y sin bloque tecnico.
- Se oculto el JSON tecnico del flujo visible.
- Se limpiaron textos de prueba en la capa visual.
- Botones finales: enviar WhatsApp y volver al catalogo.

URL candidata limpia:

- `catalogo-supabase.html`

URL directa del flujo:

- `catalogo-supabase-form-test.html`

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
- `catalogo-supabase-enviar-test.js`: envio de prueba, flujo por secciones y armado de mensaje WhatsApp.
- `catalogo-supabase.html`: entrada limpia candidata para revision.

## Produccion

- `index.html` productivo sigue intacto.
- El catalogo principal aun no fue migrado.
- El backend actual sigue operativo.

## Proximo paso recomendado

Iniciar Fase 2: validacion operativa completa desde PC y celular usando la URL candidata limpia.

Casos a revisar:

1. Pedido solo galletas.
2. Pedido solo pan.
3. Pedido mixto.
4. Pedido con transferencia.
5. Pedido con pago al retirar.
6. Pedido con observacion.
7. Pedido desde celular.
8. Pedido desde PC.

Despues de aprobar Fase 2, se puede preparar el reemplazo controlado de `index.html` o mantener la version paralela por mas tiempo.
