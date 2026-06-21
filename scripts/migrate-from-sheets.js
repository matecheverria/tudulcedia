#!/usr/bin/env node
/*
 * Tu Dulce Dia - Migracion desde Google Sheets exportado a CSV
 *
 * Uso:
 *   node scripts/migrate-from-sheets.js ./exports ./dist-migration
 *
 * Este script no se conecta a Supabase ni modifica produccion.
 * Solo transforma CSV locales a JSON normalizado para revision/importacion posterior.
 */

const fs = require('fs');
const path = require('path');

const INPUT_DIR = process.argv[2] || './exports';
const OUTPUT_DIR = process.argv[3] || './dist-migration';

const MONEY_RE = /[^0-9.-]/g;

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function readFileIfExists(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : '';
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = '';
  let inQuotes = false;

  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    const next = text[i + 1];

    if (c === '"' && inQuotes && next === '"') {
      value += '"';
      i++;
      continue;
    }

    if (c === '"') {
      inQuotes = !inQuotes;
      continue;
    }

    if (c === ',' && !inQuotes) {
      row.push(value);
      value = '';
      continue;
    }

    if ((c === '\n' || c === '\r') && !inQuotes) {
      if (c === '\r' && next === '\n') i++;
      row.push(value);
      if (row.some((x) => String(x).trim() !== '')) rows.push(row);
      row = [];
      value = '';
      continue;
    }

    value += c;
  }

  if (value || row.length) {
    row.push(value);
    if (row.some((x) => String(x).trim() !== '')) rows.push(row);
  }

  if (!rows.length) return [];
  const headers = rows[0].map((h) => normalizeHeader(h));
  return rows.slice(1).map((cells) => {
    const obj = {};
    headers.forEach((h, idx) => {
      obj[h] = clean(cells[idx] || '');
    });
    return obj;
  });
}

function clean(value) {
  return String(value == null ? '' : value).replace(/^\uFEFF/, '').trim();
}

function normalizeHeader(value) {
  return normalizeText(value)
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function normalizeText(value) {
  return clean(value)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function canonInsumo(value) {
  const n = normalizeText(value);
  if (!n) return '';
  if (n.includes('chip') && n.includes('blanco')) return 'chips de chocolate blanco';
  if (n.includes('chip')) return 'chips de chocolate';
  if (n.includes('harina') && (n.includes('fuerza') || n.includes('0000') || n.includes('pan'))) return 'harina de fuerza o 0000';
  if (n.includes('harina')) return 'harina sin polvos de hornear';
  if (n.includes('margarina')) return 'margarina';
  if (n.includes('huevo')) return 'huevos';
  if (n.includes('nuez')) return 'nueces';
  if (n.includes('cacao')) return 'cacao en polvo';
  if (n.includes('polvo')) return 'polvos de hornear';
  if (n.includes('bicarbonato')) return 'bicarbonato';
  if (n.includes('azucar')) return 'azúcar';
  if (n.includes('masa madre')) return 'masa madre';
  if (n.includes('agua')) return 'agua';
  if (n.includes('sal')) return 'sal';
  if (n.includes('bolsa')) return 'bolsas';
  if (n.includes('caja')) return 'cajas';
  if (n.includes('etiqueta')) return 'etiquetas';
  if (n.includes('gas')) return 'gas';
  if (n.includes('luz')) return 'luz';
  if (n.includes('delivery')) return 'delivery';
  return clean(value).toLowerCase();
}

function toNumber(value) {
  const raw = clean(value).replace(MONEY_RE, '');
  if (!raw) return 0;
  const n = Number(raw);
  return Number.isFinite(n) ? n : 0;
}

function toDate(value) {
  const v = clean(value);
  if (!v) return null;
  if (/^\d{4}-\d{2}-\d{2}/.test(v)) return v.slice(0, 10);
  const m = v.match(/^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})/);
  if (m) {
    const dd = m[1].padStart(2, '0');
    const mm = m[2].padStart(2, '0');
    const yyyy = m[3].length === 2 ? `20${m[3]}` : m[3];
    return `${yyyy}-${mm}-${dd}`;
  }
  return v;
}

function findCsvFile(candidates) {
  for (const name of candidates) {
    const full = path.join(INPUT_DIR, name);
    if (fs.existsSync(full)) return full;
  }
  return null;
}

function readCsv(candidates) {
  const file = findCsvFile(candidates);
  if (!file) return [];
  return parseCsv(readFileIfExists(file));
}

function transformProductos(rows) {
  return rows.map((r, idx) => {
    const nombre = r.nombre || r.producto || r.descripcion || '';
    return {
      codigo: r.id || r.codigo || `producto_${idx + 1}`,
      nombre,
      nombre_normalizado: normalizeText(nombre),
      categoria: normalizeText(r.categoria || '').includes('pan') ? 'pan' : normalizeText(r.categoria || '').includes('otro') ? 'otro' : 'galleta',
      precio: toNumber(r.precio || r.valor),
      activo: !['no', 'false', 'inactivo', '0'].includes(normalizeText(r.activo || r.disponible || 'si')),
      anticipacion_dias: toNumber(r.anticipaciondias || r.anticipacion_dias || 1) || 1,
      descripcion: r.descripcion || '',
      orden: toNumber(r.orden || idx + 1) || idx + 1,
    };
  }).filter((p) => p.nombre);
}

function splitProductosTexto(text) {
  const raw = clean(text);
  if (!raw) return [];
  return raw
    .split(/\n|;|\|/g)
    .map((x) => clean(x))
    .filter(Boolean)
    .map((line) => {
      const qtyMatch = line.match(/(?:x|×)\s*(\d+)/i) || line.match(/(\d+)\s*(?:un|unidad|unidades)/i);
      const cantidad = qtyMatch ? Number(qtyMatch[1]) : 1;
      return {
        nombre_snapshot: line.replace(/(?:x|×)\s*\d+/i, '').trim(),
        cantidad,
      };
    });
}

function transformPedidos(rows) {
  const clientesByPhone = new Map();
  const pedidos = [];
  const items = [];

  rows.forEach((r, idx) => {
    const folio = r.foliopedido || r.folio_pedido || r.folio || r.numero_pedido || `MIG-${String(idx + 1).padStart(5, '0')}`;
    const nombre = r.nombrecliente || r.nombre_cliente || r.cliente || r.nombre || 'Cliente sin nombre';
    const telefono = r.telefonocliente || r.telefono_cliente || r.telefono || '';
    const phoneKey = normalizeText(telefono || nombre);
    if (!clientesByPhone.has(phoneKey)) {
      clientesByPhone.set(phoneKey, {
        nombre,
        telefono,
        telefono_normalizado: telefono.replace(/[^0-9+]/g, ''),
      });
    }

    const total = toNumber(r.totalestimado || r.total_estimado || r.total || r.monto);
    const estado = r.estado || 'Pendiente';
    const isCancelado = normalizeText(estado).includes('cancel') || normalizeText(estado).includes('anulad');

    pedidos.push({
      folio,
      cliente_nombre: nombre,
      cliente_telefono: telefono,
      fecha_solicitada: toDate(r.fechasolicitada || r.fecha_solicitada || r.fecha || r.fecha_entrega),
      metodo_pago: r.metodopago || r.metodo_pago || 'Transferencia bancaria',
      estado: isCancelado ? 'Cancelado' : estado,
      estado_pago: r.estadopago || r.estado_pago || 'Pendiente de comprobante',
      total_estimado: isCancelado ? 0 : total,
      observacion: r.observacion || r.obs || '',
      observacion_interna: r.observacioninterna || r.observacion_interna || '',
      origen: r.origen || 'Migracion Google Sheets',
    });

    const productosTexto = r.productostexto || r.productos_texto || r.productos || r.detalle || '';
    splitProductosTexto(productosTexto).forEach((item) => {
      items.push({
        folio,
        nombre_snapshot: item.nombre_snapshot,
        cantidad: item.cantidad,
        precio_snapshot: 0,
        subtotal: 0,
        requiere_revision: true,
      });
    });
  });

  return {
    clientes: Array.from(clientesByPhone.values()),
    pedidos,
    pedido_items: items,
  };
}

function transformCompras(rows) {
  return rows.map((r) => {
    const contenido = toNumber(r.contenidoporenvase || r.contenido_por_envase || r.contenido);
    const envases = toNumber(r.envasescomprados || r.envases_comprados || r.envases);
    const costoEnvase = toNumber(r.costoporenvase || r.costo_por_envase || r.costo_envase);
    const cantidadTotal = toNumber(r.cantidadtotal || r.cantidad_total) || contenido * envases;
    const costoTotal = toNumber(r.costototal || r.costo_total) || costoEnvase * envases;
    return {
      fecha: toDate(r.fecha),
      categoria: r.categoria || 'Materia prima',
      insumo_original: r.insumo || r.item || r.material || '',
      insumo_normalizado: canonInsumo(r.insumo || r.item || r.material || ''),
      unidad_stock: r.unidadstock || r.unidad_stock || r.unidad || 'g',
      contenido_por_envase: contenido,
      envases_comprados: envases,
      costo_por_envase: costoEnvase,
      cantidad_total: cantidadTotal,
      costo_total: costoTotal,
      costo_base: cantidadTotal > 0 ? costoTotal / cantidadTotal : null,
      proveedor: r.proveedor || '',
      estado: r.estado || 'Disponible',
      observacion: r.observacion || r.obs || '',
    };
  }).filter((x) => x.insumo_original || x.insumo_normalizado);
}

function writeJson(name, data) {
  const out = path.join(OUTPUT_DIR, name);
  fs.writeFileSync(out, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
  console.log(`OK ${out} (${Array.isArray(data) ? data.length : Object.keys(data).length})`);
}

function main() {
  ensureDir(OUTPUT_DIR);

  const productosRows = readCsv(['Productos.csv', 'productos.csv', 'Catalogo.csv', 'catalogo.csv']);
  const pedidosRows = readCsv(['Pedidos.csv', 'pedidos.csv']);
  const comprasRows = readCsv(['Compras.csv', 'compras.csv', 'Insumos.csv', 'insumos.csv', 'Compras_Insumos.csv']);

  const productos = transformProductos(productosRows);
  const pedidoData = transformPedidos(pedidosRows);
  const compras = transformCompras(comprasRows);

  writeJson('productos.json', productos);
  writeJson('clientes.json', pedidoData.clientes);
  writeJson('pedidos.json', pedidoData.pedidos);
  writeJson('pedido_items.json', pedidoData.pedido_items);
  writeJson('compras_insumos.json', compras);

  const report = {
    inputDir: INPUT_DIR,
    outputDir: OUTPUT_DIR,
    counts: {
      productos: productos.length,
      clientes: pedidoData.clientes.length,
      pedidos: pedidoData.pedidos.length,
      pedido_items: pedidoData.pedido_items.length,
      compras_insumos: compras.length,
    },
    warnings: [
      'Revisar pedido_items con requiere_revision=true: el CSV puede traer productos como texto sin precio unitario.',
      'Validar folios duplicados antes de importar.',
      'Validar pedidos cancelados/anulados como total_estimado 0.',
      'Validar unidades de compras: usar g/ml/unidad/pack/servicio como base operativa.',
    ],
  };
  writeJson('migration-report.json', report);
}

main();
