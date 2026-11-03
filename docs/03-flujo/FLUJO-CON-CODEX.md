# Cómo trabajar con Codex y Claude a la vez

## La idea en una imagen

```
                    ┌──────────────────────────────┐
                    │   TÚ (director del proyecto) │
                    │  eliges, repartes, pruebas   │
                    │  en Studio y apruebas        │
                    └──────┬───────────────┬───────┘
          ficha de tarea   │               │   ficha de tarea
                           ▼               ▼
              ┌────────────────┐   ┌────────────────┐
              │     CLAUDE     │   │     CODEX      │
              │ en tu PC, en   │   │ en la nube (o  │
              │ esta carpeta   │   │ en otra copia) │
              │ núcleo, combate│   │ sistemas       │
              │ dinero, revisión│  │ aislados       │
              └───────┬────────┘   └───────┬────────┘
                      │ rama tarea/T03     │ rama tarea/T04
                      ▼                    ▼
              ┌──────────────────────────────────────┐
              │       GitHub (repositorio privado)   │
              │   main = versión buena del juego     │
              └──────────────────────────────────────┘
                              │
                              ▼
                 Rojo → Roblox Studio → pruebas → publicar
```

## Quién hace qué

| Rol | Hace | No hace |
|---|---|---|
| **Tú** | Eliges las tareas del [TABLERO](../02-tareas/TABLERO.md), se las das a cada agente, construyes el mapa y los modelos en Studio, pruebas, apruebas el merge y publicas | Escribir código (si no quieres) |
| **Claude** | El núcleo, los sistemas críticos (combate, tienda y dinero), escribe las fichas de tareas nuevas y revisa lo que entrega Codex | Tocar los archivos de una tarea que tiene Codex |
| **Codex** | Las tareas con ficha detallada y archivos aislados (evoluciones, renacimiento, recompensas, rankings…) | Tocar el núcleo o hacer merge a `main` |

Las dos IAs leen las **mismas reglas**:
- Codex lee automáticamente [AGENTS.md](../../AGENTS.md).
- Claude lee [CLAUDE.md](../../CLAUDE.md), que importa AGENTS.md.

Así trabajan con los mismos criterios.

---

## Preparación (una sola vez)

1. **Instala Git**, para guardar versiones y crear ramas. Claude puede instalarlo por ti con:
   ```bash
   winget install --id Git.Git -e
   ```
2. **Crea el repositorio local** en esta carpeta. Claude lo hace con `git init` y un primer commit.
3. **Crea un repositorio privado en GitHub** (github.com → New repository → Private) y súbelo. Claude te da los comandos exactos.
4. **Conecta Codex a ese repositorio:**
   - **Opción A (recomendada), Codex en la nube** (chatgpt.com/codex): conectas tu GitHub y eliges el repositorio. Codex trabaja en su propia copia en la nube y te entrega un *Pull Request*. **Nunca choca con Claude** porque no toca tu carpeta.
   - **Opción B, Codex CLI o extensión de VS Code** en tu PC: **no** lo abras en esta misma carpeta mientras Claude trabaja. Crea una segunda copia con:
     ```bash
     git worktree add ../Juego-Roblox-codex
     ```
     Abre Codex allí.

---

## El ciclo de cada tarea (paso a paso)

### 1. Elegir
Abre el [TABLERO](../02-tareas/TABLERO.md) y elige tareas «Pendiente» cuyas dependencias estén «Hecha».
**Comprueba que dos tareas en paralelo no compartan archivos.**

### 2. Entregar la tarea

**A Codex**, copia y pega este mensaje cambiando el número:

```
Lee AGENTS.md y docs/02-tareas/T04-evoluciones.md.
Implementa la tarea T04 en una rama nueva llamada tarea/T04-evoluciones,
respetando estrictamente los "Archivos permitidos".
Al terminar: verifica la sintaxis con `luau` y que `rojo build default.project.json -o build.rbxlx` funcione,
rellena la sección "Resultado" de la ficha, pon T04 "En revisión" en TABLERO.md y haz commit.
No hagas merge a main.
```

**A Claude**, en esta conversación o en una sesión nueva:

```
Haz la tarea T03 (docs/02-tareas/T03-combate.md) en la rama tarea/T03-combate.
```

Cambia el estado a **«En curso»** en el tablero.

### 3. Revisar (revisión cruzada)

Cuando Codex termine, pídele a Claude:

```
Revisa la rama tarea/T04-evoluciones contra su ficha docs/02-tareas/T04-evoluciones.md
y contra AGENTS.md. Dime si se puede fusionar o qué hay que corregir.
```

Si hay correcciones, se las pasas a Codex en el mismo hilo de la tarea.

También puedes hacerlo al revés: que Codex revise lo de Claude. Dos IAs distintas encuentran errores distintos.

### 4. Probar en Studio

1. Cambia a la rama que quieres probar:
   ```bash
   git switch tarea/T04-evoluciones
   ```
   Si la hizo Codex en la nube, primero descárgala con `git fetch`.
2. Deja corriendo `rojo serve`: actualiza Studio solo al cambiar de rama.
3. En Studio pulsa **Play** y marca los **«Criterios de aceptación»** de la ficha, uno por uno.
4. Usa los trucos del chat para avanzar rápido, solo en Studio: `/power 1000000`, `/wins 5000`, `/evo 5`, `/rebirths 2`, `/reset`.

### 5. Aprobar y fusionar
Si todo funciona:
- Fusiona la rama en `main` (en GitHub: botón «Merge pull request»; o pídeselo a Claude).
- Marca la tarea **«Hecha»** en el tablero.

### 6. Publicar
Cada cierto tiempo, con `main` actualizado y conectado a Rojo, en Studio: **Archivo → Publicar en Roblox**.

---

## Reglas para que las dos IAs no se pisen

1. **Una tarea = una rama = un solo agente.**
2. **Dos tareas a la vez nunca comparten archivos.** Para eso cada ficha lista sus «Archivos permitidos».
3. **El núcleo es de Claude:** `Main`, `DataService`, `Remotes`, `Config/init`, `default.project.json` y `AGENTS.md`. Si Codex necesita un cambio ahí, lo anota en «Bloqueos» y se lo pasas a Claude.
4. **Solo un `rojo serve` a la vez**, y en la carpeta de la rama que estás probando.
5. **El mapa y los modelos son tuyos** y viven en Studio, no en git. Roblox guarda su historial: Archivo → Historial de versiones.
6. **Los números del juego** (costos, precios) se cambian solo en `src/shared/Config/`. Así un ajuste de balance no rompe la lógica de nadie.

---

## Ritmo de trabajo por sprint (1 semana)

| Momento | Qué haces |
|---|---|
| **Lunes** | Revisa el tablero. Pide a Claude: «escribe las fichas del siguiente sprint». Reparte las tareas a Codex y Claude. |
| **Durante la semana** | Tú: mapa y modelos en Studio. Ellos: tareas en sus ramas. Revisas y pruebas lo que vaya llegando. |
| **Viernes** | Fusiona lo aprobado, haz una prueba completa del juego y publícalo en privado o para amigos. |
| **Domingo** | Anota qué se sintió mal (muy lento, muy fácil…) para ajustar números en `Config/`. |

---

## Qué NO delegar a ninguna IA

- **Decisiones de diseño y precios finales:** la IA propone, tú decides.
- **Publicar el juego, crear los game passes en el Creator Dashboard y manejar tu cuenta de Roblox.**
- **Aceptar un merge sin haberlo probado en Studio.**

---

## Chuleta de comandos de Git

| Para… | Comando |
|---|---|
| Ver en qué rama estás y qué cambió | `git status` |
| Volver a la versión buena | `git switch main` |
| Probar la rama de una tarea | `git switch tarea/T04-evoluciones` |
| Traer lo nuevo de GitHub | `git pull` |
| Fusionar una rama aprobada | `git switch main` y luego `git merge tarea/T04-evoluciones` |
| Subir a GitHub | `git push` |
