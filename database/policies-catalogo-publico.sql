-- Tu Dulce Dia - Politicas publicas de solo lectura para catalogo
-- Fase 2 segura: permite leer productos activos desde Supabase usando anon key.
-- Ejecutar en Supabase SQL Editor despues de schema.sql, seed.sql e import historico.
--
-- No permite insertar, editar ni borrar datos.
-- No abre pedidos, clientes, inventario privado ni costos.

-- =========================
-- Productos publicos activos
-- =========================

alter table public.productos enable row level security;

drop policy if exists "Catalogo publico puede leer productos activos" on public.productos;

create policy "Catalogo publico puede leer productos activos"
on public.productos
for select
to anon, authenticated
using (activo = true);

-- =========================
-- Configuracion publica minima
-- =========================
-- Solo permite leer claves necesarias para el catalogo publico.
-- Por ahora: whatsapp y reglas_pedido.
-- No expone datos de clientes, pedidos, compras ni stock.

alter table public.configuracion_negocio enable row level security;

drop policy if exists "Catalogo publico puede leer configuracion minima" on public.configuracion_negocio;

create policy "Catalogo publico puede leer configuracion minima"
on public.configuracion_negocio
for select
to anon, authenticated
using (clave in ('whatsapp', 'reglas_pedido'));

-- =========================
-- Verificacion rapida
-- =========================
-- Ejecutar despues de crear las politicas:
--
-- select codigo, nombre, precio, activo
-- from public.productos
-- where activo = true
-- order by orden;
--
-- Esperado: productos activos solamente.
