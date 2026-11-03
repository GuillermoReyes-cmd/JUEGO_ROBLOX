---
tipo: diseño
sistema: enemigos
mundo: 1 (Volcán)
version: 3
estado: propuesta (pendiente de aprobar)
actualizado: 2026-11-03
---

# 👹 Monstruos y zonas del Mundo 1 «Volcán»

Volver a [[INICIO]] · Reglas en [[Combate]] · Modelos en [[Arte-IA]]

> **Cambios de la v3:**
> - Los monstruos viven en **zonas del mapa compartido** y se ven entre todos.
> - El antiguo «Wyvern» enemigo pasa a ser el **Murciélago Ígneo**, para no confundirlo con el Guiverno, que ahora es una especie del jugador.
> - El **Rey Volcán** pasa a ser un **coloso de magma**, no un dragón, y es el **jefe mundial**.

## Mapa del Mundo 1

```
                      ┌──────────────── CRÁTER ────────────────┐
                      │   👑 Rey Volcán (jefe mundial, 10 min)  │
                      └───────────────────▲────────────────────┘
                                           │ (siempre abierto: todos pueden ir al jefe)
 ZONA 5 Corazón del Volcán   ⚡800K ──▶ Titán de Magma
 ZONA 4 Fortaleza Cazadragones ⚡120K ─▶ Caballero Cazadragones
 ZONA 3 Cumbres Humeantes    ⚡20K ──▶ Murciélago Ígneo
 ZONA 2 Ríos de Lava         ⚡500 ──▶ Gólem de lava · Serpiente de fuego
 ZONA 1 Pradera de Ceniza    libre  ──▶ Lagartija · Salamandra
                      ┌──────────── LOBBY ────────────┐
                      │ spawn · entrenamiento · tienda │
                      │ ⚔️ COLISEO (duelos)            │
                      └───────────────────────────────┘
```

## Tabla de monstruos

| Zona | Monstruo | ⚡ recomendado | 🏆 | Vida | Golpe (daño / s) | Especial (cada s · forma · radio · aviso · daño) | Cuántos |
|---|---|---|---|---|---|---|---|
| 1 | Lagartija | 10 | 1 | ×20 | 3 / 1,6 | 7 · círculo · 7 · 1,4 s · 20 | 6 |
| 1 | Salamandra | 75 | 3 | ×20 | 4 / 1,5 | 6,5 · círculo · 8 · 1,3 s · 22 | 4 |
| 2 | Gólem de lava | 500 | 8 | ×22 | 5 / 1,6 | 6 · círculo grande · 10 · 1,3 s · 25 | 4 |
| 2 | Serpiente de fuego | 3.000 | 20 | ×22 | 5 / 1,3 | 6 · 2 círculos · 8 · 1,2 s · 25 | 3 |
| 3 | Murciélago Ígneo | 20.000 | 50 | ×24 | 6 / 1,3 | 5,5 · línea en picado · 9 · 1,1 s · 28 | 4 |
| 4 | Caballero Cazadragones | 120.000 | 120 | ×24 | 7 / 1,2 | 5 · 3 círculos · 8 · 1,1 s · 28 | 3 |
| 5 | Titán de Magma | 800.000 | 300 | ×26 | 8 / 1,4 | 5 · pisotón: anillo que se expande · 11 · 1,0 s · 32 | 2 |
| Cráter | 👑 **Rey Volcán** | (todos) | 1.000 base | escala con el servidor | 8 / 1,2 | lluvia de 6–10 círculos; fase 2 al 50 % | 1 (evento) |

La vida es «×Poder recomendado». Por ejemplo, la Lagartija tiene 10 × 20 = 200 de vida.

## Aspecto y animación

| Monstruo | Aspecto | Animaciones clave |
|---|---|---|
| Lagartija | Pequeña, verde oliva, ojos amarillos | Corretea, cola que se menea, mordisco rápido |
| Salamandra | Naranja con manchas brillantes, **cola en llamas** | Ondula, la llama parpadea, escupe brasas |
| Gólem de lava | Rocas oscuras con **grietas de lava** que laten | Pasos pesados (temblor), golpe a dos manos |
| Serpiente de fuego | Cuerpo segmentado con fuego | Ondulación continua, latigazo |
| Murciélago Ígneo | Alas membranosas encendidas | Aleteo rápido, picado en línea |
| Caballero Cazadragones | Armadura plateada, espada brillante, escudo | Guardia, tajo, se cubre con el escudo |
| Titán de Magma | Gólem gigante con aura de fuego | Respiración profunda, pisotón con onda expansiva |
| 👑 Rey Volcán | Coloso de magma con corona de obsidiana, mitad dentro del cráter | Emerge, rugido, brazos que golpean el suelo, fase 2 al rojo vivo |

Todos se generan con IA (ver [[Arte-IA]]). Mientras no exista el modelo, se usa la versión provisional hecha con piezas por código (ya programada en `EnemyVisuals`).
