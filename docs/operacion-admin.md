# Operación Admin — Tu Dulcedía

## URLs

- Centro admin: `admin.html`
- Dashboard operativo: `admin-dashboard.html`
- Admin catálogo: `admin-catalogo.html`
- Catálogo dinámico: `catalogo-dinamico.html`
- Catálogo actual: `index.html`

## Deploy Apps Script

Cada paquete grande de cambios requiere un solo ciclo:

1. GitHub → Actions → Deploy Apps Script → Run workflow.
2. Esperar que quede verde.
3. Apps Script → Implementar → Gestionar implementaciones.
4. Lápiz de la implementación Web App actual.
5. Versión → Nueva versión.
6. Implementar.
7. Ejecutar funciones de migración si corresponde.

## Migraciones disponibles

- `migrarHojaPedidos`: asegura columnas operativas e historial.
- `reordenarHojaPedidos`: ordena columnas de Pedidos.
- `migrarHojasCatalogo`: crea y prepara Productos y Disponibilidad.

## Prueba mínima después de deploy

1. Abrir `admin-dashboard.html`.
2. Cambiar un pedido de prueba a Pagado pendiente entrega.
3. Confirmar en Sheets que se llena Estado operativo y fechas.
4. Abrir `admin-catalogo.html`.
5. Editar precio o estado Activo de un producto de prueba.
6. Abrir `catalogo-dinamico.html`.
7. Confirmar que el producto refleja el cambio.
8. Enviar un pedido de prueba y revisar que llegue a Pedidos.

## Reglas prácticas

- No publicar claves ni datos bancarios en GitHub Pages.
- Mantener `ADMIN_TOKEN` solo en Propiedades de Apps Script.
- Usar el catálogo dinámico en paralelo hasta validar bien la operación.
- Cuando el catálogo dinámico esté validado, reemplazar `index.html` o redirigirlo.
