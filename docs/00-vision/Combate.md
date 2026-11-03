---
tipo: diseño
sistema: combate
version: 3
estado: propuesta (pendiente de aprobar)
tarea: T21, T22, T23
actualizado: 2026-11-03
---

# ⚔️ Combate (v3): en el mundo, a la vista de todos

Volver a [[INICIO]] · Visión en [[Vision-v3]] · Monstruos en [[Enemigos]] · Competencia en [[Competencia-y-Boosters]]

> **Historial:**
> - **v1:** duelo automático en la plataforma (muy básico).
> - **v2:** arena privada de acción. Gustó la mecánica, pero no irse a otro lugar.
> - **v3 (esta):** la misma acción, **en el mundo compartido**, con **jefe mundial** y **duelos PvP**.

## 1. Las 3 formas de pelear

| Modo | Dónde | Contra | Para qué |
|---|---|---|---|
| **Monstruos** | Zonas del mapa | Monstruos compartidos que reaparecen | Ganar 🏆 a tu ritmo (lo principal) |
| **Jefe mundial** | Cráter del volcán, cada 10 min | El Rey Volcán, con todo el servidor | Gran recompensa y **ranking de daño en vivo** |
| **Duelos** | Coliseo, en el centro del mapa | Otro jugador y su dragón | Rango PvP, racha y premios semanales (actualización 1) |

## 2. Mecánicas comunes (vienen de la v2 y ya están probadas)
- **Auto-ataque:** tu dragón golpea cada **1 s** con daño = `Poder × 1`.
- **Clic = ataque rápido:**
  - Daño = `Poder × 0,5`, con máximo **8 clics/s** (límite en el servidor).
  - **Crítico:** 12 % de probabilidad, daño ×2.
  - **Combo:** +1 % de daño por golpe seguido, hasta +50 %.
- **Esquivar:** los ataques especiales marcan **círculos rojos** (o conos o líneas) en el suelo. Si sigues dentro cuando explotan, recibes daño.
- **Vida del dragón** = `100 + 15 × (evolución − 1)`. Si llega a 0, se desmaya 5 s y luego vuelve; no hay más castigo.
- **El servidor manda en todo:** el cliente solo dice «hice clic» y dibuja.

## 3. Monstruos en el mundo

### Cómo se pelea
1. Te acercas a un monstruo (≤ 30 studs) y **haces clic sobre él**, o tocas en móvil.
   - Queda marcado (aro rojo bajo sus pies) y **tu dragón vuela hacia él**.
2. Mientras esté marcado, **los clics en cualquier parte de la pantalla son ataques rápidos**, no entrenamiento. Al terminar la pelea o alejarte más de 45 studs, los clics vuelven a entrenar.
3. El monstruo ataca **al dragón que más daño le hace**:
   - Golpe normal: no se esquiva.
   - Especial: círculo rojo **bajo tu dragón y bajo ti**. Te mueves y tu dragón te sigue, así que esquivar sigue siendo moverte.

### Recompensas compartidas (sin «robos» de presa)
- **Todos los que hicieron al menos el 10 % del daño** reciben las 🏆 completas del monstruo.
- **El que más daño hizo es el MVP:** recibe +50 % de 🏆 y un aviso «⭐ MVP» sobre el dragón.
- Así ayudar es bueno y competir por el MVP también. Por eso importan los **boosters de daño**.

### Zonas
- El monstruo reaparece **8 s** después de morir, en su punto de aparición.
- **Puertas de zona:** para pasar a la siguiente zona necesitas cierto Poder. Es un objetivo claro, como en los «+1» exitosos.
- Detalle de zonas y monstruos en [[Enemigos]].

## 4. Jefe mundial «Rey Volcán»

| Momento | Qué pasa |
|---|---|
| Cada 10 min | Aviso a todo el servidor: «⚠️ ¡El REY VOLCÁN despierta en 60 s!», con cuenta atrás arriba |
| Aparece | Sale del cráter (animación grande y temblor de cámara para todos los que estén cerca) |
| Vida | `máx(5 M × 40, suma del Poder de los jugadores cercanos × 30)`: escala con el servidor |
| Pelea | 3 minutos como máximo. Ataques normales al azar sobre varios dragones, **lluvia de círculos** por toda la zona y **fase 2 al 50 %** (más rápido y más círculos) |
| Ranking en vivo | Arriba a la derecha, **Top 5 de daño** con nombre y porcentaje; tu puesto aparece siempre |
| Recompensas | 🥇 ×3 · 🥈 ×2 · 🥉 ×1,5 · el resto ×1 de 1.000 🏆. Basta con haber hecho ≥ 1 % del daño. Además, 2 % de probabilidad de un **Huevo de Jefe** (aspecto exclusivo) para el top 3 |
| Si nadie lo vence | Se retira con una burla; vuelve en 10 min |

## 5. Duelos en el Coliseo (actualización 1)
- **Desafiar:**
  - Te acercas a otro jugador y aparece el botón **«⚔️ Desafiar»**.
  - Él recibe una invitación de 10 s («Aceptar» o «Rechazar»).
  - También hay una **cola rápida**: «Buscar rival» empareja con alguien de rango parecido.
- **La pelea:**
  - Los dos jugadores y sus dragones aparecen en el **Coliseo, a la vista de todos**. Hay gradas y quien pasa puede mirar.
  - Hay cuenta atrás y **90 s** de límite.
- **Equilibrio:**
  - Vida de cada dragón = `su Poder × 30`; daño = su Poder.
  - El más fuerte gana antes, pero **clicar mejor y esquivar** pueden darle la vuelta a una diferencia de hasta ~2× de Poder.
- **Especial de cada especie:** botón con tiempo de recarga, por ejemplo cono de fuego, triple aliento o devorar. El rival ve el aviso y puede esquivar.
- **Premios:**
  - El ganador recibe **trofeos de rango** (+25; el perdedor −15, sin bajar de 0) y una pequeña bolsa de 🏆.
  - Hay racha de victorias con 👑 «Campeón del servidor» sobre la cabeza.
  - **Antiabuso:** después de 3 duelos contra la misma persona en 1 hora, ya no hay premio.
- Ranking semanal en [[Competencia-y-Boosters]].

## 6. Reglas técnicas
- **`CombatService` se divide en 4 partes:**
  - `MobService`: monstruos y zonas.
  - `BossService`: jefe mundial.
  - `DuelService`: Coliseo.
  - `DamageService`: el núcleo común de daño, críticos, combo, círculos y vida de los dragones.
  - Se reutiliza la lógica probada de T03 v2 (29 pruebas).
- **Remotes:**
  - `Combat` (servidor → cliente): eventos tipados como en la v2.
  - `CombatClick` (cliente → servidor): «hice clic».
  - `TargetMob` (cliente → servidor): «marco este monstruo»; el servidor valida la distancia.
  - `DuelInvite` y `DuelAnswer`.
- **Monstruos:**
  - Las cuentas las lleva el servidor: vida, quién hizo daño y objetivo.
  - El modelo se crea en el servidor (lo ven todos), anclado. Se mueve con pasos cortos hacia su objetivo.
  - Las animaciones son procedurales en cada cliente, como los dragones.
- **Atributo `InCombat`** (sustituye a `InBattle`): mientras sea `true`, los clics atacan en vez de entrenar.
- **Rendimiento:**
  - Como máximo **40 monstruos** vivos por servidor.
  - El servidor manda el estado de vida de varios golpes juntos (cada 0,1 s).
  - Los efectos los dibuja cada cliente.

## 7. Sensación visual (estándar de calidad)
- **Animaciones con anticipación y rebote:** el monstruo se encoge antes de golpear y se estira al hacerlo.
- **Partículas:** brasas al quemar, chispas al golpear, humo al desmayarse y destello del elemento en los críticos.
- **Estelas (`Trail`)** en las bolas de fuego y en las alas de los dragones voladores.
- **Luz:**
  - En el mapa: bloom suave y lava que ilumina (`PointLight`).
  - Durante el jefe, el cielo se oscurece y se vuelve rojo.
- **Cámara:** temblor proporcional al golpe, y cámara lenta de 0,3 s en el golpe que vence al jefe.
- **Sonidos** (T16): rugido por especie, impactos, críticos, monedas al cobrar 🏆.
