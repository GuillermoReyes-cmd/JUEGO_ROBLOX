# T03: Enemigos y duelos

**Responsable:** Claude · **Rama:** `tarea/T03-combate` · **Estado:** En revisión

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

### Qué se hizo
- **`CombatService`:**
  - Configura cada parte con el tag `EnemyPad`: cartel flotante con nombre (👑 si es jefe) y ⚡ necesario, y conexión de `Touched`.
  - En Studio, si el mapa no tiene plataformas, crea la carpeta `Workspace.TestEnemyPads` con 8 plataformas en fila, 40 studs delante del punto de aparición. Cada una lleva un bloque rojo provisional que crece con la dificultad.
- **Validación en el servidor:**
  - El personaje debe estar vivo y realmente encima de la plataforma (margen de 6 studs); así no sirve un `Touched` falso.
  - Debe tener Poder suficiente.
  - No puede haber un duelo en curso ni estar en tiempo de espera.
  - **No hay remote de cliente → servidor**: un cliente modificado no tiene nada que disparar para ganar.
- **Si no alcanza el Poder no hay duelo:** solo aparece el aviso «Necesitas ⚡ X para vencer a …». Es una decisión de diseño: hacer esperar un duelo que se sabe perdido aburre.
- **Las Victorias se entregan al terminar el duelo.** Si el jugador sale antes, no cobra.
- **Los avisos se limitan a uno cada 1,5 s por jugador**, porque `Touched` se dispara muchas veces seguidas.
- **`Config/Enemies.luau`:** se añadieron `DuelSeconds` (2 a 3,5 s; jefe 6 s) y `Cooldown` (1 a 5 s; jefe 30 s).
- **`CombatController`:**
  - Panel de duelo bajo el HUD con dos barras: la del enemigo baja a 0 y la tuya pierde parte.
  - Avisos en el centro: «¡GANASTE! +N 🏆», «Necesitas ⚡ …» o «⏳ Espera Ns».

### Verificación
- La sintaxis de los 3 archivos es correcta y `rojo build` funciona.
- Prueba de lógica con un entorno simulado (10 casos, todos superados): sin Poder da aviso y no cobra; los avisos no se repiten; no hay dos duelos a la vez; ganar suma Victorias; el tiempo de espera bloquea; tras la espera se repite; lejos de la plataforma o muerto se ignora.
- **No probado todavía en Studio.**

### Cómo probarlo en Studio
1. Conecta Rojo a esta rama y pulsa **Play**. Delante del punto de aparición aparecen 8 plataformas de colores con su cartel.
2. Pisa la **Lagartija** con 0 ⚡: aparece «Necesitas ⚡ 10…» y no sube 🏆.
3. Entrena hasta 10 ⚡ (o escribe `/power 10` en el chat) y pisa la Lagartija: panel de duelo de 2 s, luego «¡GANASTE! +1 🏆».
4. Quédate encima y muévete: aparece «⏳ Espera…» y no cobras. Baja y vuelve a subir tras 1 s: puedes repetir.
5. Escribe `/power 5000000` y prueba el **Rey Volcán**: duelo de 6 s, +1000 🏆 y 30 s de espera.

### Pendiente
- Modelos y animaciones reales de enemigos (T08), jefe con fases y Aliento de fuego (T10).
- En el mapa definitivo, cada plataforma necesita el tag `EnemyPad` y el atributo `EnemyIndex` (1–8). Se ponen en Studio: Propiedades → Atributos y Etiquetas.
