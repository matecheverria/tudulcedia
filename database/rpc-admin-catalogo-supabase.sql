-- RPC admin catalogo Supabase

create or replace function public.admin_actualizar_producto(
  p_token text,
  p_codigo text,
  p_nombre text default null,
  p_precio integer default null,
  p_activo boolean default null,
  p_descripcion text default null,
  p_orden integer default null
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.td_admin_token_valido(p_token) then
    raise exception 'Clave admin invalida';
  end if;

  update public.productos
  set
    nombre = coalesce(nullif(trim(p_nombre),''), nombre),
    nombre_normalizado = case when nullif(trim(p_nombre),'') is not null then public.td_normalize(p_nombre) else nombre_normalizado end,
    precio = coalesce(p_precio, precio),
    activo = coalesce(p_activo, activo),
    descripcion = coalesce(p_descripcion, descripcion),
    orden = coalesce(p_orden, orden),
    actualizado_en = now()
  where codigo = p_codigo;

  if not found then
    raise exception 'Producto no encontrado: %', p_codigo;
  end if;

  return jsonb_build_object('ok', true, 'codigo', p_codigo);
end;
$$;

grant execute on function public.admin_actualizar_producto(text,text,text,integer,boolean,text,integer) to anon, authenticated;

notify pgrst, 'reload schema';
