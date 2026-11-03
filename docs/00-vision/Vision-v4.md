---
tipo: diseño
version: 4
estado: aprobada (2026-11-03)
actualizado: 2026-11-03
---

# 🥚 Visión v4: «Roba un Huevo de Dragón»

Volver a [[INICIO]] · Decisión en [[Decisiones#D-021 Giro a «roba un huevo» con montar dragones]] · Versión anterior: [[Vision-v3]]

> **Por qué cambiamos:** la v3 tenía muchos sistemas (entrenar, combate, evolución, jefe, duelos), pero **no tenía un objetivo claro** que se entienda en 5 segundos.
>
> Los juegos que más triunfan ahora mismo sí lo tienen: «Roba un huevo», «Roba una mascota y móntala» y «Montar un dinosaurio». Su objetivo es **coger algo valioso, llevarlo a tu casa y que te haga rico**. La v4 copia esa **estructura** (no sus nombres ni su arte), con lo que a Guillermo le gusta de «Montar un dinosaurio»: **montar criaturas grandes con animaciones vistosas**.

## 1. El objetivo en una frase
> **Cuélate en los nidos de las dragonas, róbales los huevos, llévalos a tu guarida, haz que eclosionen y monta a tus dragones. Cuanto más raro el dragón, más oro te da… y más querrán robártelo los demás.**

Esto es lo que debe entender un niño en los primeros 10 segundos. Todo lo demás está al servicio de esta frase.

## 2. La fantasía
> «Me acerqué de puntillas al nido del Volcán. La dragona roja dormía. Cogí el huevo dorado, se despertó rugiendo y salí al galope montado en mi guiverno. Llegué a mi guarida por los pelos. Eclosionó un **Lung Arcoíris**: ¡1 entre 5.000! Ahora me da 2.000 de oro por segundo… y tengo que cerrar la puerta porque otro jugador viene a por mis huevos.»

## 3. Bucle principal

```
1. SALIR ─── montado en tu mejor dragón (va más rápido que a pie)
     │
     ▼
2. ROBAR ─── en cada bioma hay nidos con una DRAGONA MADRE DORMIDA
     │        mantén E sobre un huevo → si haces ruido se despierta y te persigue
     ▼
3. HUIR ──── llevas el huevo a cuestas (vas algo más lento)
     │        si la madre te alcanza → sueltas el huevo; otros jugadores también pueden quitártelo
     ▼
4. INCUBAR ─ lo pones en una incubadora de tu guarida → eclosiona en X minutos (también desconectado)
     │
     ▼
5. ECLOSIÓN  sale un dragón: ESPECIE + RAREZA + MUTACIÓN (con animación de revelado)
     │
     ▼
6. GANAR ─── los dragones de tus corrales dan 💰 oro por segundo
     │
     ▼
7. MEJORAR ─ con oro: más incubadoras, más corrales, más velocidad, mejores monturas
     │        → puedes llegar a nidos más lejanos, con huevos más raros
     └──────▶ vuelta al 1
```

**Bucle largo:**
- **Renacer:** reinicias el oro y las mejoras, pero conservas tus dragones y ganas un multiplicador de oro permanente. Además, desbloquea nidos de nivel superior.
- **Colección:** el **Dragonario** (álbum de especies × mutaciones) te da algo que completar.

## 4. Lo que ve el jugador

**El mapa: una carretera de guaridas y un camino de biomas** (estructura probada en «Roba un huevo»):

```
 [Guarida 1] [Guarida 2] [Guarida 3] [Guarida 4]
 ════════════ PLAZA (tienda, Dragonario) ════════════▶ camino de biomas
 [Guarida 5] [Guarida 6] [Guarida 7] [Guarida 8]

 Prado ▶ Bosque ▶ Desierto ▶ Glaciar ▶ Volcán ▶ Islas del Cielo (volando)
 común                                               mítico / divino
```

- **Servidor de 8 jugadores.** Cada uno recibe una **guarida** al entrar, con su nombre y sus dragones a la vista de todos (el escaparate social).
- **Cada bioma tiene varios nidos.** Cuanto más lejos está el bioma, más raros son los huevos, más rápida es la madre y menos tarda en despertarse.
- **Tu avatar de Roblox monta a tu dragón,** con silla y riendas, como en «Montar un dinosaurio».

## 5. Sistemas

### 5.1 Nidos y dragonas madre (el corazón del juego)
- **Cada nido** tiene de 1 a 3 huevos y una **dragona madre dormida** (un modelo grande que respira y ronca).
- **Barra de sueño de la madre.** Se llena más rápido si:
  - corres cerca de ella,
  - vas montado,
  - o hay varios ladrones a la vez.
  - Si vas agachado o despacio, apenas sube.
- **Robar:** mantener **E** durante 1,5 s sobre un huevo.
- **Si se despierta:**
  - ruge y te persigue hasta el límite de su territorio.
  - Si te alcanza, **sueltas el huevo** (vuelve al nido) y sales despedido.
  - Pasados unos segundos sin ladrones, se vuelve a dormir.
- **Los huevos reaparecen** en el nido tras un tiempo. El nido muestra un contador.
- **Técnica:** se reutiliza la IA de los monstruos de T21 (perseguir, correa, volver a casa). Ver §8.

### 5.2 Llevar el huevo
- El huevo va **a la espalda**, y se ve desde lejos con un brillo del color de su rareza.
- **Pesa:**
  - un huevo común te frena un 5 %; uno divino, un 30 %.
  - Las monturas buenas compensan el peso.
- **Otros jugadores pueden quitártelo:** con el **empujón** (tecla F, recarga de 3 s), sueltas el huevo y cualquiera lo recoge.
- Solo puedes llevar **un huevo** a la vez (con un pase de juego, dos).

### 5.3 Guarida
- **Incubadoras:** al principio 2; con mejoras, hasta 8. Cada huevo muestra encima su cuenta atrás.
- **Corrales:**
  - al principio 3 dragones expuestos; con mejoras, hasta 12.
  - Los dragones de los corrales **generan oro por segundo**, que se acumula en la **placa de cobro** de la guarida.
  - Los demás dragones esperan en el **establo** (inventario) y no generan oro.
- **Puerta de la guarida:**
  - un botón la cierra 60 s; luego tiene 30 s de recarga.
  - Mientras está abierta, **otros jugadores pueden entrar y robar huevos de tus incubadoras**.
- **Los dragones ya eclosionados no se pueden robar.** Decisión deliberada:
  - perder un dragón conseguido (o comprado) frustra mucho a los niños y genera reembolsos.
  - Lo robable son los **huevos en incubación**: duele, pero no destroza.

### 5.4 Eclosión, rarezas y mutaciones
- **Al eclosionar**, el huevo tiembla, se agrieta y estalla en luz, con un banner de rareza. Las rarezas altas se anuncian a todo el servidor: es el momento de compartir.
- **Rareza** (la decide el tipo de huevo):

| Rareza | Color | Oro/s base (orientativo) |
|---|---|---|
| Común | gris | 1–5 |
| Raro | azul | 10–30 |
| Épico | morado | 60–150 |
| Legendario | dorado | 400–900 |
| Mítico | rojo | 3.000–6.000 |
| Divino | blanco brillante | 25.000+ |
| Secreto | arcoíris | evento |

- **Mutación** (independiente de la rareza; multiplica el oro):
  - Normal ×1
  - Dorada ×2
  - Diamante ×4
  - Sombra ×6
  - Arcoíris ×10
  - Gigante: tamaño ×1,5 y oro ×3.
- **Probabilidades:**
  - Se muestran **siempre** antes de abrir o comprar (política de Roblox; regla 9 de [[AGENTS]]).
  - Las cifras exactas irán en `Config/Eggs.luau`.

### 5.5 Montar (lo que más gusta de «Montar un dinosaurio»)
- **Eliges cualquier dragón tuyo como montura.** Cada especie tiene:
  - **Velocidad**,
  - **Salto**,
  - y **Vuelo** (solo las especies aladas, y desde el bioma Islas del Cielo).
- **Animaciones procedurales.** Ya tenemos la base en `DragonBuilder` y `DragonController`:
  - ciclo de patas al galope,
  - balanceo del cuerpo y de la cabeza,
  - cola que ondula,
  - alas que se pliegan al correr y baten al saltar.
- **El jinete:**
  - va sentado en la silla (punto `Saddle`, que ya existe) y bota con el paso;
  - sujeta las riendas, que unen la silla con la cabeza.
- **Efectos:**
  - polvo en las patas, líneas de velocidad y rastro de huellas;
  - al acelerar, la cámara se abre un poco.
- **Estelas:** cosmético de pago.

### 5.6 Mejoras con oro
| Mejora | Efecto |
|---|---|
| Incubadora extra | +1 huevo a la vez |
| Corral extra | +1 dragón que genera oro |
| Botas | +velocidad a pie |
| Sigilo | la madre se despierta más despacio |
| Silla | +velocidad de la montura y menos efecto del peso del huevo |
| Radar | señala el nido con el mejor huevo del bioma |

### 5.7 Evento: la Dragona Reina (cada 10 min)
- **Aviso 60 s antes** para todo el servidor: «¡La Dragona Reina ha puesto huevos en el Cráter!»
- **Aparece un nido gigante** con 5 huevos legendarios o mejores, custodiados por una madre que **nunca duerme del todo**.
- **Carrera de todo el servidor:**
  - empujones, persecución y gritos.
  - Es el momento más social y el que más impulsa comprar velocidad.
- **Técnica:** se reutiliza el ciclo de `BossService` (Espera → Aviso → Activo). Ver §8.

### 5.8 Dragonario (colección)
- Un álbum con cada especie × mutación.
- **Completar una página** (un bioma) da un multiplicador de oro permanente pequeño.
- Cada especie tiene una ficha corta con **su leyenda real**: de dónde viene el mito. Eso nos diferencia y es dominio público.

## 6. Especies (solo mitología, dominio público)
Regla 11 de [[AGENTS]] y [[Decisiones#D-014 Sin propiedad intelectual ajena]]. Se amplía la lista de [[Dragones]]:

| Bioma | Especies (rareza aproximada) |
|---|---|
| Prado | Draco (común), Cuélebre (común), Wyvern de granja (raro) |
| Bosque | Lindwurm (común), Zmey (raro), Guiverno (épico) |
| Desierto | Anfíptero (raro), Ouroboros (épico), Basilisco alado (legendario) |
| Glaciar | Dragón de hielo (raro), Fafnir (épico), Lung de escarcha (legendario) |
| Volcán | Tarasca (épico), Hidra (legendario), Bakunawa (mítico) |
| Islas del Cielo | Ryū (legendario), Serpiente emplumada (mítico), Níðhöggr (divino) |
| Evento | Dragona Reina «Secreta» (variantes de evento) |

- **Nada de** Smaug, Drogon, Haku, Shenron ni ningún nombre o diseño de franquicia.
- Los nombres de mitología (Fafnir, Níðhöggr, Ryū…) sí se pueden usar.
- Los diseños son nuestros, generados con IA.

## 7. Monetización (precios reales observados)
Datos del 2026-11-03, sacados de las tiendas de los juegos de referencia (ver §10). Casi todo cae entre **15 y 499 R$**: el punto dulce que buscábamos.

**Pases de juego (pago único):**

| Pase | Precio | Referencia |
|---|---|---|
| ×2 Oro | 199 | «Montar un dinosaurio» 199; «Monta un dragón» 149 |
| VIP (chat, etiqueta, +10 % oro) | 199 | «Roba una mascota y móntala» 199 |
| Llevar 2 huevos | 149 | (nuestro) |
| Auto-cobrar oro | 99 | «Roba una mascota…» 49; «Montar una mascota» 699 |
| Radar infinito | 249 | «Monta un dragón» 99; «Montar una mascota» 399 |

**Productos (consumibles):**

| Producto | Precio |
|---|---|
| Eclosión instantánea | 9 / 25 / 49, según rareza |
| Escudo de guarida (puerta cerrada) | 15 (30 min) / 49 (2 h) |
| Poción de suerte (15 min) | 45 |
| Huevo de evento | ×1 49 · ×3 129 · ×10 399, **con probabilidades visibles** |
| Packs de oro | 25 / 99 / 249 / 499 |
| Pack de inicio (una vez) | 99 |
| Estelas de montura | 19 a 499 |
| Montura voladora exclusiva | 299 a 499 |

- **Sin «pagar para ganar» contra otros:** lo que se compra da comodidad, suerte o estilo.
- **Lo que no se puede comprar:** robar dragones ajenos ni ser invulnerable.

## 8. Qué se reutiliza de lo ya hecho
| Pieza actual | En la v4 | Estado |
|---|---|---|
| `Main`, `DataService`, `Remotes`, `Format`, `DebugService` | Tal cual | ✅ |
| `DragonBuilder` (rigs con articulaciones, `Saddle`, modelos IA por pivote) | Monturas y dragones de los corrales | ✅ se amplía con «modo montado» |
| `DragonController` (animación procedural) | Galope, alas y respiración de monturas y madres | ✅ se amplía con el ciclo de patas |
| `Config/Dragons` (especies y elementos) | Catálogo con rareza, velocidad y bioma | 🔁 se amplía |
| `MobService` (IA perseguir/correa, raíz en servidor, cuerpo en cliente) | Dragonas madre | 🔁 se adapta: dormir → despertar → perseguir |
| `EnemyVisuals` + `MobRegistry` | Cuerpo de las madres en el cliente | ✅ |
| `BossService` (ciclo y avisos) | Evento Dragona Reina | 🔁 cambia el premio: huevos en vez de ranking de daño |
| `StatsService` | Oro, Huevos robados y Renacimientos en la tabla | 🔁 |
| Modelos IA: Huevo y Cría | Huevo base y cría recién nacida | ✅ |
| `TrainService` (+1 por clic) | Se retira | ❌ |
| `DamageService` y `CombatController` (combate) | Se retiran del lanzamiento; quizá vuelvan como modo | ❌ |
| `EvolutionService` (T19, Codex) | Se retira; las especies ahora salen del huevo | ❌ |
| Modelos Lagartija y Salamandra | Fuera | ❌ |

**Resumen:** se conserva más o menos la mitad del código, justo la difícil (rigs, animación, IA, guardado). Lo que se retira sigue en Git por si vuelve.

## 9. Calendario (4 semanas; ajustado pero posible)
Hoy es 3 de noviembre. **Lanzamiento: domingo 30 de noviembre.**

| Semana | Claude | Codex | Guillermo |
|---|---|---|---|
| 1 (4–10 nov) | T30 Guaridas, incubadoras y oro · T31 Nidos y madres | T34 Eclosión, rarezas y mutaciones (`Config/Eggs`) | Probar cada día en Studio |
| 2 (11–17 nov) | T32 Montar (patas, jinete, riendas, efectos) · T33 Robo entre jugadores, empujón y puerta | T35 Mejoras con oro · T13 Tablas de clasificación | Mapa: guaridas + 3 biomas |
| 3 (18–24 nov) | T06 Tienda Robux · T36 Dragona Reina | T37 Renacer · T38 Dragonario | Mapa: 3 biomas más · modelos (Claude los genera) |
| 4 (25–30 nov) | Pulido, rendimiento, pruebas con 8 jugadores | T16 Sonidos e interfaz | Miniatura, icono, publicar (T17) |

- **Navidad (~15 de diciembre):** bioma de Nieve festivo, huevos de Navidad limitados y mutación «Escarcha».
- **Si vamos tarde, se recorta en este orden:** Dragonario → Islas del Cielo (vuelo) → Renacer. **No se recortan nunca** robar, incubar, ganar oro y montar.

## 10. Investigación de referencia (2026-11-03)
Datos sacados de la API pública de Roblox:

| Juego | Creado | Jugadores ahora | Visitas | Me gusta | Lo que aprendemos |
|---|---|---|---|---|---|
| «Montar un dinosaurio» | 24 ago 2026 | ~12.500 | 31 M en 10 semanas | 97 % | Monturas de bloques muy animadas, 9 eras y rancho que da dinero. 1 solo pase (×2 dinero, 199) y 96 productos. |
| «Montar una mascota» | abr 2026 | ~13.000 | 447 M | — | Huevos por el mapa, radar y linternas: productos de 49 a 999. |
| «Roba una mascota y móntala» | 4 oct 2026 | (top) | — | — | **Robar jaulas a jefes dormidos y correr a casa**, que es la base de nuestras madres. 13 pases y granero. |
| «Monta un dragón» | 24 sep 2026 | ~1.100 | — | 85 % | ⚠️ **Competidor directo:** huevos de dragón, robar, incubar y volar. |

**Cómo nos diferenciamos de «Monta un dragón»:**
1. **Dragonas madre dormidas:** tensión de sigilo y persecución en cada robo. Es lo que hace adictivo «Roba una mascota y móntala»; ellos solo recogen huevos del suelo.
2. **Especies de mitología real** con su leyenda en el Dragonario.
3. **Evento de la Dragona Reina** para todo el servidor cada 10 minutos.
4. **Animaciones de montura** al nivel de «Montar un dinosaurio» (patas, jinete, riendas, polvo).

**Estilo visual que gusta a Guillermo («Montar un dinosaurio»):**
- criaturas grandes, de colores planos y saturados, hechas de **bloques gruesos**;
- jinete con silla y riendas;
- cielo azul, césped muy verde;
- efectos exagerados de polvo y velocidad.
- **Propuesta:** dragones *low-poly* de colores vivos, generados con IA y **partidos en piezas** (cuerpo, cabeza, alas, patas, cola) para poder animarlos. Ver [[Arte-IA]].

## 11. Riesgos
- **Calendario ajustado:**
  - el núcleo (robar, incubar, oro, montar) debe funcionar al final de la semana 2;
  - si no, se retrasa el lanzamiento antes que lanzar algo roto.
- **Robo entre jugadores:**
  - puede frustrar si es demasiado fácil;
  - por eso solo se roban huevos, la puerta se puede cerrar y hay escudo.
- **Modelos:**
  - 18 especies más 6 madres son muchos;
  - para el lanzamiento bastan 10 especies con mutaciones de color (las mutaciones solo cambian materiales y colores, sin modelo nuevo).
