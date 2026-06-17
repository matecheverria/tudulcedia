/**
 * Migraciones operativas para la hoja de pedidos.
 * Estas funciones no borran pedidos: reordenan columnas preservando datos por encabezado.
 */

function reordenarHojaPedidos() {
  const libro = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
  const hoja = obtenerHojaPedidos_(libro);
  reordenarColumnasPedidos_(hoja);
  hoja.setFrozenRows(1);
  hoja.setFrozenColumns(1);
  hoja.autoResizeColumns(1, hoja.getLastColumn());
  return "Hoja Pedidos reordenada correctamente. Folio pedido quedó como primera columna.";
}

function reordenarColumnasPedidos_(hoja) {
  const ultimaFila = Math.max(hoja.getLastRow(), 1);
  const ultimaColumna = Math.max(hoja.getLastColumn(), 1);
  const rango = hoja.getRange(1, 1, ultimaFila, ultimaColumna);
  const valores = rango.getValues();
  const encabezadosActuales = valores[0].map(function(valor) {
    return String(valor || "").trim();
  });

  const extras = encabezadosActuales.filter(function(nombre) {
    return nombre && COLUMNAS.indexOf(nombre) === -1;
  });

  const encabezadosFinales = COLUMNAS.concat(extras);
  const indiceActual = {};
  encabezadosActuales.forEach(function(nombre, indice) {
    if (nombre) indiceActual[nombre] = indice;
  });

  const nuevosValores = [];
  nuevosValores.push(encabezadosFinales);

  for (let fila = 1; fila < valores.length; fila++) {
    const filaActual = valores[fila];
    const filaNueva = encabezadosFinales.map(function(nombreColumna) {
      const indice = indiceActual[nombreColumna];
      return indice === undefined ? "" : filaActual[indice];
    });
    nuevosValores.push(filaNueva);
  }

  hoja.clearContents();
  hoja.getRange(1, 1, nuevosValores.length, encabezadosFinales.length).setValues(nuevosValores);
  hoja.setFrozenRows(1);
  hoja.setFrozenColumns(1);
}
