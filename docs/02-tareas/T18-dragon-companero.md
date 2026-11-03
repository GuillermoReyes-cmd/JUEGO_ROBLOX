---
tarea: T18
responsable: Claude
rama: tarea/T18-dragon
estado: En revisión
depende_de: —
actualizado: 2026-11-03
---

# T18: Dragón compañero

**Responsable:** Claude · **Rama:** `tarea/T18-dragon` · **Estado:** En revisión

Diseño: [[Dragones]] · Visión: [[Vision-v3]] · Modelos: [[Arte-IA]]

## Objetivo
Cada jugador tiene **su dragón**, que todos ven. El dragón:
- le sigue por el mapa;
- se mueve según su tipo: rebota, camina, repta, vuela u ondula;
- respira, aletea y mira a su alrededor;
- **reacciona a cada clic de entrenamiento** con un ataque y un soplo del color de su elemento;
- **cambia de especie** al cambiar la evolución.

## Archivos
- **Crear:**
  - `src/shared/Config/Dragons.luau`: las 10 especies y los 5 elementos.
  - `src/server/Services/DragonService.luau`: crea, reconstruye y elimina los dragones, y les da la propiedad de red al dueño.
  - `src/server/Dragon/DragonBuilder.luau`: arma el modelo con IA si existe (`Body` + `Wing`) o uno provisional por especie, con articulaciones `Motor6D`.
  - `src/client/DragonController.client.luau`: seguir (solo el dragón propio), animar (todos los dragones visibles) y reaccionar al entrenar.
- **Editar:**
  - `src/shared/Config/init.luau`: registrar `Config.Dragons` (núcleo, dueño Claude).
  - `docs/01-arquitectura/ARQUITECTURA.md`.

## Contrato técnico (lo usarán T19, T21, T22, T23 y T25)
- **Ubicación:** `Workspace.Dragons.Dragon_<UserId>` (Model), con `PrimaryPart = Root` (invisible).
- **Atributos del modelo:**

  | Atributo | Contenido |
  |---|---|
  | `OwnerId` | Id del dueño |
  | `Species` | Id de la especie |
  | `Movement` | Tipo de movimiento |
  | `Scale` | Escala del modelo |
  | `RootHeight` | Altura sobre el suelo en studs |
  | `Element` | Elemento actual |

- **Articulaciones (`Motor6D`) que anima el cliente:**

  | Nombre | Qué mueve | Animación |
  |---|---|---|
  | `Body` | Raíz → cuerpo | Respirar, rebotar, inclinarse, embestir |
  | `Head` | Cabeza | Mirar, morder |
  | `WingL` / `WingR` | Alas | Aletear |
  | `Tail1…n` | Cola | Balanceo en cadena |
  | `Seg1…n` | Cuerpo serpiente | Ondular |
  | `LegFL`, `LegFR`, `LegBL`, `LegBR`, `LegL`, `LegR` | Patas | Caminar |
  | `Neck1…3` | Cuellos de la hidra | Balanceo desfasado |

- **Puntos especiales:**
  - `Mouth`: Attachment en la cabeza (o al frente del cuerpo). Lleva un `ParticleEmitter` llamado `Breath`.
  - `Saddle`: Attachment sobre el lomo, para montar (T25).
- **Movimiento:**
  - `Root` lleva `AlignPosition` y `AlignOrientation` (OneAttachment) y su **propiedad de red es del dueño**.
  - El cliente del dueño mueve los objetivos de esas restricciones, así el movimiento es fluido y se replica a todos.
- **Elemento:** depende de `Rebirths`. El servidor pone el aura (`ParticleEmitter`, `PointLight`) del color del elemento.
- **Reconstrucción:** cuando cambia el atributo `Evolution` del jugador y la especie es otra. T19 añadirá la cinemática encima.

## Requisitos
1. **Seguimiento:**
   - Detrás y a la derecha del jugador; la distancia crece con el tamaño del dragón.
   - Los dragones de tierra se pegan al suelo (raycast hacia abajo); los voladores flotan a `FlyHeight`.
   - Si el dragón queda a más de 80 studs (teletransporte), **aparece de golpe** junto al jugador.
2. **Orientación:** mira hacia donde se mueve; quieto, mira hacia donde mira el jugador.
3. **Animaciones procedurales por tipo de movimiento:**

   | Movimiento | Especie | Cómo se mueve |
   |---|---|---|
   | `Hop` | Huevo | Rebota al moverse y se tambalea quieto |
   | `FlyLow` | Cría | Aleteo rápido y torpe, a baja altura |
   | `Walk` | Draco, Hidra | Paso con 4 patas, cuerpo que sube y baja, cola |
   | `Slither` | Lindwurm | Ondulación horizontal pegada al suelo |
   | `Fly` | Guiverno, Occidental, Níðhöggr | Aleteo amplio, planeo al ir rápido, inclinación |
   | `FlySerpent` | Anfíptero, Tianlong | Ondulación en el aire (horizontal y vertical) y alas si tiene |

4. **Reacción al entrenar (dragón propio):** cada clic de entrenamiento provoca una embestida o mordisco corto y un soplo de partículas desde `Mouth`.
5. **Sin modelo de IA:** dragón provisional **reconocible por especie**: huevo con grietas, cría regordeta, draco acorazado, lindwurm serpiente con 2 patas, guiverno, anfíptero emplumado, oriental largo con bigotes, occidental clásico, hidra de 3 cabezas y Níðhöggr oscuro con runas.
6. **Rendimiento:** las piezas sin colisión, sin consultas y `Massless`, y un solo bucle de animación para todos los dragones.

## Criterios de aceptación
- [ ] Al entrar aparece mi Huevo Ardiente y me sigue rebotando.
- [ ] Con `/evo 1` … `/evo 10` el dragón cambia a cada especie, con su forma y su movimiento.
- [ ] Al hacer clic para entrenar, mi dragón ataca y suelta un soplo de partículas.
- [ ] Al caminar, saltar o teletransportarme, el dragón me sigue sin quedarse atascado.
- [ ] Otro jugador (prueba de servidor local con 2 jugadores) ve mi dragón moverse fluido y animado.
- [ ] `/rebirths 1` … `/rebirths 4` cambia el color del aura (hielo, tormenta, sombra, cósmico).
- [ ] Si pongo un modelo en `Assets.Dragons.<Id>.Body` (y `Wing`), se usa en lugar del provisional.
- [x] Sintaxis correcta y `rojo build` funciona.

## Bloqueos
(ninguno)

## Resultado

### Qué se hizo
- **`Config/Dragons.luau`:**
  - 10 especies con id, tipo, tamaño (de 2,2 a 14 studs), movimiento, altura de vuelo y colores.
  - 5 elementos.
  - Reglas para seguir al jugador.
- **`DragonBuilder`:**
  - Si hay modelo de IA en `Assets.Dragons.<Id>` (`Body` + `Wing`), lo escala a su tamaño, pone un ala a cada lado con `Motor6D` y calcula la boca y la montura.
  - Si no, arma un **dragón provisional por especie**:

    | Especie | Cómo se ve |
    |---|---|
    | Huevo | Grietas brillantes |
    | Cría | Regordeta, con ojos grandes, alitas, 4 patitas y cola |
    | Draco | Acorazado, con púas, 4 patas y sin alas |
    | Lindwurm | Serpiente de 6 segmentos con 2 patas |
    | Guiverno | 2 patas, alas de murciélago y cola con punta |
    | Anfíptero | Serpiente emplumada con cresta y alas de plumas |
    | Tianlong | 10 segmentos, bigotes, cuernos, perla y crin |
    | Occidental | Cuello, 4 patas, grandes alas y 5 segmentos de cola |
    | Hidra | 3 cuellos con cabezas |
    | Níðhöggr | Occidental oscuro con runas brillantes y alas rasgadas |

- **`DragonService`:**
  - Un dragón por jugador en `Workspace.Dragons`, con la propiedad de red del dueño.
  - Aura, luz y soplo del color del elemento; aura dorada a partir de 5 renacimientos.
  - Se reconstruye al cambiar de especie y se actualiza al renacer.
  - `GetDragon(player)` para los sistemas siguientes.
- **`DragonController`:**
  - **Seguir:** detrás y a la derecha, pegado al suelo o volando, aparece de golpe si se aleja más de 80 studs y mira hacia donde va.
  - **Animar todos los dragones:** rebote, paso con 4 patas, reptar, aleteo (amplio quieto, planeo al ir rápido), ola de serpiente en el aire, colas en cadena, patas colgando al volar, cuellos de hidra desfasados y cabeza que mira alrededor.
  - **Al entrenar:** anticipación y embestida, más un soplo de partículas.

### Verificación
- **Simulación del armado de las 10 especies** con un entorno 3D simulado: todas las comprobaciones superadas.
  - Articulaciones correctas por especie: alas, patas, cola, segmentos, cuellos y cabeza.
  - Boca y montura presentes.
  - Atributos y restricciones de movimiento.
  - Ninguna pieza con colisión ni anclada.
- Sintaxis correcta en todo el proyecto y `rojo build` funciona.
- **No probado todavía en Studio:** el movimiento real, el aspecto y la sensación.

### Cómo probarlo en Studio
1. Conecta Rojo (puerto 34872, carpeta «Juego Roblox - Claude») y pulsa **Play**. Junto a ti aparece tu **Huevo Ardiente** rebotando.
2. Camina y salta: debe seguirte. Haz clic para entrenar: debe dar un saltito hacia delante y soltar chispas.
3. Escribe en el chat `/evo 2`, `/evo 3` … `/evo 10` para ver cada especie.
4. Escribe `/rebirths 1` … `/rebirths 5` para ver los elementos (5 = fuego + aura dorada).
5. **Prueba con 2 jugadores:** Prueba → Clientes y servidores → 2 jugadores. Cada uno debe ver el dragón del otro animado.
6. `/pelea 1` (con `/power 10`): tu dragón debe aparecer contigo en la arena.

### Pendiente
- Ajustar alturas, distancias y velocidades de animación cuando se vean en Studio.
- La cinemática de evolución y el aviso al servidor son de T19.
- Atacar a monstruos es de T21; montar, de T25.
