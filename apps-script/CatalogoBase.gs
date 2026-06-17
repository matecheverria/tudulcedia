/** Base FASE 3: hojas Productos y Disponibilidad. */

const NOMBRE_HOJA_PRODUCTOS = "Productos";
const NOMBRE_HOJA_DISPONIBILIDAD = "Disponibilidad";

const COLUMNAS_PRODUCTOS = [
  "ID",
  "Nombre",
  "Categoría",
  "Precio",
  "Activo",
  "Anticipación días",
  "Descripción",
  "Orden"
];

const COLUMNAS_DISPONIBILIDAD = [
  "Fecha",
  "Estado",
  "Cupo máximo",
  "Nota"
];

function migrarHojasCatalogo() {
  const libro = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
  const hojaProductos = obtenerHojaCatalogo_(libro, NOMBRE_HOJA_PRODUCTOS, COLUMNAS_PRODUCTOS);
  const hojaDisponibilidad = obtenerHojaCatalogo_(libro, NOMBRE_HOJA_DISPONIBILIDAD, COLUMNAS_DISPONIBILIDAD);
  hojaProductos.setFrozenRows(1);
  hojaDisponibilidad.setFrozenRows(1);
  hojaProductos.autoResizeColumns(1, hojaProductos.getLastColumn());
  hojaDisponibilidad.autoResizeColumns(1, hojaDisponibilidad.getLastColumn());
  return "Hojas Productos y Disponibilidad preparadas correctamente.";
}

function obtenerHojaCatalogo_(libro, nombreHoja, columnas) {
  let hoja = libro.getSheetByName(nombreHoja);
  if (!hoja) hoja = libro.insertSheet(nombreHoja);
  asegurarColumnasCatalogo_(hoja, columnas);
  return hoja;
}

function asegurarColumnasCatalogo_(hoja, columnas) {
  if (hoja.getLastRow() === 0) {
    hoja.getRange(1, 1, 1, columnas.length).setValues([columnas]);
    hoja.setFrozenRows(1);
    return;
  }

  const actuales = hoja.getRange(1, 1, 1, Math.max(hoja.getLastColumn(), 1)).getValues()[0]
    .map(function(valor) { return String(valor || "").trim(); });

  const faltantes = columnas.filter(function(columna) {
    return actuales.indexOf(columna) === -1;
  });

  if (faltantes.length) {
    hoja.getRange(1, hoja.getLastColumn() + 1, 1, faltantes.length).setValues([faltantes]);
  }
}
