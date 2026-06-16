# Apps Script - Tu Dulcedía

Esta carpeta deja el backend de Google Apps Script versionado en GitHub.

## Despliegue automático/manual

El workflow `.github/workflows/deploy-apps-script.yml` permite empujar el contenido de esta carpeta al proyecto Apps Script usando `clasp`.

Requiere dos GitHub Secrets:

- `APPS_SCRIPT_ID`: ID del proyecto Apps Script.
- `CLASPRC_JSON`: contenido del archivo `~/.clasprc.json` generado por `clasp login`.

No pegues `CLASPRC_JSON` en chats ni commits. Debe quedar solo como GitHub Secret.

## Clave admin

El código usa `PropertiesService.getScriptProperties().getProperty("ADMIN_TOKEN")`.

Configúrala una vez en Apps Script desde:

`Configuración del proyecto → Propiedades de secuencia de comandos → Agregar propiedad`

Nombre:

`ADMIN_TOKEN`

Valor:

Tu clave privada de administración.

## Nota importante

El workflow es manual (`workflow_dispatch`). Solo ejecútalo cuando quieras actualizar Apps Script desde GitHub.
