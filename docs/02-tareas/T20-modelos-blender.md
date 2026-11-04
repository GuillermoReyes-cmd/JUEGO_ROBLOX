---
tarea: T20
responsable: Claude
estado: En curso (Draco hecho)
actualizado: 2026-11-04
---

# T20: Dragones de bloques hechos con Blender

Volver a [[TABLERO]] · Estilo: [[Partida-Montar-un-dinosaurio]] · Decisión: [[Decisiones#D-022 Dragones por script en Blender]]

## Por qué Blender y no IA
- **Los modelos de IA de Studio salen de una sola pieza:** no se pueden animar por partes y cada uno tiene un estilo distinto.
- **Con un script de Blender:**
  - todas las especies comparten el **mismo estilo** (bloques con tachuelas, como «Montar un dinosaurio»);
  - cada parte (cuerpo, cabeza, alas, patas, cola) sale **separada**, así que `DragonController` la anima igual que a los dragones provisionales.

## Cómo se hace una especie (proceso)
1. **Blender (Claude, sin abrirlo):**
   - `blender -b -P tools/blender/draco_bloques.py -- tools/blender/salida`;
   - produce `Draco.fbx`, `Draco_rig.json` (puntos de giro) y dos vistas previas `.png`.
   - Los colores están en el bloque `COLORS` del script: cambiándolos sale otra variante.
2. **Studio (Guillermo):**
   - Inicio → **Importar 3D** → elegir el `.fbx`;
   - marcar **Anclado** y pulsar **Importar**. Aparece en Workspace.
3. **Montaje (Claude, por MCP):**
   - colorea cada pieza por su sufijo (`Head__Bone` → color Bone; ojos en Neon);
   - guarda las articulaciones como atributos;
   - lo mueve a `ReplicatedStorage.Assets.Dragons.<Id>.Rig`.
4. **Guardar el lugar** (Guillermo, Ctrl+S): los modelos viven en el archivo del lugar, no en Git.

## Formato «Rig» (lo lee `DragonBuilder`)
- **`Assets.Dragons.<Id>.Rig`:** `Model` con MeshParts `<Articulación>__<Color>`, cada una con el atributo `Joint`.
- **Atributos del Rig** (en su espacio: frente = -Z, suelo = Y 0):
  - `<Articulación>_Parent` (Root, Body, Tail1…);
  - `<Articulación>_Pivot` (Vector3);
  - `MouthPivot` y `SaddlePivot`;
  - `BodyLength` (largo de referencia para escalar con `species.Size`; el Draco usa 16).
- **Al construir:** en cada articulación, la pieza mayor (o `__Body`) es la principal y las demás se sueldan a ella. Los `Motor6D` se crean con los nombres del contrato de T18.
- **Ojo con izquierda y derecha:** en Blender el dragón mira a -Y, así que su «L» queda en +X de Roblox. El montaje intercambia L y R.

## Estado
| Especie | Blender | Importado | En el juego |
|---|---|---|---|
| Draco (rojo fuego) | ✅ v6 | ✅ | ✅ Probado en un corral el 2026-11-04: 14 articulaciones, mira a la entrada y se anima |
| Resto (Lindwurm, Guiverno, Anfíptero, Lung, Hidra, Níðhöggr…) | ⏳ | — | — |

**Siguiente:** generar las demás especies cambiando piezas y colores (cuello en serpiente para el Lung, tres cabezas para la Hidra…). Cada una necesita un **Importar 3D** de Guillermo.
