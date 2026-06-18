# Tu Dulce Día — Resumen final de producción y recuperación

Fecha de cierre operativo: 2026-06-18
Estado: producción controlada lista para operar

## 1. Links oficiales limpios

Usar estos links para operación normal. No publicar links con `?v=`.

- Catálogo público para clientes: https://tudulcediacl-gh.github.io/tudulcedia/
- Panel privado principal: https://tudulcediacl-gh.github.io/tudulcedia/panel-td-privado-2026.html
- Dashboard de pedidos: https://tudulcediacl-gh.github.io/tudulcedia/admin-dashboard.html
- Administrador de catálogo: https://tudulcediacl-gh.github.io/tudulcedia/admin-catalogo.html

El link que se comparte con clientes, en WhatsApp, flyers, fotos o redes sociales es solo:

https://tudulcediacl-gh.github.io/tudulcedia/

Los links con `?v=...` son solo para pruebas de caché después de publicar cambios.

## 2. Número operativo WhatsApp

Número operativo actualizado por bloqueo del número anterior:

`+56 9 3021 0411`

Formato técnico para links WhatsApp:

`56930210411`

El catálogo público ya reemplaza los números anteriores y el botón final de WhatsApp apunta a este número.

## 3. Repositorio y respaldo GitHub

Repositorio:

`tudulcediacl-gh/tudulcedia`

Rama principal productiva:

`main`

Rama de respaldo de producción creada:

`backup/produccion-final-tu-dulce-dia-2026-06-18`

Esta rama se creó desde `main` cuando el sistema ya tenía los cambios de producción. Sirve como punto de recuperación si se rompe el sitio o se necesita volver a una versión estable. Si hay cambios posteriores importantes, crear una nueva rama backup desde `main`.

## 4. Archivos principales

- `index.html`: entrada pública del catálogo. Carga `catalogo-dinamico-v8.html`, aplica correcciones visuales, corrige links/contactos, registra pedidos por JSONP y muestra la pantalla final.
- `catalogo-dinamico-v8.html`: base visual del catálogo y formulario.
- `admin-dashboard.html`: dashboard operativo de pedidos, filtros, estados, pagos, WhatsApp y exportación CSV.
- `admin-catalogo.html`: administración de productos y disponibilidad.
- `panel-td-privado-2026.html`: panel privado de accesos administrativos.

## 5. Backend activo Apps Script

Web App activo:

`https://script.google.com/macros/s/AKfycbzmPICimq95KQ4GLloWbgeoonhTWBjzUM7J7kMbz32r9qiooqzC_MY4e2IADroA8Rnl/exec`

Este es el endpoint formal que debe usarse. El sistema público y admin ya apuntan a este Web App.

Funciones principales esperadas:

- `catalogoPublico`
- `registrarPedido`
- `adminListarPedidos`
- `adminActualizarPedido`
- `adminListarCatalogo`
- `adminGuardarProducto`
- `adminGuardarDisponibilidad`

No usar como endpoint productivo el Web App antiguo `AKfycby92...`, porque fue identificado como implementación equivocada para el flujo formal.

## 6. Google Sheets

Spreadsheet operativo:

`Tu Dulce Día - Pedidos`

ID interno de referencia:

`1t5AAjWH1Vudf53flzfoByCMGqvDbWlBEzfVApSoWrTw`

Hojas conocidas:

- `Pedidos`
- `Productos`
- `Disponibilidad`
- `Historial pedidos`
- `Configuracion` (oculta)

Por seguridad, este documento no registra claves admin ni datos bancarios completos. Esos datos deben permanecer protegidos en Apps Script/Google Sheets y no publicarse en el repositorio público.

## 7. Flujo cliente validado

Estado validado:

Cliente hace pedido → Apps Script registra pedido → se genera folio real TD-00XX → el cliente ve el folio en la pantalla final → el cliente inicia WhatsApp desde el botón final → el mensaje de WhatsApp incluye el folio → el pedido aparece en el dashboard admin.

Pruebas reales observadas:

- El flujo mostró folios reales como `TD-0021`, `TD-0024`, `TD-0025`.
- WhatsApp del cliente y dashboard admin recibieron el mismo folio.
- El botón de envío queda bloqueado para evitar pedidos duplicados.

## 8. Cambios finales realizados

### Catálogo público

- Conectado al Apps Script correcto.
- Registro de pedido por JSONP para leer respuesta real del backend.
- Folio real visible en pantalla final.
- WhatsApp final con folio real.
- Número operativo cambiado a `+56 9 3021 0411`.
- Se agregó botón `← Volver al catálogo` en la pantalla de `Pedido enviado`.
- Se convirtió el código de país/área del teléfono en lista desplegable.
- Chile `+56` queda como opción por defecto.
- Se agregó consentimiento obligatorio de contacto por WhatsApp antes de enviar el pedido.
- La pantalla final incentiva que el cliente inicie WhatsApp para confirmar disponibilidad, pago y coordinación.
- El botón final dice `Enviar confirmación por WhatsApp`.

Opciones del selector de país:

- Chile +56
- Argentina +54
- Perú +51
- Colombia +57
- Venezuela +58
- Brasil +55
- Bolivia +591
- Uruguay +598
- Paraguay +595
- Ecuador +593
- México +52
- EE.UU./Canadá +1
- España +34

### Dashboard admin

- Filtros corregidos y mejorados.
- Búsqueda por folio, cliente, teléfono, producto, estado, pago, método y observaciones.
- Filtros por método, estado del pedido y estado de pago.
- Orden por recientes, antiguos, mayor total y menor total.
- Mensajes WhatsApp por estado.
- Emojis corregidos mediante URL Encode y `api.whatsapp.com` para evitar caracteres dañados.
- Dashboard conectado al Apps Script correcto.

Regla operativa anti-bloqueo:

Usar WhatsApp desde el dashboard solo si el cliente ya inició conversación por WhatsApp o espera explícitamente ese seguimiento. Para pedidos nuevos, priorizar que el cliente presione el botón final del catálogo e inicie la conversación.

## 9. Medidas anti-bloqueo WhatsApp aplicadas

- El cliente inicia el WhatsApp desde la pantalla final.
- Se agregó consentimiento explícito de contacto por WhatsApp en el formulario.
- Se cambió el número bloqueado por el nuevo número operativo.
- Se reforzó que el WhatsApp sea para confirmar disponibilidad, pago y coordinación del pedido.

Medidas operativas recomendadas:

- No iniciar chats fríos desde el negocio.
- No enviar mensajes masivos repetidos.
- Reducir mensajes por pedido a máximo 2 o 3.
- Responder preferentemente dentro de conversaciones iniciadas por el cliente.
- Pausar envíos proactivos si WhatsApp vuelve a mostrar advertencias.

## 10. Mensajes WhatsApp por estado

Los mensajes se generan desde `admin-dashboard.html`, no desde Apps Script.

Estados cubiertos:

- `Pendiente`: confirma recepción y revisión de disponibilidad.
- `Confirmado`: informa que el pedido fue confirmado.
- `En preparación`: informa que el pedido se está preparando.
- `Listo para retiro/entrega`: informa que el pedido está listo y será entregado hoy.
- `Entregado`: agradece con nombre del cliente y confirma entrega.
- `Cancelado`: informa cancelación con tono amable.
- Fallback: mensaje genérico si el estado no coincide.

Los emojis se usan con URL Encode:

- Cara sonriente: `%F0%9F%98%8A`
- Galleta: `%F0%9F%8D%AA`
- Pan: `%F0%9F%A5%96`
- Destellos: `%E2%9C%A8`
- Nota: `%F0%9F%93%9D`
- Corazón amarillo: `%F0%9F%92%9B`
- Check: `%E2%9C%85`
- Cocinera: `%F0%9F%91%A9%E2%80%8D%F0%9F%8D%B3`
- Cara radiante: `%F0%9F%98%81`
- Camión: `%F0%9F%9A%9A`

## 11. Commits importantes de producción

- Flujo cliente con folio real: `b567c6d5646bf2ff618525ce7cc53caf02dd1756`
- Filtros dashboard admin: `4febc9b36e09a774ef09c37b6cab810168d8e382`
- Mensajes WhatsApp por estado y emojis: `7c41f128ac1ea58d3dd8507419f4452552d8986a`
- Botón volver al catálogo en pantalla final: `6122bc931a5cf5b6a1c9869d0b1d08d91c6d0ec4`
- Selector de código país/área en catálogo: `d67df06de444f76d93b2de613301959b564441f3`
- Consentimiento WhatsApp, nuevo número y flujo cliente inicia WhatsApp: `427c549f6d01b837ff7176bd179c57d6aba4a603`

## 12. Procedimiento de recuperación rápida

Si algo falla en producción:

1. No modificar Apps Script ni Google Sheets de inmediato.
2. Verificar si el error está en cliente público, dashboard o backend.
3. Probar links limpios y luego link con `?v=emergencia` para descartar caché.
4. Revisar en GitHub los archivos:
   - `index.html`
   - `admin-dashboard.html`
   - `catalogo-dinamico-v8.html`
5. Si el sitio se rompe, recuperar desde la rama:
   - `backup/produccion-final-tu-dulce-dia-2026-06-18`
6. Comparar la rama backup contra `main`.
7. Restaurar el archivo afectado, no todo el proyecto, salvo emergencia mayor.
8. Después de restaurar, probar:
   - pedido cliente con folio real
   - WhatsApp cliente al nuevo número
   - aparición en dashboard admin
   - filtros admin
   - WhatsApp admin por estado

## 13. Reglas para cambios futuros

- No tocar folios si el pedido se registra correctamente.
- No tocar Apps Script si el error está en visual o frontend.
- No tocar Google Sheets si el error está en GitHub Pages.
- No publicar links con `?v=`.
- Hacer cambios pequeños y verificables.
- Después de cada cambio en GitHub, probar con un parámetro temporal `?v=commit` y luego volver a usar el link limpio.
- Evitar automatizar mensajes masivos de WhatsApp desde el número del negocio.

## 14. Estado final

El sistema queda documentado, con links finales limpios, backend identificado, nuevo número WhatsApp operativo, ramas y archivos clave definidos, medidas anti-bloqueo aplicadas en el catálogo público y un punto de recuperación en GitHub para emergencia.
