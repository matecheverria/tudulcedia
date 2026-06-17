# Tu Dulcedía — MVP catálogo web

Sistema liviano para tomar pedidos de galletas artesanales y pan de masa madre usando GitHub Pages, Google Apps Script y Google Sheets.

## URLs principales

```text
Catálogo actual:
https://matecheverria.github.io/tudulcedia/

Catálogo dinámico en prueba:
https://matecheverria.github.io/tudulcedia/catalogo-dinamico.html

Dashboard operativo:
https://matecheverria.github.io/tudulcedia/admin-dashboard.html

Admin catálogo y disponibilidad:
https://matecheverria.github.io/tudulcedia/admin-catalogo.html
```

## Arquitectura

- Frontend público en GitHub Pages.
- Backend en Google Apps Script desplegado como Web App.
- Base operativa en Google Sheets.
- Deploy de Apps Script desde GitHub Actions con `clasp push --force`.

## Hojas usadas

```text
Pedidos
Historial pedidos
Productos
Disponibilidad
```

## Apps Script: funciones manuales importantes

Ejecutar después de grandes cambios:

```text
migrarHojaPedidos
reordenarHojaPedidos
migrarHojasCatalogo
```

## Pedidos

La hoja `Pedidos` contiene folio, estados, teléfono, datos del cliente, productos, total, método de pago, fechas de control y JSON completo.

Campos principales:

```text
Folio pedido
Estado
Estado de pago
Estado operativo
Teléfono
Nombre cliente
Fecha solicitada
Productos seleccionados
Total estimado
Método de pago
Observación interna
Fecha confirmado
Fecha pagado
Fecha entregado
Detalle JSON
```

## Historial

La hoja `Historial pedidos` registra cambios hechos desde el dashboard:

```text
Fecha/hora cambio
Folio pedido
Campo
Valor anterior
Valor nuevo
Origen
Observación interna
```

## Productos

La hoja `Productos` permite administrar el catálogo dinámico:

```text
ID
Nombre
Categoría
Precio
Activo
Anticipación días
Descripción
Orden
```

- `Activo = Sí`: aparece en el catálogo dinámico.
- `Activo = No`: queda oculto.
- `Anticipación días`: controla fecha mínima del pedido.
- `Orden`: controla el orden visual.

## Disponibilidad

La hoja `Disponibilidad` permite bloquear o limitar fechas:

```text
Fecha
Estado
Cupo máximo
Nota
```

Estados sugeridos:

```text
Abierto
Cerrado
Bloqueado
```

El catálogo dinámico bloquea fechas cuyo estado no sea `Abierto`.

## Flujo de deploy

Cada vez que se edita Apps Script desde GitHub:

```text
1. GitHub → Actions → Deploy Apps Script → Run workflow
2. Esperar verde
3. Apps Script → Implementar → Gestionar implementaciones
4. Lápiz de la Web App actual
5. Versión: Nueva versión
6. Implementar
7. Ejecutar migraciones si corresponde
```

## Seguridad

- No publicar claves ni datos bancarios en el frontend.
- `ADMIN_TOKEN` vive en Propiedades de secuencia de comandos de Apps Script.
- La clave admin se guarda solo en `sessionStorage` del navegador.
- Los datos de transferencia se envían manualmente por WhatsApp después de confirmar disponibilidad.

## Estado de fases

```text
FASE 1: Operación pedidos básica — completada
FASE 2: Dashboard, trazabilidad y fechas — completada funcionalmente
FASE 3: Productos y disponibilidad desde Sheets — base implementada
FASE 4: Deploy con GitHub Actions — operativo, con mejora futura para despliegue automático de versión
```

## Próximas mejoras

- Reemplazar el catálogo principal por `catalogo-dinamico.html` cuando esté validado.
- Agregar cupos reales por fecha usando pedidos ya tomados.
- Agregar pantalla de calendario operativo.
- Automatizar completamente nueva versión de Web App si se configura un deployment ID compatible con `clasp deploy`.
