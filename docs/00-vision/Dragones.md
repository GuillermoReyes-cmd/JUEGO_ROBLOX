---
tipo: diseño
sistema: dragones
version: 3
estado: propuesta (pendiente de aprobar)
actualizado: 2026-11-03
---

# 🐲 Dragones: especies, evolución y compañero

Volver a [[INICIO]] · Visión en [[Vision-v3]] · Modelos en [[Arte-IA]]

## 1. Idea
Cada evolución **cambia la especie** del dragón. El jugador recorre los grandes tipos de dragón de las leyendas del mundo, del más humilde al más legendario.

- Los costos y multiplicadores son los de siempre (`Config/Evolutions.luau`).
- Lo que cambia es **el modelo, el tamaño, la forma de moverse y el ataque especial**.

## 2. Línea de evolución del Mundo 1

| Evo | Especie | Tipo | Inspiración (dominio público) | Movimiento | Ataque especial | 🏆 costo | ×Poder |
|---|---|---|---|---|---|---|---|
| 1 | **Huevo Ardiente** | Huevo | — | Rebota detrás de ti | Chispazo | inicio | ×1 |
| 2 | **Cría de Dragón** | Occidental (bebé) | — | Revolotea torpe | Bocanada de humo | 5 | ×1,5 |
| 3 | **Draco de Ceniza** | Draco (4 patas, sin alas) | Fáfnir | Camina pesado | Mordisco brutal | 20 | ×2 |
| 4 | **Lindwurm Escarlata** | Wyrm / Lindwurm (serpiente con 2 patas) | Gusano de Lambton | Repta ondulando | Constricción (círculo) | 60 | ×3 |
| 5 | **Guiverno Sombrío** | Guiverno (2 patas + alas) | Guivernos heráldicos | Vuela bajo | Picado | 150 | ×5 |
| 6 | **Anfíptero Emplumado** | Anfíptero (serpiente alada emplumada) | Quetzalcóatl | Vuela en espiral | Vendaval de plumas | 400 | ×8 |
| 7 | **Tianlong Celestial** | Oriental (largo, vuela sin alas) | Tianlong | Ondula en el aire | Rayo de perla | 1.000 | ×12 |
| 8 | **Dragón Occidental Ancestral** | Occidental clásico (4 patas + 2 alas) | Y Ddraig Goch | Vuela majestuoso | Aliento de fuego en cono | 2.500 | ×18 |
| 9 | **Hidra de Lerna** | Hidra (3 cabezas) | Hidra de Lerna | Camina con 3 cuellos | Triple aliento | 6.000 | ×27 |
| 10 | **Níðhöggr** | Dragón primordial | Níðhöggr | Vuela envuelto en sombra | Devorar (gran círculo) | 15.000 | ×40 |

**Escala del modelo:** crece de 1 (huevo, ~2 studs) a 4 (Níðhöggr, ~16 studs de largo).
**Montar** (actualización 1): desde la evolución 5, Guiverno, se puede montar; desde la 6 se puede volar libremente.

### Mundos siguientes (ideas, ya validadas como dominio público)

| Mundo | Especies |
|---|---|
| 2 «Hielo» | Jörmungandr (serpiente marina nórdica), Ryūjin (dragón marino japonés), Zmey Gorynych (3 cabezas eslavo), Ladon (guardián griego) |
| 3 «Tormenta» | Apep (serpiente egipcia del caos), Vritra (vedas), Tiamat (Babilonia), Bahamut (árabe) |

## 3. Elementos (renacimiento)

| Renac. | Elemento | Color principal | Brillo / partículas |
|---|---|---|---|
| 0 | 🔥 Fuego | Rojo y naranja | Brasas |
| 1 | ❄️ Hielo | Azul claro y blanco | Copos |
| 2 | ⚡ Tormenta | Amarillo y violeta | Chispas |
| 3 | 🌑 Sombra | Negro y morado | Humo oscuro |
| 4 | 🌌 Cósmico | Azul noche con estrellas | Destellos |
| 5+ | Se repite con una **aura dorada** extra por cada ciclo | | |

Cada especie tiene, por tanto, 5 versiones de color: **50 combinaciones en el Mundo 1**. Así cada jugador «se ve distinto» y hay estatus.

## 4. El dragón compañero (comportamiento)

| Situación | Qué hace el dragón |
|---|---|
| Quieto | Respira; mira a su alrededor; los voladores mantienen la altura aleteando |
| El jugador camina | Lo sigue detrás y a la derecha (unos 6 studs, más lejos si es grande). Los que vuelan, a 3–5 studs de altura |
| Entrenar (clic) | Pequeño ataque al aire (bocanada, mordisco o aleteo), «+X» y un destello del color de su elemento |
| Pelea | Vuela hacia el monstruo marcado, lo rodea y ataca. Los clics son golpes rápidos con animación de ataque |
| Recibe daño | Retrocede y parpadea en rojo. Con la vida a 0 «se desmaya» y vuelve contigo tras 5 s |
| Evoluciona | Se envuelve en una luz del color de su elemento, crece y aparece la nueva especie. Cámara cinematográfica de 2 s y aviso a todo el servidor: «¡Guillermo evolucionó a GUIVERNO SOMBRÍO!» |

## 5. Cómo se arma y se anima un dragón (técnico)
- **Modelos** en `ReplicatedStorage.Assets.Dragons.<IdEspecie>`. Se generan con la IA de Studio (ver [[Arte-IA]]) en **piezas separadas**: `Body`, `WingL`, `WingR`, opcionalmente `Head` y `Tail`.
- **El servidor crea el dragón de cada jugador** en `Workspace.Dragons` (lo ven todos) y lo une con `Motor6D`:
  - `Body` es la raíz; alas, cabeza y cola son articulaciones.
  - Se mueve con `AlignPosition` y `AlignOrientation`, con la propiedad de red del dueño, para que vaya fluido.
- **Las animaciones son procedurales en cada cliente:**
  - Cada cliente anima todos los dragones que ve, cambiando el `Transform` de los `Motor6D`: aleteo, ondulación, respiración, inclinación al girar y ataques.
  - Así no hace falta subir animaciones, todos ven lo mismo y se ve fluido.
- **Puntos especiales** (atributos o Attachments): `Mouth` (de donde sale el aliento), `Saddle` (donde se monta) y `WingL_Joint`/`WingR_Joint`.
  - Si el modelo no los trae, el código los calcula con la caja del modelo: boca delante y arriba, alas en los costados superiores.
- **Si falta un modelo,** se usa un dragón provisional hecho con piezas, como ahora, para no bloquear el desarrollo.

## 6. Números (en `Config/Dragons.luau`, nuevo)
Por especie se guardan:
- `Id`, `Name` y `Type` (tipo de dragón).
- `Scale` (tamaño del modelo).
- `Movement`: `Hop`, `Walk`, `Slither`, `Fly` o `Serpent`.
- `FollowDistance` y `FlyHeight`.
- `Special`: tipo de ataque especial, forma del área, radio o ángulo, y tiempo de recarga.
- `CanMount`.
