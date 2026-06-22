-- Lista productos para administracion, incluyendo inactivos.

create or replace function public.admin_listar_productos(p_token text)
returns table (
  codigo text,
  nombre text,
  categoria text,
  precio integer,
  activo boolean,
  descripcion text,
  orden integer,
  anticipacion_dias integer
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.td_admin_token_valido(p_token) then
    raise exception 'Clave admin invalida';
  end if;

  return query
  select
    p.codigo,
    p.nombre,
    p.categoria,
    p.precio,
    p.activo,
    p.descripcion,
    p.orden,
    p.anticipacion_dias
  from public.productos p
  order by p.orden asc, p.nombre asc;
end;
$$;

grant execute on function public.admin_listar_productos(text) to anon, authenticated;

notify pgrst, 'reload schema';
