-- Tu Dulce Dia - Actualizacion incremental de insumos y recetas
-- Fecha: 2026-06-21
-- Fuente: Google Sheets actual, pestañas Insumos, Recetas y RecetaIngredientes.
-- Ejecutar despues de:
--   1. database/schema.sql
--   2. database/seed.sql
--
-- Objetivo:
-- - Agregar insumos nuevos, especialmente Almendras.
-- - Agregar recetas nuevas con almendras y chips de chocolate blanco.
-- - Reinsertar ingredientes de recetas actuales sin tocar pedidos.

begin;

-- =========================
-- Insumos actuales
-- =========================

insert into public.insumos (nombre, nombre_normalizado, categoria, unidad_base, activo)
values
  ('Chips de chocolate', public.td_normalize('Chips de chocolate'), 'Materia prima', 'g', true),
  ('Chips de chocolate blanco', public.td_normalize('Chips de chocolate blanco'), 'Materia prima', 'g', true),
  ('Nueces', public.td_normalize('Nueces'), 'Materia prima', 'g', true),
  ('Almendras', public.td_normalize('Almendras'), 'Materia prima', 'g', true),
  ('Sal', public.td_normalize('Sal'), 'Materia prima', 'g', true),
  ('Cacao en polvo', public.td_normalize('Cacao en polvo'), 'Materia prima', 'g', true),
  ('Bicarbonato', public.td_normalize('Bicarbonato'), 'Materia prima', 'g', true),
  ('Polvos de hornear', public.td_normalize('Polvos de hornear'), 'Materia prima', 'g', true),
  ('Azúcar', public.td_normalize('Azúcar'), 'Materia prima', 'g', true),
  ('Huevos', public.td_normalize('Huevos'), 'Materia prima', 'unidad', true),
  ('Margarina', public.td_normalize('Margarina'), 'Materia prima', 'g', true),
  ('Harina sin polvos de hornear', public.td_normalize('Harina sin polvos de hornear'), 'Materia prima', 'g', true),
  ('Harina de fuerza o 0000', public.td_normalize('Harina de fuerza o 0000'), 'Materia prima', 'g', true),
  ('Agua', public.td_normalize('Agua'), 'Materia prima', 'ml', true),
  ('Masa madre', public.td_normalize('Masa madre'), 'Materia prima', 'g', true)
on conflict (nombre) do update set
  nombre_normalizado = excluded.nombre_normalizado,
  categoria = excluded.categoria,
  unidad_base = excluded.unidad_base,
  activo = excluded.activo,
  actualizado_en = now();

-- =========================
-- Recetas actuales
-- =========================

insert into public.recetas (producto_id, producto_nombre, producto_nombre_normalizado, rendimiento, unidad_salida, activo)
select p.id, v.producto_nombre, public.td_normalize(v.producto_nombre), v.rendimiento, v.unidad_salida, true
from (
  values
    ('Pan masa madre 1 kg aprox.', 2::numeric, 'panes'),
    ('Galleta vainilla nueces', 40::numeric, 'unidades'),
    ('Galleta de vainilla con almendras', 40::numeric, 'unidades'),
    ('Galleta de vainilla con chips', 40::numeric, 'unidades'),
    ('Galleta vainilla chips y nueces', 40::numeric, 'unidades'),
    ('Galleta chocolate chips y nueces', 40::numeric, 'unidades'),
    ('Galleta chocolate y almendras', 40::numeric, 'unidades'),
    ('Galleta de vainillia chips y almendras', 40::numeric, 'unidades'),
    ('Galleta chocolate chips', 40::numeric, 'unidades'),
    ('Galleta chocolate nueces', 40::numeric, 'unidades'),
    ('Galleta de vainilla almendras', 40::numeric, 'unidades'),
    ('Galleta vainilla chips almendras', 40::numeric, 'unidades'),
    ('Galleta chocolate con almendras', 40::numeric, 'unidades'),
    ('Galleta chocolate chips almendras', 40::numeric, 'unidades'),
    ('Galleta chips chocolate blanco', 40::numeric, 'unidades'),
    ('Galleta chocolate chips chocolate blanco', 40::numeric, 'unidades'),
    ('Galleta chocolate chips chocolate blanco nueces', 40::numeric, 'unidades')
) as v(producto_nombre, rendimiento, unidad_salida)
left join public.productos p on public.td_normalize(p.nombre) = public.td_normalize(v.producto_nombre)
on conflict (producto_nombre) do update set
  producto_id = excluded.producto_id,
  producto_nombre_normalizado = excluded.producto_nombre_normalizado,
  rendimiento = excluded.rendimiento,
  unidad_salida = excluded.unidad_salida,
  activo = excluded.activo,
  actualizado_en = now();

-- =========================
-- Reinsertar ingredientes actuales
-- =========================

-- Borra solo ingredientes de las recetas actualizadas.
delete from public.receta_ingredientes ri
using public.recetas r
where ri.receta_id = r.id
  and r.producto_nombre in (
    'Pan masa madre 1 kg aprox.',
    'Galleta vainilla nueces',
    'Galleta de vainilla con almendras',
    'Galleta de vainilla con chips',
    'Galleta vainilla chips y nueces',
    'Galleta chocolate chips y nueces',
    'Galleta chocolate y almendras',
    'Galleta de vainillia chips y almendras',
    'Galleta chocolate chips',
    'Galleta chocolate nueces',
    'Galleta de vainilla almendras',
    'Galleta vainilla chips almendras',
    'Galleta chocolate con almendras',
    'Galleta chocolate chips almendras',
    'Galleta chips chocolate blanco',
    'Galleta chocolate chips chocolate blanco',
    'Galleta chocolate chips chocolate blanco nueces'
  );

insert into public.receta_ingredientes (receta_id, insumo_id, insumo_nombre_snapshot, cantidad, unidad)
select
  r.id,
  i.id,
  i.nombre,
  v.cantidad,
  v.unidad
from (
  values
    -- Pan masa madre
    ('Pan masa madre 1 kg aprox.', 'Harina de fuerza o 0000', 1050::numeric, 'g'),
    ('Pan masa madre 1 kg aprox.', 'Agua', 750::numeric, 'g'),
    ('Pan masa madre 1 kg aprox.', 'Masa madre', 250::numeric, 'g'),
    ('Pan masa madre 1 kg aprox.', 'Sal', 30::numeric, 'g'),

    -- Galleta de vainilla con almendras
    ('Galleta de vainilla con almendras', 'Margarina', 550::numeric, 'g'),
    ('Galleta de vainilla con almendras', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta de vainilla con almendras', 'Almendras', 200::numeric, 'g'),
    ('Galleta de vainilla con almendras', 'Azúcar', 700::numeric, 'g'),
    ('Galleta de vainilla con almendras', 'Harina sin polvos de hornear', 1050::numeric, 'g'),
    ('Galleta de vainilla con almendras', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta de vainilla con almendras', 'Bicarbonato', 10::numeric, 'g'),

    -- Galleta de vainilla con chips
    ('Galleta de vainilla con chips', 'Margarina', 550::numeric, 'g'),
    ('Galleta de vainilla con chips', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta de vainilla con chips', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta de vainilla con chips', 'Chips de chocolate', 400::numeric, 'g'),
    ('Galleta de vainilla con chips', 'Azúcar', 700::numeric, 'g'),
    ('Galleta de vainilla con chips', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta de vainilla con chips', 'Harina sin polvos de hornear', 1050::numeric, 'g'),

    -- Galleta vainilla chips y nueces
    ('Galleta vainilla chips y nueces', 'Harina sin polvos de hornear', 1100::numeric, 'g'),
    ('Galleta vainilla chips y nueces', 'Margarina', 550::numeric, 'g'),
    ('Galleta vainilla chips y nueces', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta vainilla chips y nueces', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta vainilla chips y nueces', 'Chips de chocolate', 400::numeric, 'g'),
    ('Galleta vainilla chips y nueces', 'Azúcar', 700::numeric, 'g'),
    ('Galleta vainilla chips y nueces', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta vainilla chips y nueces', 'Nueces', 300::numeric, 'g'),

    -- Galleta vainilla nueces
    ('Galleta vainilla nueces', 'Harina sin polvos de hornear', 1100::numeric, 'g'),
    ('Galleta vainilla nueces', 'Margarina', 550::numeric, 'g'),
    ('Galleta vainilla nueces', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta vainilla nueces', 'Azúcar', 750::numeric, 'g'),
    ('Galleta vainilla nueces', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta vainilla nueces', 'Nueces', 300::numeric, 'g'),
    ('Galleta vainilla nueces', 'Bicarbonato', 10::numeric, 'g'),

    -- Galleta chocolate chips y nueces
    ('Galleta chocolate chips y nueces', 'Harina sin polvos de hornear', 1100::numeric, 'g'),
    ('Galleta chocolate chips y nueces', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate chips y nueces', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate chips y nueces', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chocolate chips y nueces', 'Chips de chocolate', 400::numeric, 'g'),
    ('Galleta chocolate chips y nueces', 'Nueces', 300::numeric, 'g'),
    ('Galleta chocolate chips y nueces', 'Cacao en polvo', 100::numeric, 'g'),
    ('Galleta chocolate chips y nueces', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chocolate chips y nueces', 'Bicarbonato', 10::numeric, 'g'),

    -- Galleta chocolate y almendras
    ('Galleta chocolate y almendras', 'Harina sin polvos de hornear', 1::numeric, 'kg'),
    ('Galleta chocolate y almendras', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chocolate y almendras', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chocolate y almendras', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate y almendras', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate y almendras', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chocolate y almendras', 'Cacao en polvo', 100::numeric, 'g'),
    ('Galleta chocolate y almendras', 'Almendras', 200::numeric, 'g'),

    -- Galleta de vainillia chips y almendras
    ('Galleta de vainillia chips y almendras', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta de vainillia chips y almendras', 'Chips de chocolate', 400::numeric, 'g'),
    ('Galleta de vainillia chips y almendras', 'Margarina', 550::numeric, 'g'),
    ('Galleta de vainillia chips y almendras', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta de vainillia chips y almendras', 'Almendras', 200::numeric, 'g'),
    ('Galleta de vainillia chips y almendras', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta de vainillia chips y almendras', 'Azúcar', 700::numeric, 'g'),
    ('Galleta de vainillia chips y almendras', 'Harina sin polvos de hornear', 1050::numeric, 'g'),

    -- Galleta chocolate chips
    ('Galleta chocolate chips', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate chips', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate chips', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chocolate chips', 'Chips de chocolate', 400::numeric, 'g'),
    ('Galleta chocolate chips', 'Cacao en polvo', 100::numeric, 'g'),
    ('Galleta chocolate chips', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chocolate chips', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chocolate chips', 'Harina sin polvos de hornear', 1050::numeric, 'g'),

    -- Galleta chocolate nueces
    ('Galleta chocolate nueces', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate nueces', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate nueces', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chocolate nueces', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chocolate nueces', 'Cacao en polvo', 100::numeric, 'g'),
    ('Galleta chocolate nueces', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chocolate nueces', 'Nueces', 300::numeric, 'g'),
    ('Galleta chocolate nueces', 'Harina sin polvos de hornear', 1050::numeric, 'g'),

    -- Galleta de vainilla almendras
    ('Galleta de vainilla almendras', 'Margarina', 550::numeric, 'g'),
    ('Galleta de vainilla almendras', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta de vainilla almendras', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta de vainilla almendras', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta de vainilla almendras', 'Almendras', 200::numeric, 'g'),
    ('Galleta de vainilla almendras', 'Azúcar', 700::numeric, 'g'),
    ('Galleta de vainilla almendras', 'Harina sin polvos de hornear', 1050::numeric, 'g'),

    -- Galleta vainilla chips almendras
    ('Galleta vainilla chips almendras', 'Margarina', 550::numeric, 'g'),
    ('Galleta vainilla chips almendras', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta vainilla chips almendras', 'Almendras', 200::numeric, 'g'),
    ('Galleta vainilla chips almendras', 'Azúcar', 700::numeric, 'g'),
    ('Galleta vainilla chips almendras', 'Harina sin polvos de hornear', 1050::numeric, 'g'),
    ('Galleta vainilla chips almendras', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta vainilla chips almendras', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta vainilla chips almendras', 'Chips de chocolate', 400::numeric, 'g'),

    -- Galleta chocolate con almendras
    ('Galleta chocolate con almendras', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate con almendras', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate con almendras', 'Almendras', 200::numeric, 'g'),
    ('Galleta chocolate con almendras', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chocolate con almendras', 'Harina sin polvos de hornear', 1050::numeric, 'g'),
    ('Galleta chocolate con almendras', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chocolate con almendras', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chocolate con almendras', 'Cacao en polvo', 100::numeric, 'g'),

    -- Galleta chocolate chips almendras
    ('Galleta chocolate chips almendras', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate chips almendras', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate chips almendras', 'Azúcar', 750::numeric, 'g'),
    ('Galleta chocolate chips almendras', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chocolate chips almendras', 'Nueces', 300::numeric, 'g'),
    ('Galleta chocolate chips almendras', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chocolate chips almendras', 'Cacao en polvo', 100::numeric, 'g'),
    ('Galleta chocolate chips almendras', 'Harina sin polvos de hornear', 1050::numeric, 'g'),
    ('Galleta chocolate chips almendras', 'Chips de chocolate', 400::numeric, 'g'),

    -- Galleta chips chocolate blanco
    ('Galleta chips chocolate blanco', 'Margarina', 550::numeric, 'g'),
    ('Galleta chips chocolate blanco', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chips chocolate blanco', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chips chocolate blanco', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chips chocolate blanco', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chips chocolate blanco', 'Chips de chocolate blanco', 400::numeric, 'g'),
    ('Galleta chips chocolate blanco', 'Harina sin polvos de hornear', 1000::numeric, 'g'),
    ('Galleta chips chocolate blanco', 'Cacao en polvo', 100::numeric, 'g'),

    -- Galleta chocolate chips chocolate blanco
    ('Galleta chocolate chips chocolate blanco', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate chips chocolate blanco', 'Polvos de hornear', 15::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco', 'Chips de chocolate blanco', 400::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco', 'Harina sin polvos de hornear', 1000::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco', 'Cacao en polvo', 100::numeric, 'g'),

    -- Galleta chocolate chips chocolate blanco nueces
    ('Galleta chocolate chips chocolate blanco nueces', 'Nueces', 300::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Azúcar', 700::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Bicarbonato', 10::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Cacao en polvo', 100::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Chips de chocolate blanco', 400::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Harina sin polvos de hornear', 1100::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Margarina', 550::numeric, 'g'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Huevos', 4::numeric, 'unidad'),
    ('Galleta chocolate chips chocolate blanco nueces', 'Polvos de hornear', 15::numeric, 'g')
) as v(producto_nombre, insumo_nombre, cantidad, unidad)
join public.recetas r on r.producto_nombre = v.producto_nombre
join public.insumos i on i.nombre = v.insumo_nombre;

commit;

-- Validacion sugerida despues de ejecutar:
-- select producto_nombre, count(*) ingredientes
-- from public.recetas r
-- left join public.receta_ingredientes ri on ri.receta_id = r.id
-- group by producto_nombre
-- order by producto_nombre;
