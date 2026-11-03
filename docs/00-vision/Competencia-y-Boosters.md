---
tipo: diseño
sistema: competencia y monetización
version: 3
estado: propuesta (pendiente de aprobar)
actualizado: 2026-11-03
---

# 🏆 Competencia entre jugadores y boosters

Volver a [[INICIO]] · Combate en [[Combate]] · Monetización base en [[Diseno-juego-Dragon#7. Monetización]]

## 1. Por qué la competencia vende boosters
Comprar se siente bien cuando **otros lo ven** y cuando **te da ventaja en algo que importa ahora mismo**. Por eso:
- Cada competencia es **visible**: rankings en pantalla, el MVP sobre el dragón, el Coliseo con espectadores y avisos a todo el servidor.
- Cada competencia es **corta**: el jefe dura 3 minutos y un duelo 90 s. Un booster de 15 minutos «se nota» enseguida.
- Los premios de estatus (auras de campeón, títulos) **no se compran: se ganan**. El dinero acelera, pero no compra el trono. Esto mantiene a los que no pagan, que son el público de los que sí pagan.

## 2. Las 4 competencias

| Competencia | Frecuencia | Qué se mide | Premio | Booster que más ayuda |
|---|---|---|---|---|
| **MVP de monstruo** | Cada pelea | Quién hizo más daño | +50 % 🏆 y ⭐ «MVP» | x2 Daño |
| **Jefe mundial** | Cada 10 min | Ranking de daño (Top 5 en vivo) | 🥇 ×3 · 🥈 ×2 · 🥉 ×1,5 de 🏆, y Huevo de Jefe al top 3 | x2 Daño, revivir al instante |
| **Duelos** (actualización 1) | Cuando quieras | Rango (trofeos) y racha | 👑 Campeón del servidor; ranking semanal | x2 Daño, x2 Poder (más vida) |
| **Rankings permanentes** | Siempre | Poder, 🏆 totales, renacimientos, rango de duelos | Top 100 semanal: aura y título exclusivos | Todos |

**Rankings visibles en el lobby:** tablones 3D con el Top 10 de cada categoría. Se guardan con `OrderedDataStore`.

## 3. Boosters y productos (developer products)
Precios dentro del rango acordado ([[Decisiones#D-002 Monetización: escalera de 49–499 R$]]).

| Producto | Efecto | Duración | R$ |
|---|---|---|---|
| ⚡ x2 Poder | Doble Poder al entrenar | 15 min | 49 |
| ⚔️ x2 Daño | Doble daño de tu dragón (monstruos, jefe, duelos) | 15 min | 79 |
| 🏆 x2 Victorias | Doble 🏆 al ganar | 15 min | 59 |
| 🍀 x2 Suerte | Más probabilidad de huevo de jefe y críticos | 15 min | 49 |
| 💖 Revivir al instante | Tu dragón vuelve sin esperar 5 s | 1 uso | 19 |
| 📦 Pack Combate | x2 Daño + x2 Victorias + 3 revivir | 30 min | 199 |
| 🌍 **Boost de servidor** x2 Poder | **Todo el servidor** entrena x2, con aviso «¡Guillermo activó x2 PODER para todos!» | 30 min | 149 |
| 🌍 **Boost de servidor** x2 Daño en el jefe | Todo el servidor, solo durante el próximo jefe | 1 jefe | 249 |

**Reglas de los boosters:**
- **Se acumulan en tiempo** (comprar dos veces x2 Poder = 30 min), **no en fuerza** (no hace x4).
- **Siempre visibles:** aparecen como iconos con su tiempo restante debajo del HUD. Los demás ven un brillo en tu dragón.
- Los game passes permanentes (multiplicadores ×2…×512, VIP, etc.) siguen como en el diseño original.

## 4. Equilibrio y ética
- **En los duelos, la cola rápida empareja por rango.** Quien paga no aplasta a principiantes al azar.
- **Las recompensas compartidas** (todos los que hacen ≥10 % cobran) evitan la frustración de que «el que paga se lo lleva todo».
- **Nada de presión engañosa:** sin temporizadores falsos ni ofertas que «desaparecen» sin motivo. El público es joven y Roblox lo modera.
- **Huevos o premios aleatorios de pago:** se muestran siempre las probabilidades, como obliga la política de Roblox.

## 5. Avisos sociales (motor de la competencia)

| Evento | Aviso a todo el servidor |
|---|---|
| Evolución | «🐉 ¡Ana evolucionó a HIDRA DE LERNA!» |
| Boost de servidor | «🌍 ¡Guillermo activó x2 PODER para todos durante 30 min! ¡Gracias!» |
| MVP del jefe | «👑 ¡Leo fue el MVP del Rey Volcán con el 34 % del daño!» |
| Racha en duelos | «🔥 ¡Mia lleva 5 duelos ganados seguidos! ¿Quién se atreve?» |
