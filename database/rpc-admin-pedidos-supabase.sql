-- Tu Dulce Dia - RPC admin para operar pedidos Supabase
-- Ejecutar despues de database/schema.sql y database/views-dashboard-supabase.sql.
--
-- Seguridad:
-- Estas funciones son SECURITY DEFINER y validan una clave admin guardada en configuracion_negocio.
-- Primero define una clave privada en Supabase:
--
-- insert into public.configuracion_negocio (clave, valor)
-- values ('admin_dashboard_token', '{"token":"CAMBIA_ESTA_CLAVE"}'::jsonb)
-- on conflict (clave) do update set valor = excluded.valor, actualizado_en = now();
--
-- No usar la misma clave en repositorio publico.

create or replace function public.td_admin_token_valido(p_token text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.configuracion_negocio c
    where c.clave = 'admin_dashboard_token'
      and coalesce(c.valor->>'token', '') <> ''
      and c.valor->>'token' = coalesce(p_token, '')
  );
$$;

create or replace function public.admin_actualizar_pedido(
  p_token text,
  p_folio text,
  p_estado text default null,
  p_estado_pago text default null,
  p_observacion_interna text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido public.pedidos%rowtype;
begin
  if not public.td_admin_token_valido(p_token) then
    raise exception 'Clave admin invalida';
  end if;

  select * into v_pedido
  from public.pedidos
  where folio = p_folio;

  if not found then
    raise exception 'Pedido no encontrado: %', p_folio;
  end if;

  if p_estado is not null and p_estado not in ('Pendiente', 'Confirmado', 'En preparación', 'Listo para retiro/entrega', 'Entregado', 'Cancelado') then
    raise exception 'Estado invalido: %', p_estado;
  end if;

  if p_estado_pago is not null and p_estado_pago not in ('Pendiente de comprobante', 'Comprobante recibido', 'Pagado', 'Pago al retirar') then
    raise exception 'Estado de pago invalido: %', p_estado_pago;
  end if;

  update public.pedidos
  set
    estado = coalesce(p_estado, estado),
    estado_pago = coalesce(p_estado_pago, estado_pago),
    observacion_interna = coalesce(p_observacion_interna, observacion_interna),
    actualizado_en = now()
  where folio = p_folio
  returning * into v_pedido;

  return jsonb_build_object(
    'ok', true,
    'folio', v_pedido.folio,
    'estado', v_pedido.estado,
    'estadoPago', v_pedido.estado_pago,
    'observacionInterna', v_pedido.observacion_interna
  );
end;
$$;

create or replace function public.admin_anular_pedido(
  p_token text,
  p_folio text,
  p_motivo text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_nota text;
begin
  if not public.td_admin_token_valido(p_token) then
    raise exception 'Clave admin invalida';
  end if;

  if not exists (select 1 from public.pedidos where folio = p_folio) then
    raise exception 'Pedido no encontrado: %', p_folio;
  end if;

  v_nota := 'Pedido Anulado (' || to_char(now(), 'YYYY-MM-DD HH24:MI') || '): ' || coalesce(nullif(trim(p_motivo), ''), 'Sin motivo informado');

  update public.pedidos
  set
    estado = 'Cancelado',
    observacion_interna = concat_ws(E'\n', nullif(observacion_interna, ''), v_nota),
    actualizado_en = now()
  where folio = p_folio;

  return jsonb_build_object('ok', true, 'folio', p_folio, 'estado', 'Cancelado', 'motivo', p_motivo);
end;
$$;

revoke all on function public.td_admin_token_valido(text) from public;
revoke all on function public.admin_actualizar_pedido(text, text, text, text, text) from public;
revoke all on function public.admin_anular_pedido(text, text, text) from public;

grant execute on function public.admin_actualizar_pedido(text, text, text, text, text) to anon;
grant execute on function public.admin_anular_pedido(text, text, text) to anon;

grant execute on function public.admin_actualizar_pedido(text, text, text, text, text) to authenticated;
grant execute on function public.admin_anular_pedido(text, text, text) to authenticated;
