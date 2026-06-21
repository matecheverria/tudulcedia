# Apps Script - Campos Fase 3 Supabase

## Objetivo

Asegurar que los pedidos creados desde el catalogo Supabase guarden estos campos operativos en Google Sheets y puedan ser mostrados luego en el dashboard:

- `origen`
- `tipoPedido`
- `notaEntrega`
- `entregaSeparada`

## Estado actual frontend

El flujo `catalogo-supabase-form-test.html` / `catalogo-supabase-enviar-test.js` ya envia datos suficientes en el payload:

- `origen`: actualmente como `Catálogo Supabase controlado` o equivalente.
- `notaEntrega`: tipo de pedido generado por la regla: galletas, pan o mixto.
- `entregaSeparada`: booleano para pedido mixto.
- `productosSeleccionados`: permite derivar tipo de pedido si falta `tipoPedido`.

## Cambio requerido en Apps Script

En la funcion que registra pedidos, normalmente `registrarPedido`, despues de parsear el payload, agregar una normalizacion como esta:

```javascript
function detectarTipoPedido_(payload) {
  var texto = '';
  try {
    texto += ' ' + (payload.notaEntrega || '');
    texto += ' ' + (payload.observacion || '');
    texto += ' ' + JSON.stringify(payload.productosSeleccionados || []);
  } catch (e) {}

  texto = String(texto).toLowerCase();
  var tienePan = texto.indexOf('pan') >= 0 || texto.indexOf('masa madre') >= 0;
  var tieneGalleta = texto.indexOf('galleta') >= 0 || texto.indexOf('gall') >= 0;

  if (tienePan && tieneGalleta) return 'Mixto';
  if (tienePan) return 'Pan';
  if (tieneGalleta) return 'Galletas';
  return 'Otro';
}

function normalizarCamposFase3_(payload) {
  payload = payload || {};
  var origen = payload.origen || 'Catálogo actual';
  var tipoPedido = payload.tipoPedido || detectarTipoPedido_(payload);
  var notaEntrega = payload.notaEntrega || tipoPedido;
  var entregaSeparada = payload.entregaSeparada === true || String(payload.entregaSeparada).toLowerCase() === 'true';

  return {
    origen: origen,
    tipoPedido: tipoPedido,
    notaEntrega: notaEntrega,
    entregaSeparada: entregaSeparada ? 'Sí' : 'No'
  };
}
```

Luego, dentro de `registrarPedido`, antes de escribir la fila:

```javascript
var fase3 = normalizarCamposFase3_(payload);
```

Y al guardar la fila en la hoja `Pedidos`, incluir columnas nuevas si existen:

```javascript
origen: fase3.origen
tipoPedido: fase3.tipoPedido
notaEntrega: fase3.notaEntrega
entregaSeparada: fase3.entregaSeparada
```

## Columnas recomendadas en hoja Pedidos

Agregar al final de la hoja, para no romper columnas existentes:

1. `origen`
2. `tipoPedido`
3. `notaEntrega`
4. `entregaSeparada`

## Importante

- No reemplazar columnas existentes.
- No mover columnas actuales.
- Agregar estas columnas al final.
- Mantener compatibilidad con pedidos antiguos.
- Si un pedido antiguo no tiene estos campos, el dashboard debe derivar tipo por productos y marcar origen como `Actual/otro`.

## Validacion despues del cambio

Crear 3 pedidos nuevos desde `catalogo-supabase.html`:

1. Solo galletas: debe guardar `tipoPedido = Galletas`.
2. Solo pan: debe guardar `tipoPedido = Pan`.
3. Mixto: debe guardar `tipoPedido = Mixto` y `entregaSeparada` segun seleccion.
