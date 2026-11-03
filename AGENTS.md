# Reglas del proyecto para agentes (Codex, Claude y cualquier otro)

Juego de Roblox «+1 Evolución de Dragón». Cada clic da +1 Poder, con el Poder se vencen enemigos, las Victorias compran evoluciones y renacer da multiplicadores permanentes.

Antes de trabajar, lee:
1. Este archivo.
2. [docs/01-arquitectura/ARQUITECTURA.md](docs/01-arquitectura/ARQUITECTURA.md): cómo está hecho el código.
3. **El archivo de tu tarea** en `docs/02-tareas/`. Solo haces esa tarea.

## Herramientas

- **Lenguaje:** Luau (Roblox). El código vive en `src/` y **Rojo 7.7.1** lo sincroniza con Roblox Studio. No hay otra build.
- **Comprobar la sintaxis** de un archivo (fuera de Roblox fallará en `game`, eso es normal; un error de *parse* no lo es):
  ```bash
  luau ruta/al/archivo.luau
  ```
- **Comprobar que el proyecto compila:**
  ```bash
  rojo build default.project.json -o build.rbxlx
  ```
  `build.rbxlx` no se sube al repositorio.

## Reglas obligatorias

1. **Una tarea = una rama de git** llamada `tarea/TXX-nombre-corto`. Nunca trabajes directamente en `main`.
2. **Solo editas los archivos que tu tarea lista en «Archivos permitidos».** Si necesitas cambiar otro, detente y escríbelo en la sección «Bloqueos» de tu tarea.
3. **Los archivos del núcleo no se tocan** salvo que la tarea lo diga explícitamente:
   - `src/server/Main.server.luau`
   - `src/server/Services/DataService.luau`
   - `src/shared/Remotes.luau`
   - `src/shared/Config/init.luau`
   - `default.project.json`
   - `AGENTS.md`
4. **El servidor manda.** Toda la lógica de progreso, monedas y compras se calcula en el servidor. El cliente solo pide acciones y muestra cosas. Nunca confíes en números que mande el cliente.
5. **Los números del juego** (costos, multiplicadores, precios) van en `src/shared/Config/<Sistema>.luau`, nunca escritos dentro de la lógica.
6. **Datos del jugador nuevos:** regístralos en el `Init()` de tu servicio con `DataService.RegisterDefaults({ Campo = valor })`. No edites DataService.
7. **RemoteEvents nuevos:** usa `Remotes.Get("Nombre")`. No crees remotes a mano.
8. **Estilo:**
   - Comentarios en español.
   - Nombres de código en inglés, en PascalCase para servicios y campos de datos.
   - Indentación con tabulador.
   - Imita el estilo de los archivos existentes.
9. **Compras con Robux:** solo `ShopService` maneja `ProcessReceipt`. Toda compra aleatoria (huevos, ruedas) debe mostrar sus probabilidades antes de comprar, por política de Roblox.
10. **No metas modelos ni mapas en `src/`.** Los modelos y el mapa los crea el humano en Studio.
    - Si tu sistema necesita un modelo, búscalo en `ReplicatedStorage.Assets` (lo crea el humano).
    - Si no existe, usa una pieza provisional creada por código.
11. **Sin propiedad intelectual ajena.** Nunca uses nombres, diseños ni frases de personajes o franquicias con derechos de autor (Juego de Tronos, Tolkien, Ghibli, Dragon Ball, Pokémon…). Los dragones de mitología son de dominio público y sí se pueden usar. Ver `docs/05-decisiones/Decisiones.md`, D-014.
12. **Documenta en la bóveda.** Al terminar, añade una entrada en `docs/04-bitacora/Bitacora.md`. Si tomaste una decisión de diseño o técnica, añádela en `docs/05-decisiones/Decisiones.md`.

## Cuando termines una tarea

1. Verifica la sintaxis de cada archivo que tocaste y que `rojo build` funciona.
2. Rellena en tu archivo de tarea la sección **«Resultado»**:
   - Qué hiciste.
   - Cómo probarlo en Studio, paso a paso.
   - Qué quedó pendiente.
3. Cambia el estado de tu tarea en [docs/02-tareas/TABLERO.md](docs/02-tareas/TABLERO.md) a **«En revisión»**.
4. Haz commit en tu rama con un mensaje claro en español, del tipo `T04: evoluciones con partes visuales`.

**No hagas merge a `main`:** eso lo decide el humano después de probar en Studio.
