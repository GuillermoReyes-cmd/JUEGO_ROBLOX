---
tipo: diseño
sistema: combate
version: 2
tarea: T03
actualizado: 2026-11-03
---

# ⚔️ Combate de acción (v2)

Volver a [[INICIO]] · Enemigos en [[Enemigos]] · Decisión en [[Decisiones#D-010 Combate de acción en arena privada]]

## 1. Fantasía del jugador
> «Soy un dragón que cada vez pega más fuerte. Mi dragón ataca solo, pero si machaco el clic lo destrozo más rápido. Tengo que moverme para esquivar sus ataques fuertes.»

**Tres verbos:** **golpear** (clic), **esquivar** (moverse) y **crecer** (más Poder = más daño).

## 2. Flujo de una batalla

```
Mundo ──pisa plataforma──▶ ¿Poder ≥ requerido? ──no──▶ aviso «Necesitas ⚡ X»
                                   │ sí
                                   ▼
                     ¿en espera? ──sí──▶ aviso «⏳ Espera Ns»
                                   │ no
                                   ▼
              Teletransporte a ARENA PRIVADA (cuenta atrás 3·2·1·¡PELEA!)
                                   ▼
        ┌──────────────── BATALLA (tiempo límite) ────────────────┐
        │ Dragón: auto-ataque cada 1 s (bola de fuego)            │
        │ Jugador: clic = ataque rápido (garra), críticos, combo  │
        │ Enemigo: golpe normal periódico (no se esquiva)         │
        │ Enemigo: ESPECIAL → círculos rojos → explotan → esquiva │
        │ Jefe: al 50 % de vida entra en FASE 2 (más rápido)      │
        └─────────────────────────────────────────────────────────┘
              │ vida del enemigo = 0         │ tu vida = 0 o se acaba el tiempo
              ▼                              ▼
     ¡VICTORIA! +🏆 (2 s)                DERROTA (2 s)
              └──────────────┬───────────────┘
                             ▼
             Vuelta al mundo, delante de la plataforma
```

## 3. Arena privada
- **Una arena por jugador**, creada por el servidor lejos del mapa (x = 5000 + 300 × hueco, y = 300). Se reutiliza.
- **Suelo de roca de 80 × 80 studs**, anillo de lava decorativo y muros invisibles: no te puedes caer.
- **Posiciones:** el jugador aparece a 16 studs del centro mirando al enemigo; el enemigo está a 18 studs del centro, al lado opuesto.
- Nadie más ve tu batalla. El enemigo se dibuja **solo en tu pantalla** y el servidor lleva las cuentas.

## 4. Números del combate
Todos están en `src/shared/Config/Combat.luau` y en `Config/Enemies.luau`.

| Concepto | Fórmula / valor |
|---|---|
| Vida del enemigo | `RequiredPower × HPMultiplier` (20 a 40 según el nivel) |
| Daño del auto-ataque | `Poder × 1,0` cada **1 s** |
| Daño de un clic | `Poder × 0,5`, como máximo **8 clics/s** (límite antitrampas) |
| Crítico | **12 %** de probabilidad en los clics, daño **×2**, texto «¡CRÍTICO!» |
| Combo | Clics separados por menos de 0,6 s suman combo; **+1 % de daño por golpe**, hasta **+50 %** |
| Vida del jugador en batalla | `100 + 15 × (evolución − 1)`: 100 en evolución 1 y 235 en evolución 10 |
| Tiempo límite | 40 s (normales) y 75 s (jefe) |

**Ritmo objetivo** con el Poder justo requerido:
- **Solo auto-ataque:** unos 20 s contra un enemigo normal (40 s contra el jefe). Se gana justo, o se pierde si no se esquiva.
- **Clicando a unos 5 clics/s:** de 5 a 7 s (unos 12 s contra el jefe).
- **Con más Poder:** las batallas se acortan. Es la recompensa de progresar.

> La vida de la batalla es **virtual**: el personaje de Roblox no muere. Perder solo te devuelve al mundo, sin castigo.

## 5. Ataques del enemigo
1. **Golpe normal:** cada `Basic.Interval` s quita `Basic.Damage` de vida. Es la presión constante.
   - **No se esquiva.** El enemigo hace una embestida y la pantalla parpadea en rojo.
2. **Ataque especial (esquivable):** cada `Special.Interval` s, con una pequeña variación al azar.
   - Aparecen `Special.Count` **círculos rojos** en el suelo, con radio `Special.Radius`. El primero sale **justo debajo del jugador**; los demás, cerca.
   - Un relleno crece dentro del círculo durante `Special.Telegraph` s y luego **explota**.
   - Si en ese momento estás dentro de algún círculo, recibes `Special.Damage` (una sola vez por especial).
3. **Fase 2 (solo el jefe):** al bajar del 50 % de vida, el jefe ruge, se vuelve rojo y la pantalla tiembla.
   - Sus especiales salen ×0,6 más seguidos y lanza más círculos (`Phase2.Count`).

## 6. Sensación (feedback)

| Evento | Qué se ve y se siente |
|---|---|
| Auto-ataque | Una bola de fuego sale de tu cabeza hacia el enemigo y explota |
| Clic | Un zarpazo brillante sobre el enemigo y un número de daño que salta |
| Crítico | Número grande y amarillo, «¡CRÍTICO!» y una pequeña sacudida de cámara |
| Combo | Contador «x12 COMBO» que crece y se reinicia si dejas de clicar |
| Enemigo golpeado | Destello blanco y retroceso corto del enemigo |
| Golpe del enemigo | Embestida del enemigo y borde rojo en la pantalla |
| Especial | Círculos rojos que se llenan; luego explosión naranja con sacudida |
| Esquivar con éxito | Texto «¡ESQUIVADO!» en verde |
| Fase 2 | Rugido (sacudida fuerte), el jefe brilla en rojo y aviso «¡FASE 2!» |
| Victoria | El enemigo se hunde y desaparece en partículas; «¡VICTORIA! +N 🏆» |
| Derrota | «DERROTA» en rojo; vuelves al mundo |

## 7. Interfaz de batalla
- **Arriba:** «Nv. 3 · Gólem de lava», la barra de vida del enemigo con números (1.2K / 11K) y el tiempo restante.
- **Abajo:** tu barra de vida (❤️ 180 / 190).
- **A la derecha:** el contador de combo.
- **Abajo, en el centro:** «👆 ¡Clic = ataques rápidos! · 🏃 ¡Esquiva los círculos rojos!».
- **Durante la batalla:** el texto de entrenar se oculta y **los clics no entrenan**, sino que atacan.

## 8. Reglas técnicas
- **El servidor manda.** El cliente solo envía «hice clic» (`BattleClick`, sin datos). El servidor calcula el daño, los críticos y el combo, mueve el temporizador y comprueba la posición del jugador en cada explosión.
- **Remote `Battle`** (servidor → cliente). Lleva un campo `Type`:

  | `Type` | Cuándo se envía |
  |---|---|
  | `Start` | Empieza la batalla |
  | `Hit` | El jugador golpea al enemigo |
  | `EnemyAttack` | Golpe normal del enemigo |
  | `Telegraph` | Aparecen los círculos rojos |
  | `Explode` | Explotan los círculos |
  | `Phase` | El jefe entra en fase 2 |
  | `End` | Termina la batalla |
  | `TooWeak` | Aviso: falta Poder |
  | `Cooldown` | Aviso: hay que esperar |

- **Atributo `InBattle`** en el jugador. Lo leen `TrainController`, para no entrenar, y el `HUD`, para ocultar el texto de entrenar.
- **Si el jugador sale o reaparece durante la batalla,** se cancela sin premio y se libera la arena.
- **Prueba rápida en Studio:** escribe `/pelea N` en el chat para entrar directamente a la batalla contra el enemigo N.

## 9. Futuro (no está en la v2)
- **Aliento de fuego** como habilidad activa con tecla (T10).
- **Pase «Auto Win»** o «2x Victorias» (T06).
- **Modelos y animaciones reales** de enemigos, cuando existan en `ReplicatedStorage.Assets.Enemies` (T09).
- **Sonidos** (T16).
