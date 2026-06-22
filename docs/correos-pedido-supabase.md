# Correos de pedido Supabase

## Diagnóstico

El catálogo público guarda el pedido en Supabase y abre WhatsApp, pero no envía correo por sí solo.

GitHub Pages es frontend estático y no puede enviar correos de forma segura porque requeriría exponer claves privadas.

Antes, si llegaban correos, probablemente venían desde Apps Script / Google Sheets. En la migración a Supabase ese envío no queda automático salvo que se cree un servicio backend.

## Solución implementada

Se agregó una Supabase Edge Function:

- `supabase/functions/enviar-correo-pedido/index.ts`

Esta función envía el detalle del pedido por correo usando Resend.

## Secretos necesarios en Supabase

Configurar en Supabase Edge Functions / Secrets:

- `RESEND_API_KEY`
- `MAIL_FROM`
- `MAIL_TO`

Ejemplo conceptual:

- `MAIL_FROM`: Tu Dulce Día <pedidos@tudulcedia.cl>
- `MAIL_TO`: correo interno donde deben llegar los pedidos

No subir estos valores al repositorio.

## Deploy necesario

Desde entorno con Supabase CLI:

```bash
supabase functions deploy enviar-correo-pedido
supabase secrets set RESEND_API_KEY="..."
supabase secrets set MAIL_FROM="Tu Dulce Día <pedidos@tudulcedia.cl>"
supabase secrets set MAIL_TO="correo-destino@dominio.cl"
```

## Prueba

Después del deploy:

1. Crear pedido desde catálogo público.
2. Confirmar que se guarda en Supabase.
3. Confirmar que abre WhatsApp.
4. Confirmar que llega correo al `MAIL_TO`.

## Nota

Si no se desea usar Resend, alternativa provisoria:

- mantener Apps Script como webhook de correo,
- llamar Apps Script desde el frontend después de guardar pedido,
- o crear automatización desde Supabase hacia Make/Zapier.

La opción recomendada para producción es Supabase Edge Function + proveedor de correo transaccional.
