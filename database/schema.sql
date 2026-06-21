-- Tu Dulce Dia - Esquema inicial Supabase / PostgreSQL
-- Fase 1: preparacion sin cambiar produccion.

create extension if not exists pgcrypto;

-- =========================
-- Utilidades
-- =========================

create or replace function public.td_normalize(input text)
returns text
language sql
immutable
as $$
  select trim(regexp_replace(lower(unaccent(coalesce(input, ''))), '\s+', ' ', 'g'))
$$;

-- Si unaccent no existe en el proyecto, ejecutar:
-- create extension if not exists unaccent;

create extension if not exists unaccent;

-- =========================
-- Catalogo y clientes
-- =========================

create table if not exists public.clientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  telefono text,
  telefono_normalizado text,
  correo text,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

create table if not exists public.productos (
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique,
  nombre text not null,
  nombre_normalizado text not null,
  categoria text not null check (categoria in ('galleta', 'pan', 'otro')),
  precio integer not null check (precio >= 0),
  activo boolean not null default true,
  anticipacion_dias integer not null default 1 check (anticipacion_dias >= 0),
  descripcion text,
  orden integer not null default 999,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

create index if not exists idx_productos_activo_orden on public.productos(activo, orden);

create table if not exists public.disponibilidad (
  id uuid primary key default gen_random_uuid(),
  fecha date not null unique,
  estado text not null check (estado in ('Abierto', 'Cerrado', 'Bloqueado')) default 'Abierto',
  cupo_maximo integer check (cupo_maximo is null or cupo_maximo >= 0),
  nota text,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

-- =========================
-- Pedidos
-- =========================

create table if not exists public.pedidos (
  id uuid primary key default gen_random_uuid(),
  folio text not null unique,
  cliente_id uuid references public.clientes(id) on delete set null,
  cliente_nombre text not null,
  cliente_telefono text,
  fecha_solicitada date not null,
  metodo_pago text not null default 'Transferencia bancaria',
  requiere_datos_transferencia boolean not null default true,
  entrega_separada boolean not null default false,
  nota_entrega text,
  estado text not null default 'Pendiente' check (estado in ('Pendiente', 'Confirmado', 'En preparación', 'Listo para retiro/entrega', 'Entregado', 'Cancelado')),
  estado_pago text not null default 'Pendiente de comprobante' check (estado_pago in ('Pendiente de comprobante', 'Comprobante recibido', 'Pagado', 'Pago al retirar')),
  total_estimado integer not null default 0 check (total_estimado >= 0),
  observacion text,
  observacion_interna text,
  origen text not null default 'Catalogo web',
  whatsapp_mensaje text,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

create index if not exists idx_pedidos_creado_en on public.pedidos(creado_en desc);
create index if not exists idx_pedidos_estado on public.pedidos(estado);
create index if not exists idx_pedidos_estado_pago on public.pedidos(estado_pago);

create table if not exists public.pedido_items (
  id uuid primary key default gen_random_uuid(),
  pedido_id uuid not null references public.pedidos(id) on delete cascade,
  producto_id uuid references public.productos(id) on delete set null,
  producto_codigo_snapshot text,
  nombre_snapshot text not null,
  categoria_snapshot text,
  precio_snapshot integer not null check (precio_snapshot >= 0),
  cantidad integer not null check (cantidad > 0),
  subtotal integer not null check (subtotal >= 0),
  creado_en timestamptz not null default now()
);

create index if not exists idx_pedido_items_pedido on public.pedido_items(pedido_id);

-- =========================
-- Configuracion negocio
-- =========================

create table if not exists public.configuracion_negocio (
  clave text primary key,
  valor jsonb not null,
  actualizado_en timestamptz not null default now()
);

-- =========================
-- Inventario
-- =========================

create table if not exists public.insumos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  nombre_normalizado text not null,
  categoria text not null default 'Materia prima',
  unidad_base text not null check (unidad_base in ('g', 'kg', 'ml', 'l', 'unidad', 'pack', 'servicio')),
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

create index if not exists idx_insumos_normalizado on public.insumos(nombre_normalizado);

create table if not exists public.compras_insumos (
  id uuid primary key default gen_random_uuid(),
  fecha date not null,
  categoria text not null,
  insumo_id uuid not null references public.insumos(id) on delete restrict,
  insumo_nombre_snapshot text not null,
  unidad_stock text not null check (unidad_stock in ('g', 'kg', 'ml', 'l', 'unidad', 'pack', 'servicio')),
  contenido_por_envase numeric(14,3) not null check (contenido_por_envase >= 0),
  envases_comprados numeric(14,3) not null check (envases_comprados >= 0),
  costo_por_envase integer not null check (costo_por_envase >= 0),
  cantidad_total numeric(14,3) not null check (cantidad_total >= 0),
  costo_total integer not null check (costo_total >= 0),
  costo_base numeric(14,6),
  proveedor text,
  estado text not null default 'Disponible' check (estado in ('Disponible', 'Consumido', 'Merma')),
  observacion text,
  creado_en timestamptz not null default now()
);

create index if not exists idx_compras_insumos_fecha on public.compras_insumos(fecha desc);
create index if not exists idx_compras_insumos_insumo on public.compras_insumos(insumo_id);

create table if not exists public.stock_movimientos (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  insumo_id uuid not null references public.insumos(id) on delete restrict,
  tipo text not null check (tipo in ('entrada', 'salida', 'ajuste', 'merma')),
  unidad_base text not null check (unidad_base in ('g', 'ml', 'unidad', 'pack', 'servicio')),
  cantidad_base numeric(14,3) not null,
  costo_total integer not null default 0 check (costo_total >= 0),
  referencia_tipo text,
  referencia_id uuid,
  observacion text,
  creado_en timestamptz not null default now()
);

create index if not exists idx_stock_movimientos_insumo on public.stock_movimientos(insumo_id);
create index if not exists idx_stock_movimientos_fecha on public.stock_movimientos(fecha desc);

-- =========================
-- Recetas y produccion
-- =========================

create table if not exists public.recetas (
  id uuid primary key default gen_random_uuid(),
  producto_id uuid references public.productos(id) on delete set null,
  producto_nombre text not null unique,
  producto_nombre_normalizado text not null,
  rendimiento numeric(14,3) not null check (rendimiento > 0),
  unidad_salida text not null default 'unidades',
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

create table if not exists public.receta_ingredientes (
  id uuid primary key default gen_random_uuid(),
  receta_id uuid not null references public.recetas(id) on delete cascade,
  insumo_id uuid not null references public.insumos(id) on delete restrict,
  insumo_nombre_snapshot text not null,
  cantidad numeric(14,3) not null check (cantidad > 0),
  unidad text not null check (unidad in ('g', 'kg', 'ml', 'l', 'unidad', 'pack', 'servicio')),
  creado_en timestamptz not null default now()
);

create index if not exists idx_receta_ingredientes_receta on public.receta_ingredientes(receta_id);

create table if not exists public.producciones (
  id uuid primary key default gen_random_uuid(),
  fecha date not null,
  receta_id uuid not null references public.recetas(id) on delete restrict,
  producto_nombre_snapshot text not null,
  lotes numeric(14,3) not null check (lotes > 0),
  unidades_producidas numeric(14,3) not null check (unidades_producidas >= 0),
  costo_total integer,
  costo_unitario numeric(14,6),
  observacion text,
  creado_en timestamptz not null default now()
);

create table if not exists public.produccion_consumos (
  id uuid primary key default gen_random_uuid(),
  produccion_id uuid not null references public.producciones(id) on delete cascade,
  insumo_id uuid not null references public.insumos(id) on delete restrict,
  insumo_nombre_snapshot text not null,
  cantidad_base numeric(14,3) not null check (cantidad_base >= 0),
  unidad_base text not null check (unidad_base in ('g', 'ml', 'unidad', 'pack', 'servicio')),
  costo_total integer,
  creado_en timestamptz not null default now()
);

-- =========================
-- Vistas utiles
-- =========================

create or replace view public.v_stock_actual as
select
  i.id as insumo_id,
  i.nombre as insumo,
  i.unidad_base,
  coalesce(sum(sm.cantidad_base), 0) as cantidad_disponible,
  coalesce(sum(sm.costo_total), 0) as costo_asociado,
  case
    when coalesce(sum(sm.cantidad_base), 0) > 0 then coalesce(sum(sm.costo_total), 0)::numeric / coalesce(sum(sm.cantidad_base), 0)
    else null
  end as costo_unitario_base
from public.insumos i
left join public.stock_movimientos sm on sm.insumo_id = i.id
where i.activo = true
  and i.unidad_base not in ('kg', 'l')
group by i.id, i.nombre, i.unidad_base;

-- =========================
-- Folios
-- =========================

create sequence if not exists public.pedidos_folio_seq start 1;

create or replace function public.generar_folio_pedido()
returns text
language plpgsql
as $$
declare
  n bigint;
begin
  n := nextval('public.pedidos_folio_seq');
  return 'TDD-' || to_char(now(), 'YYYYMMDD') || '-' || lpad(n::text, 4, '0');
end;
$$;
