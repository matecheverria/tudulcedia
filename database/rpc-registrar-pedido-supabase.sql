-- Tu Dulce Dia - RPC para registrar pedidos directamente en Supabase
-- Ejecutar despues de database/schema.sql y database/views-dashboard-supabase.sql.
-- Objetivo: dejar de depender de Google Sheets como backend principal.

create or replace function public.registrar_pedido_publico(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cliente_id uuid;
  v_pedido_id uuid;
  v_folio text;
  v_item jsonb;
  v_producto public.productos%rowtype;
  v_total integer := 0;
  v_cliente_nombre text;
  v_cliente_telefono text;
  v_fecha_solicitada date;
  v_metodo_pago text;
  v_requiere_transferencia boolean;
  v_entrega_separada boolean;
  v_nota_entrega text;
  v_observacion text;
  v_origen text;
  v_estado_pago text;
  v_whatsapp_mensaje text;
  v_items_count integer := 0;
begin
  if payload is null then
    raise exception 'Payload requerido';
  end if;

  v_cliente_nombre := nullif(trim(coalesce(payload->>'nombreCliente', payload->>'cliente_nombre', '')), '');
  v_cliente_telefono := nullif(trim(coalesce(payload->>'telefonoCliente', payload->>'cliente_telefono', '')), '');
  v_fecha_solicitada := nullif(coalesce(payload->>'fechaSolicitada', payload->>'fecha_solicitada', ''), '')::date;
  v_metodo_pago := coalesce(nullif(payload->>'metodoPago', ''), 'Transferencia bancaria');
  v_requiere_transferencia := coalesce((payload->>'requiereDatosTransferencia')::boolean, v_metodo_pago = 'Transferencia bancaria');
  v_entrega_separada := coalesce((payload->>'entregaSeparada')::boolean, false);
  v_nota_entrega := nullif(trim(coalesce(payload->>'notaEntrega', payload->>'tipoEntrega', '')), '');
  v_observacion := nullif(trim(coalesce(payload->>'observacion', '')), '');
  v_origen := coalesce(nullif(payload->>'origen', ''), 'Catálogo Supabase');
  v_whatsapp_mensaje := nullif(payload->>'whatsappMensaje', '');

  if v_cliente_nombre is null then
    raise exception 'Nombre cliente requerido';
  end if;

  if v_fecha_solicitada is null then
    raise exception 'Fecha solicitada requerida';
  end if;

  if jsonb_typeof(payload->'productosSeleccionados') <> 'array' then
    raise exception 'productosSeleccionados debe ser un arreglo';
  end if;

  if v_metodo_pago = 'Pago al retirar' then
    v_estado_pago := 'Pago al retirar';
    v_requiere_transferencia := false;
  else
    v_estado_pago := 'Pendiente de comprobante';
    v_requiere_transferencia := true;
  end if;

  insert into public.clientes (nombre, telefono, telefono_normalizado)
  values (
    v_cliente_nombre,
    v_cliente_telefono,
    regexp_replace(coalesce(v_cliente_telefono, ''), '[^0-9]', '', 'g')
  )
  returning id into v_cliente_id;

  v_folio := public.generar_folio_pedido();

  insert into public.pedidos (
    folio,
    cliente_id,
    cliente_nombre,
    cliente_telefono,
    fecha_solicitada,
    metodo_pago,
    requiere_datos_transferencia,
    entrega_separada,
    nota_entrega,
    estado,
    estado_pago,
    total_estimado,
    observacion,
    origen,
    whatsapp_mensaje
  ) values (
    v_folio,
    v_cliente_id,
    v_cliente_nombre,
    v_cliente_telefono,
    v_fecha_solicitada,
    v_metodo_pago,
    v_requiere_transferencia,
    v_entrega_separada,
    v_nota_entrega,
    'Pendiente',
    v_estado_pago,
    0,
    v_observacion,
    v_origen,
    v_whatsapp_mensaje
  )
  returning id into v_pedido_id;

  for v_item in select * from jsonb_array_elements(payload->'productosSeleccionados') loop
    v_items_count := v_items_count + 1;

    select * into v_producto
    from public.productos
    where codigo = coalesce(v_item->>'id', v_item->>'codigo', v_item->>'producto_codigo')
       or id::text = coalesce(v_item->>'producto_id', '')
    limit 1;

    if not found then
      raise exception 'Producto no encontrado: %', coalesce(v_item->>'id', v_item->>'codigo', v_item->>'nombre', 'sin identificador');
    end if;

    insert into public.pedido_items (
      pedido_id,
      producto_id,
      producto_codigo_snapshot,
      nombre_snapshot,
      categoria_snapshot,
      precio_snapshot,
      cantidad,
      subtotal
    ) values (
      v_pedido_id,
      v_producto.id,
      v_producto.codigo,
      v_producto.nombre,
      v_producto.categoria,
      coalesce(nullif(v_item->>'precio', '')::integer, v_producto.precio),
      greatest(coalesce(nullif(v_item->>'cantidad', '')::integer, 1), 1),
      greatest(coalesce(nullif(v_item->>'subtotal', '')::integer, 0), 0)
    );

    v_total := v_total + greatest(coalesce(nullif(v_item->>'subtotal', '')::integer, 0), 0);
  end loop;

  if v_items_count = 0 then
    raise exception 'Pedido sin productos';
  end if;

  if v_total <= 0 then
    select coalesce(sum(subtotal), 0)::integer
    into v_total
    from public.pedido_items
    where pedido_id = v_pedido_id;
  end if;

  update public.pedidos
  set total_estimado = v_total,
      actualizado_en = now()
  where id = v_pedido_id;

  return jsonb_build_object(
    'ok', true,
    'pedido_id', v_pedido_id,
    'folio', v_folio,
    'totalEstimado', v_total,
    'estado', 'Pendiente',
    'estadoPago', v_estado_pago,
    'origen', v_origen
  );
end;
$$;

revoke all on function public.registrar_pedido_publico(jsonb) from public;
grant execute on function public.registrar_pedido_publico(jsonb) to anon;
grant execute on function public.registrar_pedido_publico(jsonb) to authenticated;

-- Permisos necesarios para ejecucion con anon via RPC.
-- La funcion es SECURITY DEFINER, pero mantenemos grants de ejecucion explicitos.
