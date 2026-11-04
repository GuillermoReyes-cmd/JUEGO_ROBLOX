---
tipo: flujo
actualizado: 2026-11-04
---

# 🗺️ Plan de lanzamiento: orden de trabajo Claude + Codex

Volver a [[INICIO]] · Tareas: [[TABLERO]] · Cómo trabajamos: [[FLUJO-CON-CODEX]]

> **Regla acordada con Guillermo (2026-11-04):**
> - Claude y Codex siguen esta cola **en orden y sin preguntar**.
> - Las dudas se resuelven con la opción más sensata y quedan anotadas en [[Decisiones]].
> - Guillermo revisa **al final de cada tanda** y da su opinión.
> - Solo se le pide a Guillermo lo que solo él puede hacer:
>   - pulsar **Connect** en Rojo;
>   - **Importar 3D** en Studio;
>   - aprobar la fusión en `main`;
>   - cualquier cosa con dinero o Robux.

## ⏯️ Cómo reanudar si se acaban los créditos
Todo el progreso queda guardado en GitHub y en esta nota. Nada se pierde: el trabajo a medias está en la rama de su tarea.

**Para Claude** (pegar al volver):
```text
Reanuda el PLAN-LANZAMIENTO (docs/03-flujo/PLAN-LANZAMIENTO.md): mira la cola de Claude, la primera tarea que no esté ✅ es la siguiente. Revisa también las ramas nuevas de Codex e intégralas en integracion/v4. Trabaja sin preguntar y al final enséñame todo.
```

**Para Codex** (pegar al volver):
```text
Codex: reanuda tu cola en docs/03-flujo/PLAN-LANZAMIENTO.md (rama integracion/v4, git fetch primero). Si tenías una tarea a medias, termina esa (su rama y su ficha dicen dónde te quedaste); si no, empieza la primera de la «Cola de Codex» que no tenga rama en origin. Sigue las reglas comunes del plan.
```

## Cómo se integra el trabajo
1. **Cada tarea tiene su rama** (`tarea/TXX-…`). Codex encadena sus ramas: cada una sale de la anterior.
2. **Claude es el integrador.** Revisa cada rama de Codex con la lista de [[CLAUDE]]:
   - archivos permitidos;
   - lógica en el servidor;
   - números en `Config`;
   - sintaxis y build.
3. Si todo está bien, la fusiona en **`integracion/v4`**. Si no, anota el arreglo en la ficha y en la cola de Codex.
4. **Claude prueba `integracion/v4` en Studio por MCP** después de cada fusión.
5. **`main`** solo recibe `integracion/v4` cuando Guillermo lo aprueba tras jugar.

## Cola de Claude (en este orden)
| # | Tarea | Qué entrega | Estado |
|---|---|---|---|
| C1 | Integración | `integracion/v4` = base + T35 + T37 + T38 + T13 (Codex) + T39 + notas de investigación. Revisión de Codex y prueba en Studio | ✅ 2026-11-04 |
| C2 | Draco en el juego (T20) | `DragonBuilder` acepta modelos de varias piezas («Rig»); el Draco de Blender aparece animado en los corrales | ✅ 2026-11-04 |
| C3 | **T31 Nidos y dragonas madre** | Nidos en los biomas, madre dormida con barra de sueño, robar con E, persecución, llevar el huevo y entregarlo en la incubadora | ✅ 2026-11-04 |
| C4 | **T32 Montar** | Montar el mejor dragón (o el elegido), silla, jinete, galope, polvo, velocidad por especie | ✅ 2026-11-04 |
| C5 | **T33 Robo entre jugadores** | Empujón (F), huevo en el suelo, robar de incubadoras ajenas, puerta y escudo | ✅ 2026-11-04 (falta prueba con 2 jugadores) |
| C6 | **T06 Tienda Robux** | Pases y productos; recompensa sin conexión ×3, primera compra barata, regalos, probabilidades visibles | ✅ 2026-11-04 (faltan los ID reales al publicar) |
| C7 | **T36 Dragona Reina** | Evento cada 10 min con nido gigante (al oeste de las guaridas) | ✅ 2026-11-04 |
| C8 | Más especies en Blender (T20) | Una especie por `Kind` con el mismo estilo de bloques. Necesita que Guillermo importe cada `.fbx` | ⏳ siguiente |

## Cola de Codex (copiar y pegar en este orden)
Reglas comunes, que van en cada mensaje:
- leer AGENTS.md y la ficha;
- escribir la ficha antes de programar;
- solo tocar los archivos permitidos;
- `luau` en cada archivo y `rojo build`;
- rellenar «Resultado»;
- actualizar Tablero y Bitácora;
- commit y push;
- **nunca** fusionar.

**No tocar archivos de Claude:** `BaseService`, `IncomeService`, `StableService`, `IncubatorService`, `TutorialService`, `DragonBuilder`, `DragonDisplay`, `DragonController` y lo de T31, T32, T33, T06 y T36.

**Estado de Codex (2026-11-04):** T35, T37, T38, T13 y T16 hechas e integradas. **Siguen:** X1 (T43), X2 (T41) y X4 (T16b, estilo de botones).

> ⚠️ **Cambio para X1, X2 y X4:** crear las ramas desde `origin/integracion/v4` (no desde T13 ni T43), porque ahí ya está todo.

### X1 · T43 «Mundo provisional de biomas»
```text
Codex: tarea T43 «Mundo provisional de biomas». Rama tarea/T43-mundo desde origin/integracion/v4.
Lee AGENTS.md, Vision-v4 §4 y §6, y ARQUITECTURA. Escribe la ficha docs/02-tareas/T43-mundo.md.
Archivos: crear src/server/Services/WorldService.luau y src/shared/Config/World.luau; editar Config/init.luau (1 línea) y docs.
- Si en Workspace hay modelos con la etiqueta «Biome», no construyas nada (el mapa lo hará Guillermo). Si no, construye 6 biomas provisionales en fila a lo largo del eje X, empezando después de las guaridas (mira Config.Base.Layout): Prado, Bosque, Desierto, Glaciar, Volcan, Cielo (los Id de Config.Eggs.Eggs).
- Cada bioma: suelo de su color y material (hierba, arena, hielo, roca volcánica…), 20-40 decoraciones simples de bloques (árboles, rocas, cactus, cristales de hielo, rocas de lava) hechas con Parts y pocas piezas, un arco de entrada con el nombre del bioma (BillboardGui o SurfaceGui), y un camino central.
- Cielo: islas flotantes más altas unidas por rampas (todavía no se vuela).
- Ojo: Claude ya hizo los nidos (T31). Mientras no haya «NestSpawn», NestService crea nidos provisionales en X ≥ 200 en una carpeta «NidosProvisionales». No hace falta borrarla: en cuanto existan tus NestSpawn, ya no se crea. Coloca tus biomas también desde X ≈ 200 y deja libre la zona X ≈ −190 (evento de la Reina, T36).
- En cada bioma, 4 puntos de nido: Parts invisibles, anclados, sin colisión, con la etiqueta «NestSpawn» y los atributos Biome = "<Id>" y Index = 1..4. Separados entre sí al menos 25 studs.
- Cada modelo de bioma con la etiqueta «Biome» y los atributos Biome = "<Id>" y Order = 1..6, y ModelStreamingMode = Atomic.
- Construye en tandas con task.wait() para no congelar el servidor. Todos los números en Config/World.
- Prueba en Studio: los 6 biomas aparecen, hay 24 NestSpawn con sus atributos y no hay errores en Output.
Commit «T43: mundo provisional de biomas» y push. No hagas merge.
```

### X2 · T41 «Día y noche»
```text
Codex: tarea T41 «Ciclo de día y noche». Rama tarea/T41-dia-noche desde origin/integracion/v4.
Escribe la ficha docs/02-tareas/T41-dia-noche.md.
Archivos: crear src/server/Services/DayNightService.luau, src/client/DayNightController.client.luau y src/shared/Config/DayNight.luau; editar Config/init.luau (1 línea) y docs.
- El servidor manda el ciclo: día 8 min y noche 3 min (Config). Pone los atributos de ReplicatedStorage IsNight (bool) y PhaseEndsAt (hora del servidor).
- El cliente cambia Lighting con tweens suaves (ClockTime, Ambient, OutdoorAmbient y un Atmosphere) y muestra abajo a la derecha «🌙 en 2m 30s» o «☀️ en 5m 10s», como en «Montar un dinosaurio».
- No toques otros sistemas: T31 leerá IsNight (de noche las madres duermen más profundo).
Commit «T41: día y noche» y push. No hagas merge.
```

### X3 · T16 «Novedades»
```text
Codex: tarea T16a «Novedades e indicadores». Rama tarea/T16-novedades desde origin/tarea/T41-dia-noche.
Escribe la ficha docs/02-tareas/T16-novedades.md.
Archivos: crear src/client/NewsController.client.luau, src/server/Services/NewsService.luau y src/shared/Config/News.luau; editar Config/init.luau (1 línea) y docs.
- Ventana «Novedades» que se abre sola al entrar si Config.News.Version es mayor que el dato NewsSeen del jugador (NewsService lo guarda; remote «NewsSeen»).
- Secciones con título, emoji y texto (en Config/News), con scroll. ActiveModal = "News".
- Primera versión: presentación del juego, cómo se juega en 5 líneas y «próximamente: Navidad».
Commit «T16: novedades» y push. No hagas merge.
```

### X4 · Arreglos de revisión
Claude añadirá aquí los arreglos que encuentre al revisar las ramas de Codex.

**Revisión del 2026-11-04 (T35, T37, T38, T13): aprobadas.** Respetan sus archivos, validan en el servidor y usan Config. Arreglos de estilo para cuando Codex haga T16 (pulido):

```text
Codex: tarea T16b «Estilo común de botones». Rama tarea/T16-estilo desde origin/integracion/v4.
Archivos: UpgradeController, DexController, RebirthController (solo la parte visual) y docs.
- Los botones laterales «Mejoras», «Dragonario» y «Renacer» deben verse como «🐉 Establo» (StableController): 200×48 px, esquinas redondeadas de 8 px, fuente FredokaOne en grande (TextScaled), un emoji delante (⬆️ Mejoras, 📖 Dragonario, 🔁 Renacer) y su color propio (verde, azul, morado).
- Un «!» rojo en la esquina del botón cuando haya algo pendiente: Dragonario con DexPending > 0; Mejoras cuando alcance el oro para alguna mejora; Renacer cuando alcance el oro para renacer.
Commit «T16b: estilo común de botones» y push.
```

## Lo que hace Guillermo (cuando Claude lo pida)
- Conectar Rojo (puerto **34872**) en Studio cuando se le avise.
- Importar en Studio los `.fbx` de dragones nuevos (Inicio → Importar 3D, marcando «Anclado»).
- Jugar `integracion/v4` al final de cada tanda y dar su opinión.
- Guardar el lugar en Studio (Ctrl+S) después de importar modelos.
