# T16a: Novedades e indicadores
Estado: En revisión · Rama: tarea/T16-novedades desde origin/tarea/T13-rankings.

## Archivos permitidos
Crear src/client/NewsController.client.luau, src/shared/Config/News.luau y src/server/Services/NewsService.luau; docs.

## Objetivo y contrato
Config.News.Version y secciones con título, emoji y texto. Lectura directa del módulo News (sin editar Config/init). NewsSeen se registra como dato persistente y se replica como atributo. Remote NewsSeen solo acepta la versión vigente, con antispam; no acepta versiones futuras. Ventana con scroll y ActiveModal News; se abre automáticamente una sola vez por sesión si hay versión pendiente, espera al otro modal y se marca vista al pulsar Entendido.

## Bloqueos
Ninguno.

## Resultado
- Config de versión y secciones, ventana con scroll y espera de modales; marca vista al pulsar Entendido.
- Dato/atributo NewsSeen y remote validado, sin admitir versiones futuras ni bajar el valor guardado.
- Sintaxis de todos los Luau, build Rojo y pruebas de contratos correctas.
### Cómo probar en Studio
1. Play con NewsSeen=0: debe abrir Novedades cuando no haya otro modal.
2. Leer y pulsar Entendido; comprobar atributo NewsSeen=1.
3. Reaparecer: no se vuelve a abrir. Reconectar con datos guardados: tampoco.
4. Subir News.Version en la config y reiniciar: se muestra la nueva versión.
5. Abrir otro modal antes de cargar: Novedades espera; probar scroll en móvil.
6. Peticiones con versión futura, texto o argumentos extra no cambian el dato.
### Pruebas reproducibles
`python docs/03-flujo/probar-v4.py` ejecuta los servicios reales con adaptadores de Roblox: compras, antispam, límites, renacer, colección, premios únicos, NewsSeen y fallos de ranking.
### Pendiente
Persistencia en un lugar publicado y verificación visual completa.
