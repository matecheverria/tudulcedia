# Fase 3 - Dashboard y administracion

## Objetivo

Validar que los pedidos generados desde el catalogo Supabase se gestionen correctamente en el dashboard actual, sin romper la operacion productiva.

## Estado de partida

- Los pedidos creados desde el catalogo Supabase llegan a Google Sheets.
- El dashboard actual sigue leyendo desde el backend actual.
- `index.html` productivo sigue intacto.
- El catalogo Supabase candidato aun esta en version paralela.

## Casos a validar en dashboard

### 1. Pedido solo galletas

Validar:

- Aparece en dashboard.
- Total correcto.
- Fecha solicitada correcta.
- Estado inicial correcto.
- Estado de pago correcto.
- WhatsApp abre al telefono del cliente.

### 2. Pedido solo pan

Validar:

- Aparece en dashboard.
- Total correcto.
- Fecha respeta 3 dias.
- Producto se lee claramente como pan de masa madre.
- WhatsApp de seguimiento funciona.

### 3. Pedido mixto pan + galletas

Validar:

- Aparece en dashboard.
- Total correcto.
- Fecha respeta 3 dias.
- Observacion o nota de entrega permite identificar si se pidio separado o junto.
- WhatsApp de seguimiento funciona.

### 4. Pago por transferencia

Validar:

- Metodo de pago: Transferencia bancaria.
- Estado de pago inicial: Pendiente de comprobante.
- Al confirmar pedido, el dashboard puede enviar datos de transferencia.
- Estado de pago se puede cambiar a Comprobante recibido o Pagado.

### 5. Pago al retirar

Validar:

- Metodo de pago: Pago al retirar.
- No exige comprobante.
- Se puede avanzar a Entregado con pago al retirar.

### 6. Pedido anulado

Validar:

- Se puede anular.
- No desaparece de la tabla.
- No suma ingreso activo.
- No suma pedido activo.
- Conserva motivo de anulacion en observacion interna.

## Mejoras recomendadas para dashboard

1. Mostrar origen del pedido cuando venga desde catalogo Supabase.
2. Agregar filtro rapido para pedidos Supabase.
3. Mostrar tipo de pedido: galletas, pan o mixto.
4. Mostrar nota de entrega/separacion cuando aplique.
5. Revisar que WhatsApp del dashboard use mensaje de negocio a cliente, distinto al mensaje del catalogo.
6. Mantener anulados como historial con ingreso considerado cero.

## Criterio de aprobado Fase 3

La fase se considera aprobada cuando:

- Los tres tipos de pedido se ven y gestionan correctamente.
- Los cambios de estado funcionan.
- Los cambios de pago funcionan.
- WhatsApp de seguimiento funciona.
- Anulacion descuenta ingresos y pedidos activos.
- No hay errores visuales graves en dashboard.

## Archivos relacionados

- `admin-dashboard.html`: dashboard operativo actual.
- `catalogo-supabase.html`: entrada limpia candidata.
- `catalogo-supabase-form-test.html`: flujo de catalogo Supabase.
- `catalogo-supabase-enviar-test.js`: flujo por secciones, envio y WhatsApp cliente a negocio.
