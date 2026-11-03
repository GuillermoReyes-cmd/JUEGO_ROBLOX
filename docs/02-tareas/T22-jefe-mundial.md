---
tarea: T22
responsable: Claude
rama: integracion/lanzamiento (sobre T21 + T19)
estado: En revisión
depende_de: T21
actualizado: 2026-11-03
---

# T22: Jefe mundial «Rey Volcán»

**Responsable:** Claude · **Estado:** En revisión

Diseño: [[Combate]] (sección 4) · [[Competencia-y-Boosters]] · Base técnica: [[T21-monstruos-mundo]]

## Objetivo
Cada 10 minutos el **Rey Volcán** sale del cráter. Todo el servidor pelea contra él con sus dragones. Hay un **ranking de daño en vivo** y premios según el puesto. Es la competencia principal del lanzamiento y el momento en que más se notan los boosters.

## Ciclo del evento

| Fase | Duración | Qué pasa |
|---|---|---|
| Espera | 10 min (Config) | Contador visible en el HUD: «👑 Rey Volcán en 7:42» |
| Aviso | 60 s | Banner a todo el servidor: «⚠️ ¡El REY VOLCÁN despierta en 60 s!» y botón **«Ir al cráter»** (teletransporte) |
| Aparición | 3 s | Emerge del cráter con temblor de cámara para los que estén cerca |
| Pelea | hasta 3 min | Vida = `máx(5M × 40, Σ Poder de los jugadores en el cráter × 30)` |
| Fase 2 | al 50 % de vida | Ruge, brilla en rojo, ataques ×0,6 más seguidos y lluvia de 5 a 10 círculos |
| Final | — | Si muere: premios y ranking final. Si se acaba el tiempo: «se retira» sin premios. Vuelve a Espera |

## Reglas
- **Cualquiera puede atacar** al jefe estando en el cráter (≤ 60 studs del centro), sin requisito de Poder.
- **Se reutiliza `DamageService`:** auto-ataque, clics con combo y crítico, límite de 8 clics/s, vida y desmayo del dragón.
- **El jefe no se mueve.** Ataca:
  - Golpe normal: a los 3 dragones con más daño, cada `Basic.Interval`.
  - **Lluvia de círculos** cada `Special.Interval`: un círculo bajo cada jugador del cráter más círculos al azar.
- **Ranking en vivo:** Top 5 de daño con nombre y porcentaje, y tu puesto siempre visible. Se actualiza cada 0,5 s.
- **Premios** (solo con ≥ 1 % del daño):

  | Puesto | 🏆 |
  |---|---|
  | 🥇 1º | ×3 |
  | 🥈 2º | ×2 |
  | 🥉 3º | ×1,5 |
  | Resto | ×1 |

  Sobre 1.000 🏆 base. Aviso a todo el servidor: «👑 MVP: <nombre> con el X % del daño».
- **En Studio:** `/jefe` lo invoca ya (sin esperar) y `/jefe fin` lo termina.

## Archivos
- **Crear:**
  - `src/server/Services/BossService.luau`
  - `src/client/BossController.client.luau`
  - `src/shared/Config/Boss.luau`
- **Editar:**
  - `src/shared/Config/init.luau`: registrar Boss.
  - `src/server/Services/DebugService.luau`: `/jefe`.
  - `src/server/Services/MobService.luau`: exponer el objetivo «jefe» en `CombatClick`, compartiendo el clic.
  - `src/client/CombatController.client.luau` y `DragonController`: objetivo jefe.
  - Documentación.
- **Cráter de prueba:** en Studio, si el mapa no tiene una parte con el tag `BossArena`, se crea un cráter circular detrás de la zona 5.

## Criterios de aceptación
- [ ] Con `/jefe` aparece el Rey Volcán en el cráter, con su barra de vida y el ranking.
- [ ] Mi dragón vuela hacia él al hacer clic sobre el jefe, y mis clics son ataques.
- [ ] Lluvia de círculos que se esquiva; fase 2 al 50 %.
- [ ] Al morir: premios por puesto y aviso del MVP. Con 2 jugadores, el ranking ordena bien.
- [ ] El ciclo de 10 min y el aviso de 60 s funcionan (en Studio, con tiempos acortados por Config).
- [ ] Sintaxis correcta, `rojo build` funciona y la simulación pasa.

## Bloqueos
(ninguno)

## Resultado

### Qué se hizo
- **El jefe es un monstruo especial de `MobService`** (`SpawnBoss`), así que reutiliza todo lo de T21: marcar con clic, auto-ataque, clics con combo y crítico, círculos, animaciones y barra de vida. Como jefe:
  - No se mueve ni vuelve a casa.
  - Su golpe normal alcanza a los 3 jugadores con más daño.
  - Lanza una **lluvia de círculos**: uno bajo cada participante más 3 al azar (5 al azar en fase 2).
  - Pasa a **fase 2 al 50 %**: ataques ×0,6 más seguidos y aviso «¡FASE 2!», con el cuerpo brillando en rojo.
  - Al morir no reaparece: se retira tras su animación.
- **`BossService`:**
  - Ciclo Espera (10 min) → Aviso (60 s) → Pelea (3 min) → Espera.
  - Vida = `máx(5M × 40, Σ Poder en el cráter × 30)`.
  - Ranking en vivo cada 0,5 s.
  - Premios por puesto: ×3, ×2, ×1,5 y ×1 (sobre 1.000 🏆), con un mínimo del 1 % del daño.
  - Si se acaba el tiempo, se retira sin premios.
  - **Cráter de prueba** automático en Studio, detrás de la zona 5: suelo de basalto, anillo de lava y cartel.
- **`BossController`:**
  - Panel arriba a la derecha: «👑 Rey Volcán en 9:41» y, en pelea, **Top 5 con medallas** y «Tú: #N».
  - Botón **«🔥 Ir al cráter»** durante el aviso y la pelea.
  - Avisos grandes: despierta, fase 2, derrotado + MVP, tu puesto y premio, o se retiró.
- **Trucos:** `/jefe` lo invoca con un aviso de 3 s y `/jefe 0` lo retira.
- **`DragonController`:** el dragón se coloca a una distancia según la altura del monstruo, para no meterse dentro del jefe.

### Verificación
- **Simulación del jefe: 12 pruebas superadas.** Cubren:
  - Aparece como jefe.
  - Se marca desde lejos y sin requisito de zona.
  - No se mueve.
  - El golpe alcanza a varios.
  - Lluvia de 5 círculos (2 jugadores + 3).
  - Fase 2 una sola vez y con más círculos.
  - Al morir entrega el daño de cada uno para los premios por puesto, sin premios por defecto.
  - Se retira y no reaparece.
  - Al retirarlo se sueltan los objetivos.
- **La simulación de monstruos de T21 sigue pasando (25 pruebas)** tras los cambios.
- Sintaxis correcta y `rojo build` funciona.
- **Pendiente de probar en Studio:** el ciclo completo con los tiempos reales, la interfaz y el aspecto del jefe.

### Cómo probarlo en Studio
1. Conecta Rojo y pulsa **Play**. Arriba a la derecha aparece la cuenta atrás del Rey Volcán.
2. Escribe `/power 100000` y luego `/jefe`. Sale el aviso; pulsa **«🔥 Ir al cráter»**.
3. Haz clic sobre el jefe, ataca y esquiva la lluvia de círculos. Al 50 % entra en fase 2.
4. Al vencerlo verás el ranking, el MVP y «🥇 Puesto 1 +3K 🏆».
5. Con 2 jugadores (Prueba → 2 jugadores) se comprueba el orden del ranking y los premios por puesto.

### Pendiente
- Modelo de IA del jefe (ver [[Arte-IA]]).
- Sonidos (T16).
- Ajustar la vida y el daño según cómo se sienta.