// Tu Dulce Dia - envio de prueba Apps Script para catalogo Supabase test
// Este archivo solo se usa en catalogo-supabase-form-test.html.
// No modifica index.html ni el flujo productivo.

(function () {
  const API_FORMAL = 'https://script.google.com/macros/s/AKfycbzmPICimq95KQ4GLloWbgeoonhTWBjzUM7J7kMbz32r9qiooqzC_MY4e2IADroA8Rnl/exec';
  const WA_NUMBER = '56930210411';
  const money = new Intl.NumberFormat('es-CL', { style: 'currency', currency: 'CLP', maximumFractionDigits: 0 });

  function q(selector) { return document.querySelector(selector); }

  function applyVisualLayer() {
    if (q('#tdVisualLayer')) return;
    document.title = 'Tu Dulce Día | Catálogo';
    const h1 = q('h1');
    if (h1) h1.textContent = 'Tu Dulce Día';
    const lead = q('.lead');
    if (lead) lead.textContent = 'Catálogo de pedidos';
    const notice = q('.notice');
    if (notice) notice.textContent = 'Galletas con 1 día de anticipación. Pan de masa madre con 3 días de anticipación.';
    const productsTitle = q('section.box h2');
    if (productsTitle) productsTitle.textContent = 'Productos';
    const orderTitle = q('aside.box h2');
    if (orderTitle) orderTitle.textContent = 'Tu pedido';
    const style = document.createElement('style');
    style.id = 'tdVisualLayer';
    style.textContent = `
      .wrap{width:min(1040px,calc(100% - 40px))!important;padding-top:22px!important}
      h1{font-size:clamp(2rem,4vw,2.8rem)!important;margin-bottom:2px!important}
      .lead{margin-bottom:12px!important;font-size:1rem!important}
      .notice{margin-bottom:14px!important;padding:11px 13px!important;border-radius:16px!important}
      .grid{grid-template-columns:minmax(0,640px) minmax(320px,360px)!important;gap:16px!important;align-items:start!important;justify-content:center!important}
      .box{border-radius:22px!important;padding:16px!important}
      .products{grid-template-columns:repeat(2,minmax(0,1fr))!important;gap:11px!important}
      .product{padding:12px!important;border-radius:18px!important}
      .product h3{font-size:.96rem!important}
      .desc{font-size:.84rem!important}
      .price{font-size:1.22rem!important}
      .payload{display:none!important}
      #status.ok{font-size:.9rem!important;padding:10px 12px!important}
      button[type="submit"]{width:100%!important;margin-top:4px!important}
      @media(max-width:1060px){.wrap{width:min(760px,calc(100% - 28px))!important}.grid{grid-template-columns:1fr!important}.products{grid-template-columns:repeat(2,minmax(0,1fr))!important}}
      @media(max-width:640px){.wrap{width:calc(100% - 22px)!important;padding-top:14px!important}.products{grid-template-columns:1fr!important}.phone{grid-template-columns:1fr!important}}
    `;
    document.head.appendChild(style);
  }

  function setMsg(text, type) {
    const msg = q('#msg');
    if (!msg) return;
    msg.style.display = 'block';
    msg.className = 'msg ' + (type === 'err' ? 'err' : 'ok');
    msg.textContent = text;
  }

  function validate(payload) {
    if (!payload.productosSeleccionados || !payload.productosSeleccionados.length) return 'Selecciona al menos un producto.';
    if (!payload.nombreCliente || payload.nombreCliente.length < 2) return 'Ingresa el nombre.';
    if (!payload.fechaSolicitada) return 'Selecciona fecha.';
    if (!q('#consent') || !q('#consent').checked) return 'Debes aceptar contacto por WhatsApp.';
    return '';
  }

  function jsonpRegistrar(payload) {
    return new Promise(function (resolve, reject) {
      const cb = 'tdPedido_' + Date.now() + '_' + Math.floor(Math.random() * 100000);
      const script = document.createElement('script');
      const timer = setTimeout(function () { cleanup(); reject(new Error('No hubo respuesta del servidor.')); }, 15000);
      function cleanup() { clearTimeout(timer); delete window[cb]; script.remove(); }
      window[cb] = function (data) { cleanup(); resolve(data); };
      script.onerror = function () { cleanup(); reject(new Error('No se pudo conectar con el servidor.')); };
      const params = new URLSearchParams({ action: 'registrarPedido', callback: cb, payload: JSON.stringify(payload) });
      script.src = API_FORMAL + '?' + params.toString();
      document.body.appendChild(script);
    });
  }

  function buildItemsText(payload) {
    const items = payload.productosSeleccionados || [];
    if (!items.length) return '';
    return items.map(function (item) { return '- ' + item.nombre + ' x ' + item.cantidad + ' = ' + money.format(item.subtotal || 0); }).join('\n');
  }

  function buildWhatsappUrl(folio, payload) {
    const lines = ['Hola Tu Dulce Día 😊','Hice un pedido desde el catálogo.','Folio: ' + folio,'Nombre: ' + payload.nombreCliente,'Total estimado: ' + money.format(payload.totalEstimado),'Fecha solicitada: ' + payload.fechaSolicitada,'','Detalle:',buildItemsText(payload),'','Quedo atento/a a la confirmación de disponibilidad y pago.'];
    if (payload.observacion) lines.splice(lines.length - 1, 0, 'Observación: ' + payload.observacion, '');
    return 'https://wa.me/' + WA_NUMBER + '?text=' + encodeURIComponent(lines.join('\n'));
  }

  function showFinal(data, payload) {
    const folio = data && (data.folio || data.numeroPedido || (data.pedido && data.pedido.folio)) || 'Pedido recibido';
    const url = buildWhatsappUrl(folio, payload);
    const payloadBox = q('#payload');
    if (payloadBox) { payloadBox.style.display = 'none'; payloadBox.textContent = ''; }
    setMsg('Pedido enviado correctamente. Folio: ' + folio + '\nPuedes abrir WhatsApp para avisar al negocio.', 'ok');
    const actions = document.querySelector('.actions');
    if (actions && !q('#waFinalBtn')) {
      const a = document.createElement('a');
      a.id = 'waFinalBtn';
      a.className = 'btn green';
      a.href = url;
      a.target = '_blank';
      a.rel = 'noopener';
      a.textContent = 'Abrir WhatsApp';
      actions.prepend(a);
    }
  }

  function overrideSubmit() {
    applyVisualLayer();
    const form = q('#form');
    const btn = form && form.querySelector('button[type="submit"]');
    if (!form || !btn || !window.buildPayload) return false;
    btn.textContent = 'Enviar pedido';
    form.onsubmit = async function (event) {
      event.preventDefault();
      const payload = window.buildPayload();
      const err = validate(payload);
      const payloadBox = q('#payload');
      if (payloadBox) { payloadBox.style.display = 'none'; payloadBox.textContent = ''; }
      if (err) { setMsg(err, 'err'); return; }
      btn.disabled = true;
      setMsg('Enviando pedido...', 'ok');
      try {
        const data = await jsonpRegistrar(payload);
        if (data && data.ok === false) throw new Error(data.error || 'El servidor no pudo registrar el pedido.');
        showFinal(data, payload);
      } catch (error) {
        setMsg(error.message || 'No se pudo registrar el pedido.', 'err');
      } finally {
        btn.disabled = false;
      }
    };
    return true;
  }

  function boot() {
    applyVisualLayer();
    if (!overrideSubmit()) setTimeout(boot, 300);
  }

  boot();
})();
