-- Correccion de costos y margenes
-- Usa costo_base cuando existe y normaliza unidades cuando no existe.

create or replace view public.v_costo_unitario_insumos as
with compras_normalizadas as (
  select
    c.insumo_id,
    case
      when c.costo_base is not null and c.costo_base > 0 then c.costo_base
      when c.cantidad_total > 0 then
        c.costo_total::numeric /
        case
          when c.unidad_stock = 'kg' then c.cantidad_total * 1000
          when c.unidad_stock = 'l' then c.cantidad_total * 1000
          else c.cantidad_total
        end
      else null
    end as costo_unitario_base,
    case
      when c.unidad_stock = 'kg' then c.cantidad_total * 1000
      when c.unidad_stock = 'l' then c.cantidad_total * 1000
      else c.cantidad_total
    end as cantidad_base,
    c.costo_total
  from public.compras_insumos c
)
select
  i.id as insumo_id,
  i.nombre as insumo,
  i.unidad_base,
  case
    when coalesce(sum(cn.cantidad_base),0) > 0 then
      coalesce(sum(cn.costo_total),0)::numeric / coalesce(sum(cn.cantidad_base),0)
    else avg(cn.costo_unitario_base)
  end as costo_unitario_base,
  coalesce(sum(cn.cantidad_base),0) as cantidad_comprada,
  coalesce(sum(cn.costo_total),0) as costo_total_compras
from public.insumos i
left join compras_normalizadas cn on cn.insumo_id = i.id
where i.activo = true
group by i.id, i.nombre, i.unidad_base;

create or replace view public.v_costo_recetas as
select
  r.id as receta_id,
  r.producto_id,
  r.producto_nombre,
  r.producto_nombre_normalizado,
  r.rendimiento,
  r.unidad_salida,
  coalesce(sum(
    case
      when ri.unidad = 'kg' then ri.cantidad * 1000 * cu.costo_unitario_base
      when ri.unidad = 'g' then ri.cantidad * cu.costo_unitario_base
      when ri.unidad = 'l' then ri.cantidad * 1000 * cu.costo_unitario_base
      when ri.unidad = 'ml' then ri.cantidad * cu.costo_unitario_base
      else ri.cantidad * cu.costo_unitario_base
    end
  ),0)::numeric(14,2) as costo_receta,
  case
    when r.rendimiento > 0 then (
      coalesce(sum(
        case
          when ri.unidad = 'kg' then ri.cantidad * 1000 * cu.costo_unitario_base
          when ri.unidad = 'g' then ri.cantidad * cu.costo_unitario_base
          when ri.unidad = 'l' then ri.cantidad * 1000 * cu.costo_unitario_base
          when ri.unidad = 'ml' then ri.cantidad * cu.costo_unitario_base
          else ri.cantidad * cu.costo_unitario_base
        end
      ),0) / r.rendimiento
    )::numeric(14,2)
    else null
  end as costo_unitario_estimado,
  count(ri.id) as ingredientes,
  count(ri.id) filter (where cu.costo_unitario_base is null or cu.costo_unitario_base = 0) as ingredientes_sin_costo
from public.recetas r
left join public.receta_ingredientes ri on ri.receta_id = r.id
left join public.v_costo_unitario_insumos cu on cu.insumo_id = ri.insumo_id
where r.activo = true
group by r.id, r.producto_id, r.producto_nombre, r.producto_nombre_normalizado, r.rendimiento, r.unidad_salida;

create or replace view public.v_margen_pedidos as
select
  p.id as pedido_id,
  p.folio,
  p.cliente_nombre,
  p.fecha_solicitada,
  p.estado,
  p.estado_pago,
  p.total_estimado as venta,
  coalesce(sum(coalesce(cr.costo_unitario_estimado,0) * pi.cantidad),0)::numeric(14,2) as costo_estimado,
  (p.total_estimado - coalesce(sum(coalesce(cr.costo_unitario_estimado,0) * pi.cantidad),0))::numeric(14,2) as margen,
  case
    when p.total_estimado > 0 then ((p.total_estimado - coalesce(sum(coalesce(cr.costo_unitario_estimado,0) * pi.cantidad),0)) / p.total_estimado * 100)::numeric(14,2)
    else null
  end as margen_pct,
  count(pi.id) as items,
  count(pi.id) filter (where cr.receta_id is null) as items_sin_receta,
  count(pi.id) filter (where coalesce(cr.ingredientes_sin_costo,0) > 0) as items_con_costo_pendiente,
  string_agg(pi.nombre_snapshot || ' x ' || pi.cantidad, ' | ' order by pi.nombre_snapshot) as detalle
from public.pedidos p
left join public.pedido_items pi on pi.pedido_id = p.id
left join public.productos prod on prod.id = pi.producto_id
left join public.v_costo_recetas cr on cr.producto_id = pi.producto_id
  or cr.producto_nombre_normalizado = public.td_normalize(pi.nombre_snapshot)
  or cr.producto_nombre_normalizado = public.td_normalize(prod.nombre)
where p.estado <> 'Cancelado'
group by p.id, p.folio, p.cliente_nombre, p.fecha_solicitada, p.estado, p.estado_pago, p.total_estimado;

grant select on public.v_costo_unitario_insumos to anon, authenticated;
grant select on public.v_costo_recetas to anon, authenticated;
grant select on public.v_margen_pedidos to anon, authenticated;

notify pgrst, 'reload schema';
