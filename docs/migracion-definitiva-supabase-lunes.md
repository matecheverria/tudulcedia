# Migracion definitiva a Supabase antes del lunes

## Objetivo

Reducir la dependencia de Google Sheets antes de que empiecen nuevos pedidos el lunes.

La meta no es apagar Sheets de golpe, sino dejar preparada una migracion segura:

1. Catalogo desde Supabase.
2. Pedidos nuevos guardados en Supabase.
3. Dashboard leyendo Supabase.
4. Sheets como respaldo temporal/exportacion.

## Estado actual

### Ya esta listo

- Esquema Supabase creado.
- Productos activos en Supabase.
- Historico importado.
- Catalogo candidato leyendo productos desde Supabase.
- Flujo visual del catalogo separado en 3 pasos.
- Pedidos actuales siguen llegando a Google Sheets.
- Hoja Pedidos ya tiene columnas utiles:
  - Origen.
  - Indicacion de pago.
  - Detalle JSON.
- Detalle JSON ya contiene informacion operativa relevante:
  - productosSeleccionados.
  - entregaSeparada.
  - notaEntrega.
  - anticipacionDiasMinima.
  - origen.
  - tipoEntrega.

### Aun pendiente

- Guardar pedidos nuevos directamente en Supabase.
- Crear dashboard Supabase real.
- Actualizar estado de pedido y pago en Supabase.
- Mantener Sheets como respaldo, no como fuente principal.

## Decisión técnica

Google Sheets debe pasar a segundo plano.

Nuevo flujo recomendado:

```text
Catalogo Supabase
  -> crea pedido en Supabase
  -> muestra folio Supabase
  -> abre WhatsApp cliente -> negocio
  -> dashboard Supabase gestiona estado/pago
  -> exportacion opcional a Sheets
```

## Fase A - Preparar pedidos Supabase

Crear una funcion RPC o endpoint seguro para registrar pedidos.

Debe insertar en:

- `clientes`
- `pedidos`
- `pedido_items`

Campos minimos requeridos en `pedidos`:

- folio
- cliente_nombre
- cliente_telefono
- fecha_solicitada
- metodo_pago
- requiere_datos_transferencia
- entrega_separada
- nota_entrega
- estado
- estado_pago
- total_estimado
- observacion
- origen
- whatsapp_mensaje

Campos minimos requeridos en `pedido_items`:

- pedido_id
- producto_id
- producto_codigo_snapshot
- nombre_snapshot
- categoria_snapshot
- precio_snapshot
- cantidad
- subtotal

## Fase B - Catalogo escribe en Supabase

Modificar la version candidata del catalogo para que:

1. Lea productos desde Supabase.
2. Valide anticipacion.
3. Guarde pedido en Supabase.
4. Si falla Supabase, opcionalmente use Apps Script como respaldo temporal.
5. Muestre folio Supabase.
6. Envie WhatsApp al negocio.

Durante transicion:

```text
Modo seguro = guardar en Supabase + fallback Sheets
Modo final = guardar solo en Supabase
```

## Fase C - Dashboard Supabase

Crear version paralela:

- `admin-dashboard-supabase.html`

Debe permitir:

- Ver pedidos.
- Filtrar por estado.
- Filtrar por pago.
- Filtrar por tipo: galletas, pan, mixto.
- Filtrar por origen.
- Editar estado.
- Editar estado de pago.
- Anular pedido.
- Ver nota de entrega.
- Ver productos.
- Abrir WhatsApp de seguimiento.

No reemplazar dashboard actual hasta validar.

## Fase D - Corte controlado

Cuando el catalogo y dashboard Supabase esten validados:

1. Crear backup de `index.html`.
2. Reemplazar `index.html` por catalogo Supabase.
3. Mantener dashboard antiguo como emergencia.
4. Publicar dashboard Supabase como principal.
5. Mantener Sheets solo como exportacion.

## Rollback

Si algo falla:

1. Restaurar `index.html` desde backup.
2. Volver temporalmente al flujo Apps Script + Sheets.
3. Mantener pedidos Supabase creados como historico.

## Prioridad antes del lunes

### Imprescindible

- Crear guardado de pedidos en Supabase.
- Crear dashboard Supabase minimo.
- Probar 3 pedidos reales:
  - galletas.
  - pan.
  - mixto.

### Deseable

- Exportar pedidos Supabase a CSV.
- Boton de emergencia para registrar tambien en Sheets.
- Vista de ingresos activos desde Supabase.

### No hacer antes del lunes si no alcanza

- Apagar Google Sheets completamente.
- Migrar inventario completo a interfaz nueva.
- Rehacer todo el panel privado.
- Cambiar reglas de negocio no urgentes.

## Riesgo principal

El mayor riesgo es cortar `index.html` antes de validar que los pedidos Supabase se guardan, se ven en dashboard y se pueden gestionar.

Por eso la migracion debe hacerse en paralelo primero.

## Checklist de salida

Antes de publicar definitivo:

- [ ] Pedido galletas guardado en Supabase.
- [ ] Pedido pan guardado en Supabase.
- [ ] Pedido mixto guardado en Supabase.
- [ ] Dashboard Supabase muestra los 3 pedidos.
- [ ] Cambio de estado funciona.
- [ ] Cambio de pago funciona.
- [ ] Pedido anulado no suma ingreso activo.
- [ ] WhatsApp cliente -> negocio funciona desde catalogo.
- [ ] WhatsApp negocio -> cliente funciona desde dashboard.
- [ ] Backup de `index.html` creado.
- [ ] Rollback probado o claramente documentado.
