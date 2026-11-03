---
tipo: diseño
version: 3
estado: propuesta (pendiente de aprobar)
actualizado: 2026-11-03
---

# 🐉 Visión v3: «+1 Entrenador de Dragones»

Volver a [[INICIO]] · Decisión en [[Decisiones#D-011 Entrenador con dragón compañero]]

> **Cambio respecto a la v2:**
> - Ya no eres un humano al que le salen partes de dragón; eres un **entrenador con su dragón**.
> - Ya no se pelea en arenas privadas, sino **en el mundo, a la vista de todos**, y hay **competencia entre jugadores**.

## 1. La fantasía
> «Mi dragón empezó siendo un huevo. Cada clic lo hace más fuerte. Ha sido draco, guiverno, dragón oriental… y ahora es una hidra de tres cabezas. Lo monto para volar sobre el volcán, peleo contra el jefe con todo el servidor, y en el Coliseo le gané a un jugador que tenía más Poder que yo.»

## 2. Qué ve el jugador
- **Su avatar normal de Roblox** (se mantiene su personalidad).
- **A su lado, su dragón:**
  - Le sigue volando o caminando y respira.
  - Mira a su alrededor y reacciona al entrenar o pelear.
- **Los dragones de los demás jugadores**, cada uno de su especie y elemento. Es el gran escaparate social del juego.

## 3. Bucle principal

```
ENTRENAR ──clic = +1 Poder (×multiplicadores)──▶ tu dragón hace su animación de entrenamiento
    │
    ▼
PELEAR EN EL MUNDO ──monstruos compartidos por zonas──▶ 🏆 Victorias (y MVP si haces más daño)
    │
    ▼
EVOLUCIONAR ──🏆──▶ tu dragón CAMBIA DE ESPECIE (huevo → cría → draco → … → Níðhöggr)
    │
    ▼
COMPETIR ──▶ Jefe mundial cada 10 min (ranking de daño) · Duelos en el Coliseo (ranking semanal)
    │
    ▼
RENACER ──▶ multiplicador permanente + nuevo ELEMENTO (fuego, hielo, tormenta, sombra, cósmico)
    ↺
```

## 4. Sistemas y notas de diseño

| Sistema | Nota |
|---|---|
| Especies y evolución del dragón | [[Dragones]] |
| Combate en el mundo y jefe mundial | [[Combate]] |
| Monstruos y zonas | [[Enemigos]] |
| Competencia (jefe, duelos, rankings) y boosters | [[Competencia-y-Boosters]] |
| Modelos 3D generados con IA | [[Arte-IA]] |
| Monetización general (sigue vigente) | [[Diseno-juego-Dragon#7. Monetización]] |

## 5. Qué se reutiliza de lo ya hecho
- **Entrenar con clic, guardado, HUD y trucos de Studio:** se mantienen.
- **Lógica de combate de T03 v2:** se reutiliza en el mundo abierto, el jefe y los duelos. Incluye auto-ataque, clics con crítico y combo, límite de 8 clics/s, círculos rojos que se esquivan, fase 2 y validación en el servidor.
- **Números de evolución** (costos y multiplicadores): se mantienen; cambia lo que se ve.
- **Renacimiento (T05):** se mantiene; el elemento ahora cambia el color del dragón.
- **Las partes pegadas al avatar (T04 v1 de Codex):** quedan **sustituidas** por el dragón compañero.
- **Las arenas privadas (T03 v2):** quedan **sustituidas** por el combate en el mundo.

## 6. Alcance y calendario propuesto

| Versión | Fecha objetivo | Incluye |
|---|---|---|
| **Lanzamiento** | 1 de diciembre | Dragón compañero con 10 especies, monstruos en el mundo, jefe mundial con ranking de daño, boosters, renacimiento, tienda y mapa |
| **Actualización 1 «Navidad»** | ~15 de diciembre | **Duelos PvP en el Coliseo** con ranking semanal, **montar y volar**, evento navideño |
| Mundo 2 «Hielo» | Enero | Nuevas especies (mitología nórdica, japonesa y eslava), nuevos monstruos |

> **Por qué los duelos van en la actualización 1:** el jefe mundial ya da competencia desde el primer día y es más sencillo. Los duelos PvP necesitan más pruebas de equilibrio, y además sirven como «gran novedad» para que los jugadores vuelvan.
> **Esta decisión es tuya:** se pueden adelantar los duelos al lanzamiento a cambio de más riesgo con la fecha.

## 7. Reglas de propiedad intelectual (obligatorio)
- **No se usan nombres ni diseños de personajes con derechos de autor:** Smaug, Drogon, Rhaegal, Viserion, Balerion, Caraxes, Syrax, Vermithrax, Glaurung, Haku, Shenron de Dragon Ball, etc.
- **Sí se usan:** tipos de dragón (occidental, oriental, guiverno, draco, anfíptero, wyrm, hidra) y **dragones de mitología** (dominio público): Fáfnir, Níðhöggr, Quetzalcóatl, Hidra de Lerna, Gusano de Lambton, Tianlong, Jörmungandr, Ryūjin, Zmey Gorynych, Y Ddraig Goch, Ladon…
- Ver [[Decisiones#D-014 Sin propiedad intelectual ajena]].
