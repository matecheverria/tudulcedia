create or replace function public.admin_reportes_resumen(p_token text,p_desde date default null,p_hasta date default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_desde date := coalesce(p_desde, (current_date - interval '30 days')::date);
  v_hasta date := coalesce(p_hasta, current_date);
  v_pedidos integer;
  v_ventas integer;
  v_compras integer;
begin
  if not public.td_admin_token_valido(p_token) then raise exception 'Clave admin invalida'; end if;

  select count(*), coalesce(sum(total_estimado),0)::integer
  into v_pedidos, v_ventas
  from pedidos
  where estado <> 'Cancelado' and fecha_solicitada between v_desde and v_hasta;

  select coalesce(sum(costo_total),0)::integer
  into v_compras
  from compras_insumos
  where fecha between v_desde and v_hasta;

  return jsonb_build_object(
    'periodo', jsonb_build_object('desde',v_desde,'hasta',v_hasta),
    'resumen', jsonb_build_object('pedidos',v_pedidos,'ventas_total',v_ventas,'compras_total',v_compras,'resultado_bruto',v_ventas-v_compras)
  );
end;
$$;

grant execute on function public.admin_reportes_resumen(text,date,date) to anon, authenticated;
notify pgrst, 'reload schema';
