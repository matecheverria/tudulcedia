create or replace function public.td_convertir_a_base(p_cantidad numeric, p_unidad text)
returns numeric
language sql
immutable
as $$
  select case
    when p_unidad = 'kg' then p_cantidad * 1000
    when p_unidad = 'l' then p_cantidad * 1000
    else p_cantidad
  end
$$;

create or replace function public.td_unidad_base_normalizada(p_unidad text)
returns text
language sql
immutable
as $$
  select case
    when p_unidad = 'kg' then 'g'
    when p_unidad = 'l' then 'ml'
    else p_unidad
  end
$$;

create or replace function public.admin_registrar_stock_movimiento(
  p_token text,
  p_insumo_id uuid,
  p_fecha date,
  p_tipo text,
  p_cantidad_base numeric,
  p_unidad_base text,
  p_costo_total integer default 0,
  p_observacion text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare v_insumo insumos; v_mov stock_movimientos; v_cantidad numeric; v_unidad text;
begin
  if not public.td_admin_token_valido(p_token) then raise exception 'Clave admin invalida'; end if;
  select * into v_insumo from insumos where id=p_insumo_id;
  if v_insumo.id is null then raise exception 'Insumo no encontrado'; end if;
  if coalesce(p_cantidad_base,0) <= 0 then raise exception 'Cantidad debe ser mayor a cero'; end if;

  v_cantidad := public.td_convertir_a_base(p_cantidad_base, coalesce(nullif(p_unidad_base,''), v_insumo.unidad_base));
  v_unidad := public.td_unidad_base_normalizada(coalesce(nullif(p_unidad_base,''), v_insumo.unidad_base));

  if p_tipo in ('salida','merma') then
    v_cantidad := -abs(v_cantidad);
  elsif p_tipo in ('entrada','ajuste') then
    v_cantidad := abs(v_cantidad);
  else
    raise exception 'Tipo invalido';
  end if;

  insert into stock_movimientos(fecha,insumo_id,tipo,unidad_base,cantidad_base,costo_total,referencia_tipo,observacion)
  values(coalesce(p_fecha,current_date),v_insumo.id,p_tipo,v_unidad,v_cantidad,coalesce(p_costo_total,0),'manual',p_observacion)
  returning * into v_mov;

  return to_jsonb(v_mov);
end;
$$;

grant execute on function public.admin_registrar_stock_movimiento(text,uuid,date,text,numeric,text,integer,text) to anon, authenticated;
notify pgrst, 'reload schema';
