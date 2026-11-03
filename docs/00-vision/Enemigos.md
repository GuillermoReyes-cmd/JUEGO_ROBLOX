---
tipo: diseño
sistema: enemigos
mundo: 1 (Volcán)
tarea: T03
actualizado: 2026-11-03
---

# 👹 Enemigos del Mundo 1 «Volcán»

Volver a [[INICIO]] · Reglas de combate en [[Combate]]

Los enemigos **evolucionan con el nivel**, igual que el jugador:
- Cada nivel es más grande, más elaborado, más brillante y con más ataques.
- Hasta tener modelos reales (T09), cada uno se construye **por código con piezas** y se anima con movimientos programados: respirar, embestir, aletear, ondular y caer.

## Tabla de combate

| Nv | Enemigo | ⚡ necesario | 🏆 | Vida ×Poder | Golpe (daño / cada s) | Especial (cada s · círculos · radio · aviso · daño) | Espera |
|---|---|---|---|---|---|---|---|
| 1 | Lagartija | 10 | 1 | ×20 | 3 / 1,6 | 7 · 1 · 7 · 1,4 s · 20 | 2 s |
| 2 | Salamandra | 75 | 3 | ×20 | 4 / 1,5 | 6,5 · 1 · 8 · 1,3 s · 22 | 2 s |
| 3 | Gólem de lava | 500 | 8 | ×22 | 5 / 1,6 | 6 · 1 · 10 · 1,3 s · 25 | 3 s |
| 4 | Serpiente de fuego | 3.000 | 20 | ×22 | 5 / 1,3 | 6 · 2 · 8 · 1,2 s · 25 | 3 s |
| 5 | Wyvern | 20.000 | 50 | ×24 | 6 / 1,3 | 5,5 · 2 · 9 · 1,1 s · 28 | 4 s |
| 6 | Caballero Cazadragones | 120.000 | 120 | ×24 | 7 / 1,2 | 5 · 3 · 8 · 1,1 s · 28 | 4 s |
| 7 | Titán de Magma | 800.000 | 300 | ×26 | 8 / 1,4 | 5 · 3 · 11 · 1,0 s · 32 | 5 s |
| 8 | 👑 Rey Volcán | 5.000.000 | 1.000 | ×40 | 8 / 1,2 | 5 · 3 · 10 · 1,1 s · 30 → **Fase 2:** 5 círculos, ×0,6 de intervalo | 30 s |

## Aspecto y animaciones por nivel

### Nv 1 · Lagartija 🦎
- **Forma:** cuerpo bajo y alargado, cabeza en cuña, cola fina y 4 patitas. Verde oliva con vientre claro.
- **Animación:** reposo con balanceo lateral y cola que se menea; ataque de mordisco rápido hacia delante.
- **Sensación:** tutorial, inofensiva.

### Nv 2 · Salamandra 🔥
- **Forma:** como la lagartija pero más grande, naranja, con manchas amarillas brillantes y **llama en la punta de la cola**.
- **Animación:** ondulación del cuerpo y la llama parpadeando.

### Nv 3 · Gólem de lava 🪨
- **Forma:** bloques de roca oscura (torso, cabeza, brazos gruesos) con **grietas de lava brillantes**.
- **Animación:** respiración lenta y pesada; ataque de **golpe con los dos brazos** hacia abajo.

### Nv 4 · Serpiente de fuego 🐍
- **Forma:** 9 segmentos esféricos rojos que se hacen pequeños hacia la cola, cabeza con colmillos y **fuego a lo largo del cuerpo**.
- **Animación:** el cuerpo **ondula como una ola** continua; el ataque es un latigazo hacia delante.

### Nv 5 · Wyvern 🦇
- **Forma:** cuerpo morado y rojo, cuello largo, **dos alas grandes** y cola.
- **Animación:** **aleteo constante** y flota subiendo y bajando; el ataque es un picado corto.

### Nv 6 · Caballero Cazadragones 🛡️
- **Forma:** humanoide de armadura plateada, yelmo con visera, **espada brillante** y **escudo** con emblema rojo.
- **Animación:** guardia con la espada levantada; ataque de **tajo** (giro de la espada).
- **Sensación:** el «anti-dragón», el primer rival «inteligente».

### Nv 7 · Titán de Magma 🌋
- **Forma:** gólem gigante (el doble que el Nv 3), roca negra con **lava brillante**, ojos ardientes y **aura de fuego** (partículas).
- **Animación:** respiración profunda; el ataque es un **pisotón** que sacude la cámara.

### Nv 8 · 👑 Rey Volcán (jefe)
- **Forma:** dragón gigante de lava (cuerpo, cuello largo, cabeza con mandíbula), **alas enormes** y **corona dorada**, con aura de fuego.
- **Animación:** aleteo lento e imponente; embestida con la cabeza.
- **Fase 2:** brilla en rojo, ruge (sacudida fuerte), lanza 5 círculos y ataca más rápido.

## Cómo añadir modelos reales (T09)
1. Crea un Model con el **nombre exacto** del enemigo («Lagartija», «Gólem de lava»…) dentro de `ReplicatedStorage.Assets.Enemies`.
2. Su `PrimaryPart` debe estar en la base, mirando al frente (-Z).
3. Si existe, el juego lo usa **en lugar de** las piezas por código y le aplica las mismas animaciones de movimiento (respirar, embestir, hundirse al morir).

## Ideas para los mundos siguientes
- **Mundo 2 «Hielo»:** pingüino guerrero, lobo de escarcha, golem de hielo, yeti; especial = líneas de hielo además de círculos.
- **Mundo 3 «Tormenta»:** aves trueno, elementales de rayo; especial = rayos que caen en cadena.
