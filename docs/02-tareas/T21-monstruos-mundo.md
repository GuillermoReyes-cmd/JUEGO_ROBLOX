---
tarea: T21
responsable: Claude
rama: tarea/T21-monstruos (desde tarea/T18-dragon)
estado: En revisión
depende_de: T18
actualizado: 2026-11-03
---

# T21: Monstruos en el mundo

**Responsable:** Claude · **Rama:** `tarea/T21-monstruos` · **Estado:** En revisión

Diseño: [[Combate]] (sección 3) · [[Enemigos]] · Dragón: [[T18-dragon-companero]]

## Objetivo
Los monstruos viven en **zonas del mapa compartido**. Cualquier jugador:
1. Hace clic sobre un monstruo para marcarlo.
2. **Su dragón vuela hacia él y ataca solo.**
3. Sus clics son ataques rápidos (críticos y combo).
4. Esquiva los círculos rojos.
5. Cobra 🏆 si hizo al menos el 10 % del daño; el que más daño hizo es **MVP** y cobra +50 %.

Las zonas se abren con puertas que piden Poder.

## Qué sustituye
- **Las arenas privadas de T03 v2:**
  - Se eliminan `CombatService`, `CombatController`, las plataformas `EnemyPad` y el atributo `InBattle`.
  - Las fórmulas de daño, crítico, combo, límite de clics y círculos **se conservan** y pasan a `DamageService`.
- **`EnemyVisuals`** se reutiliza para dibujar los monstruos. Ahora siguen a su raíz del servidor y se pueden seleccionar con el clic.

## Arquitectura
- **Servidor `MobService`:**
  - Crea las zonas, los puntos de aparición, los monstruos y sus puertas.
  - Mueve a cada monstruo a **10 actualizaciones por segundo**.
  - Comportamiento: deambular → perseguir → atacar → volver a casa.
  - Lleva la vida y el registro de daño de cada monstruo, y reparte las recompensas.
- **Servidor `DamageService`:**
  - Fórmulas comunes: auto-ataque, clic con combo y crítico, límite de 8 clics/s.
  - **Vida del dragón** de cada jugador: `100 + 15 × (evolución − 1)`. Se regenera fuera de combate. Si llega a 0, el dragón se desmaya 5 s.
  - Lo reutilizarán el jefe (T22) y los duelos (T23).
- **Monstruo en el servidor:**
  - Una **raíz invisible anclada** `Workspace.Mobs.Mob_<id>`.
  - Atributos: `MobId`, `EnemyIndex`, `HP`, `MaxHP`, `Zone`, `State`, `TargetUserId`.
- **Cliente `MobController`:**
  - Para cada raíz crea su visual con `EnemyVisuals` en `Workspace.MobVisuals` y lo **desliza suavemente** hacia la raíz.
  - Muestra la barra de vida flotante y el aro de objetivo.
  - Selección: clic sobre el monstruo → `TargetMob`.
- **Cliente `CombatController` (nuevo):**
  - Clics de ataque (`CombatClick`).
  - Efectos: bola de fuego desde la boca del dragón, zarpazos, números de daño, críticos, combo, círculos, explosiones y temblor.
  - Panel del objetivo arriba, vida del dragón abajo y avisos (MVP, recompensas, desmayo).
- **`DragonController` (T18):**
  - Si el jugador tiene objetivo, **el dragón vuela junto al monstruo** mirando hacia él, en vez de seguir al jugador.
  - Con el atributo local `AttackPulse` en el modelo de un dragón, ese dragón ataca. Se usa para que **los dragones de otros jugadores** también se vean atacando.

## Reglas
| Regla | Valor |
|---|---|
| Distancia para marcar a un monstruo | ≤ 30 studs del jugador |
| Se pierde el objetivo | Si el jugador se aleja > 45 studs, muere el monstruo, se desmaya el dragón o se pulsa **Esc** o **Q** |
| Requisito de zona | Para marcar monstruos de una zona hace falta su Poder. El servidor también lo valida, para que no sirva atravesar una puerta haciendo trampa |
| Puertas | Muro brillante con cartel «🔒 ⚡ X». Se vuelve atravesable **en el cliente** cuando tu Poder alcanza el requisito |
| Objetivo del monstruo | El jugador que más daño le hizo y sigue cerca |
| Golpe normal | Quita vida al dragón de su objetivo. Necesita estar a ≤ 12 studs (× escala) del dragón o del jugador; si no, el monstruo se acerca |
| Especial | Círculos bajo el jugador objetivo (y cerca). Al explotar, quita vida al dragón de **cada participante que esté dentro** |
| Correa | Si el monstruo se aleja > 40 studs de su punto de aparición o nadie le pega en 10 s, vuelve a casa y se cura del todo |
| Reaparición | 8 s después de morir |
| Recompensa | Cobra todo participante con ≥ 10 % del daño. El MVP (mayor daño) cobra +50 % y ve el aviso «⭐ MVP» |

## Archivos
- **Crear:**
  - `src/shared/Config/Zones.luau`
  - `src/server/Services/MobService.luau`
  - `src/server/Services/DamageService.luau`
  - `src/client/MobController.client.luau`
  - `src/client/CombatController.client.luau` (reescrito)
- **Editar:**
  - `src/shared/Config/Enemies.luau`: «Wyvern» pasa a «Murciélago Ígneo» y se añaden `Speed` y `AttackRange`.
  - `src/shared/Config/Combat.luau`: reglas del mundo abierto.
  - `src/shared/Config/init.luau`: registrar Zones.
  - `src/client/EnemyVisuals.luau`: seguir la raíz y permitir la selección.
  - `src/client/DragonController.client.luau`: volar al objetivo y `AttackPulse`.
  - `src/client/TrainController.client.luau` y `src/client/HUD.client.luau`: `InCombat`.
  - `src/server/Services/DebugService.luau`: `/zona N` sustituye a `/pelea`.
  - Documentación.
- **Eliminar:**
  - `src/server/Services/CombatService.luau` (arena v2).
  - El `CombatController` v2, que se reescribe.

## Zonas de prueba automáticas (solo Studio y si el mapa no tiene zonas)
Mientras no exista el mapa (T08), en Studio se crean **5 zonas de prueba** en fila, delante del punto de aparición:
- Cada una es un suelo de color con su nombre en un cartel.
- Tiene puntos de aparición en círculo y una **puerta** a la entrada (desde la zona 2).

**En el mapa definitivo:**
- Cada zona es una parte con el tag `Zone` y el atributo `ZoneIndex`.
- Las puertas son partes con el tag `ZoneGate` y el atributo `ZoneIndex`.
- Los puntos de aparición son partes con el tag `MobSpawn` y los atributos `ZoneIndex` y `Enemy` (nombre del enemigo).

## Criterios de aceptación
- [ ] Al pulsar Play aparecen 5 zonas de prueba con monstruos animados que deambulan.
- [ ] Clic sobre una Lagartija: mi dragón vuela hacia ella y ataca cada segundo. Mis clics salen como zarpazos con números, críticos y combo.
- [ ] El monstruo me persigue y golpea a mi dragón (baja su barra de vida). Sus círculos rojos me dañan si me quedo dentro.
- [ ] Al vencerla cobro 🏆 y veo «+N 🏆 ⭐ MVP»; reaparece a los 8 s.
- [ ] Sin el Poder de la zona 2, la puerta me bloquea y el servidor no me deja marcar sus monstruos.
- [ ] Con 2 jugadores pegándole al mismo monstruo, ambos cobran y uno es MVP. Cada uno ve al dragón del otro atacar.
- [ ] Si mi dragón llega a 0 se desmaya 5 s y pierdo el objetivo.
- [ ] Los clics fuera de combate siguen entrenando.
- [ ] Sintaxis correcta, `rojo build` funciona y la lógica se verifica con una simulación.

## Bloqueos
(ninguno)

## Resultado

### Qué se hizo
- **`DamageService`** (núcleo reutilizable para el jefe y los duelos):
  - Auto-ataque = Poder; clic = 0,5 × Poder × combo, con 12 % de crítico ×2 y un máximo de 8 clics/s.
  - Vida del dragón con regeneración (desde 4 s sin daño, 15 %/s).
  - Desmayo de 5 s; al despertar vuelve con el 50 % y espera 4 s antes de regenerar.
- **`MobService`:**
  - **5 zonas de prueba** automáticas en Studio, con suelo, cartel, puntos de aparición, muros y puerta.
  - **26 monstruos** que deambulan, persiguen a quien más daño les hace, golpean al dragón y lanzan círculos bajo el jugador.
  - Vuelven a casa curados si los llevas lejos o nadie les pega en 10 s.
  - Reaparecen a los 8 s.
  - Recompensa para todo el que haga ≥ 10 % del daño, y **MVP +50 %**.
  - Validación en el servidor de la distancia, el Poder de la zona y el desmayo.
- **`MobController`:**
  - Dibuja y anima cada monstruo con `EnemyVisuals`, deslizándolo suavemente hacia la raíz del servidor.
  - Barra de vida flotante con nivel y nombre, y aro rojo giratorio bajo tu objetivo.
  - Marcar con clic; soltar con **Q** o **Esc**.
  - Las puertas se ponen verdes y se pueden cruzar cuando tienes el Poder.
- **`CombatController` (reescrito):**
  - Panel del objetivo con «Tu daño %» y vida del dragón.
  - Bola de fuego **con estela, del color de tu elemento, desde la boca de tu dragón**.
  - Zarpazos, números de daño, críticos y combo.
  - Círculos y explosiones visibles para todos, con «¡ESQUIVADO!».
  - Avisos de recompensa y MVP, zona bloqueada y desmayo.
- **`DragonController`:**
  - En combate, **tu dragón vuela junto al monstruo** y lo mira.
  - Los dragones de los demás jugadores **se ven atacando** (`AttackPulse`).
  - Desmayado, el dragón se tumba de lado.
- **Eliminado:** las arenas privadas (`CombatService` v2). **`/pelea` pasa a ser `/zona N`**, y hay un nuevo `/curar`.

### Verificación
- **Simulación con los servicios reales: 25 pruebas superadas.** Cubren:
  - Zonas, puertas y puntos de aparición.
  - Marcar de lejos (rechazado) y de cerca.
  - Daño del auto-ataque y límite de 8 clics con combo.
  - Muerte con recompensa del MVP y suelta del objetivo, y reaparición.
  - Zona bloqueada.
  - Dos jugadores cobran y solo uno es MVP.
  - El monstruo golpea al dragón; círculo bajo el jugador; quedarse dentro duele y salir esquiva.
  - Desmayo, pérdida del objetivo y vuelta con media vida.
  - Correa: el monstruo vuelve curado.
- Sintaxis correcta en todo el proyecto y `rojo build` funciona.
- **No probado todavía en Studio:** el aspecto, la fluidez y la sensación.

### Cómo probarlo en Studio
1. Conecta Rojo y pulsa **Play**. Delante verás 5 zonas en fila con carteles. La primera es libre; las demás tienen una puerta roja.
2. Entra en la **Pradera de Ceniza**, escribe `/power 10` y **haz clic sobre una Lagartija**. Tu dragón vuela hacia ella y le lanza bolas de fuego. Haz clic rápido para los zarpazos y muévete cuando veas el círculo rojo.
3. Al vencerla: «+2 🏆 ⭐ MVP».
4. **Puertas:** con `/power 500` la puerta de la zona 2 se pone verde y se puede cruzar. Usa `/zona 3` para ir directo.
5. **Desmayo:** escribe `/power 1` y pelea contra un Gólem sin moverte.
6. **Con 2 jugadores** (Prueba → 2 jugadores): ataquen al mismo monstruo.

### Pendiente
- Ajustar los números (vida, daño, velocidades) cuando se sienta en juego. Todo está en `Config/Combat`, `Config/Enemies` y `Config/Zones`.
- Los monstruos no tienen animación de caminar específica: usan respirar, embestir y retroceder.
- Mapa real (T08) y modelos de IA (T20).