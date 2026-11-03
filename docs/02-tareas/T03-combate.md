# T03: Enemigos y duelos

**Responsable:** Claude · **Rama:** `tarea/T03-combate` · **Estado:** Pendiente

## Objetivo
El jugador pisa la plataforma de un enemigo. Si su Poder alcanza el requerido, gana un duelo de unos 3 segundos y cobra Victorias.

## Contexto
Implementa la sección 2 («Pelear») y la sección 4 de `docs/00-vision/Diseno-juego-Dragon.md`. Los enemigos ya están en `src/shared/Config/Enemies.luau`. El campo `Wins` ya existe en los datos.

## Archivos permitidos
- Crear:
  - `src/server/Services/CombatService.luau`
  - `src/client/CombatController.client.luau`
- Editar:
  - `src/shared/Config/Enemies.luau` (añadir `Cooldown` y `DuelSeconds`)
  - `docs/01-arquitectura/ARQUITECTURA.md` (tabla de remotes)

## Requisitos
1. Las plataformas son partes de Workspace con el tag `EnemyPad` y el atributo `EnemyIndex`.
   - Si no hay ninguna, el servidor crea plataformas de prueba en fila cerca del punto de aparición, **solo en Studio** (`RunService:IsStudio()`).
   - Cada plataforma muestra un cartel con el nombre del enemigo y el Poder necesario (formateado).
2. Al tocar una plataforma (`Touched` + validación en el servidor), empieza un duelo de `DuelSeconds`.
   - Gana si `Power >= RequiredPower`; si no, pierde.
3. Al ganar: `Wins += enemigo.Wins` y `StatsService.Refresh`.
4. Hay un tiempo de espera por jugador y enemigo (`Cooldown`). No se puede iniciar otro duelo mientras dura uno.
5. El cliente muestra una ventana de duelo: barras de vida que bajan y el texto «¡GANASTE! +N 🏆» o «Necesitas X ⚡».

## Criterios de aceptación
- [ ] Con 0 de Poder pierdo contra la Lagartija; con 10 o más gano y sube 🏆.
- [ ] Mientras dura el tiempo de espera no puedo repetir el duelo.
- [ ] Un cliente modificado que dispare el remote no puede ganar sin el Poder suficiente.
- [ ] Sintaxis correcta y `rojo build` funciona.

## Fuera de alcance
El jefe con fases y el Aliento de fuego (T10). Modelos 3D de los enemigos (T08).

## Bloqueos

## Resultado
