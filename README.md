# +1 Evolución de Dragón

Juego de Roblox desarrollado con Claude y Codex.

| Para… | Lee |
|---|---|
| Entender el juego y el mercado | [docs/00-vision/](docs/00-vision/) |
| Entender el código | [docs/01-arquitectura/ARQUITECTURA.md](docs/01-arquitectura/ARQUITECTURA.md) |
| Ver qué falta y quién lo hace | [docs/02-tareas/TABLERO.md](docs/02-tareas/TABLERO.md) |
| Saber cómo repartir trabajo a Codex y Claude | [docs/03-flujo/FLUJO-CON-CODEX.md](docs/03-flujo/FLUJO-CON-CODEX.md) |
| Reglas que siguen las IAs | [AGENTS.md](AGENTS.md) |

## Trabajar cada día

1. Abre una terminal en esta carpeta y ejecuta:
   ```bash
   rojo serve
   ```
2. En Roblox Studio, abre tu lugar, ve a la pestaña **Plugins → Rojo** y pulsa **Connect**.
3. Los cambios en `src/` aparecen solos en Studio.
4. Para probar, pulsa **Play**. Los trucos del chat (solo en Studio) son: `/power 1000000`, `/wins 5000`, `/evo 5`, `/rebirths 2`, `/reset`.
5. Guarda o publica desde Studio como siempre (Archivo → Publicar en Roblox).

## Guardado de datos en Studio

Para probar el guardado, el lugar debe estar **publicado**. Además hay que activar **Configuración del juego → Seguridad → Habilitar acceso de Studio a los servicios de API**. Sin eso el juego funciona, pero no guarda el progreso.
