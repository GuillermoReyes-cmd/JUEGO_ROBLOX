---
tarea: T19
responsable: Codex
rama: tarea/T19-especies (desde tarea/T18-dragon)
estado: Pendiente
depende_de: T18
actualizado: 2026-11-03
---

# T19: Especies y evolución v3

**Responsable:** Codex · **Rama:** `tarea/T19-especies`, **creada desde `origin/tarea/T18-dragon`** · **Estado:** Pendiente

Diseño: [[Dragones]] · Contrato del dragón: [[T18-dragon-companero]] · Arquitectura: [[ARQUITECTURA]]

## Objetivo
El jugador gasta 🏆 para que **su dragón evolucione a la siguiente especie**. La evolución debe sentirse épica:
- Ventana clara con la especie actual y la siguiente.
- Cinemática de 2 s sobre su dragón.
- Aviso a todo el servidor.

## Contexto (qué ya existe)
- **T18 (rama base):**
  - `DragonService` reconstruye el dragón **automáticamente** cuando cambia el atributo `Evolution` del jugador (lo pone `StatsService.Refresh`).
  - Las especies están en `Config.Dragons.Species`, una por evolución.
  - Usa `Config.Dragons.GetSpecies(evolution)`.
- **Costos y multiplicadores:** `Config.Evolutions`. **No cambies los números.**
- **Tu trabajo anterior en T04** (rama `tarea/T04-evoluciones`): la **compra validada** en el servidor (`Remotes.Get("Evolve")`) y la ventana con `ActiveModal` **se reutilizan**. Las **partes pegadas al avatar NO**: el dragón compañero las sustituye.
- **Para probar:** en el chat de Studio, `/wins 100000` da Victorias y `/evo N` cambia la evolución.

## Archivos permitidos
- **Crear:**
  - `src/server/Services/EvolutionService.luau`
  - `src/client/EvolutionController.client.luau`
- **Editar:**
  - `docs/01-arquitectura/ARQUITECTURA.md`: remotes y contrato `ActiveModal`.
  - Esta ficha.
  - `docs/02-tareas/TABLERO.md`: tu estado.
  - `docs/04-bitacora/Bitacora.md`: tu entrada.
- **Solo lectura (NO editar):** `DragonService`, `DragonBuilder`, `DragonController`, `Config/Dragons.luau`, `Config/Evolutions.luau` y el núcleo.

## Requisitos
1. **Compra (servidor):**
   - `Remotes.Get("Evolve")`, sin argumentos del cliente.
   - Valida que exista la siguiente evolución y que `Wins >= Cost`. Cobra, hace `Evolution += 1` y llama a `StatsService.Refresh`, que provoca la reconstrucción del dragón.
   - Antispam: como máximo 1 compra cada 0,5 s por jugador.
2. **Aviso al servidor:**
   - Remote `Evolved`, servidor → todos.
   - Datos: `{ UserId, DisplayName, SpeciesId, SpeciesName, SpeciesType }`.
3. **Ventana (cliente):**
   - Botón **«🐉 Evolucionar»** a la izquierda (y = 35 %), **ancho fijo de unos 200 px**.
   - La ventana muestra:
     - especie actual y siguiente, con **nombre y tipo** (por ejemplo «Guiverno Sombrío · Guiverno»);
     - costo en 🏆 y el multiplicador nuevo;
     - una **vista previa 3D** de la siguiente especie: `ViewportFrame` con una copia del modelo de la siguiente especie girando. Si clonar el modelo es complejo, vale un retrato con el nombre y el color de la especie; anótalo en «Resultado».
   - Botón gris si no alcanza. Evolución máxima: «¡Tu dragón es legendario!».
   - Usa el contrato `PlayerGui.ActiveModal = "Evolution"`.
4. **Cinemática (solo el dueño):**
   - Al confirmar, la cámara se acerca a su dragón 2 s (`Camera.CameraType = Scriptable` con un tween, y vuelve después).
   - Destello de luz del color del elemento (atributo `Element` del modelo del dragón).
   - Partículas en espiral.
   - Texto grande «¡EVOLUCIONASTE A <NOMBRE>!» con el tipo debajo.
   - El dragón nuevo aparece por la reconstrucción automática de T18: **no** lo crees tú.
5. **Aviso para todos:** banner arriba durante 4 s: «🐉 <Nombre> evolucionó a <ESPECIE>».
6. **Estilo:** imita el de `CombatController` y `HUD`: fuente FredokaOne, fondos oscuros y esquinas redondeadas.

## Criterios de aceptación
- [ ] Con `/wins 5` puedo pasar del Huevo a la Cría. Veo la cinemática y el dragón cambia.
- [ ] Sin 🏆 suficientes, el botón está gris y el servidor rechaza el remote disparado a mano.
- [ ] Con 2 jugadores, el otro ve el banner y el dragón nuevo.
- [ ] En la evolución 10 no se puede comprar más.
- [ ] Sintaxis correcta (`luau`) y `rojo build default.project.json -o build.rbxlx` funciona.

## Bloqueos

## Resultado
