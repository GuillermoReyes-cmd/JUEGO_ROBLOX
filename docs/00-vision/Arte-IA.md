---
tipo: guía
sistema: arte 3D con IA
tarea: T20
responsable: Claude (vía Studio MCP) + Guillermo (guardar el lugar)
actualizado: 2026-11-03
---

# 🎨 Modelos 3D con la IA de Roblox Studio

Volver a [[INICIO]] · Dragones en [[Dragones]] · Monstruos en [[Enemigos]]

> **Reparto actualizado (2026-11-03):**
> - **Claude genera los modelos directamente en Studio** a través de la conexión MCP (`generate_mesh`), los revisa con capturas, los coloca en `ReplicatedStorage.Assets` y los prueba en juego.
> - **Guillermo solo tiene que guardar el lugar en Studio (Ctrl+S)**, porque los modelos viven en el archivo del lugar, no en Git.
> - Mientras falte alguno, el juego usa la versión provisional hecha con piezas.

## ✅ Estado de los modelos

| Modelo | Estado | Notas |
|---|---|---|
| `Dragons/Egg/Body` | ✅ En juego | Huevo rojo con escamas y púas; el aura del elemento le da el brillo |
| `Dragons/Hatchling/Body` | ✅ En juego | Cría chibi muy lograda. **Trae las alas integradas** aunque se pidió sin ellas, así que no lleva `Wing` aparte |
| `Enemies/Lagartija` | ✅ En juego (2.º intento) | El 1.º salió de pie y con la cabeza cuadrada. Se regeneró pidiendo «gecko, horizontal, cerca del suelo» |
| `Enemies/Salamandra` | ✅ En juego | Manchas y cola en llamas; venía mirando de lado y se giró −90° |
| Resto de dragones, monstruos y jefe | ⏳ Pendiente | Se generan en las siguientes tandas |

## 🧠 Lo aprendido al generar (para las próximas tandas)
- **Studio debe estar en modo edición.** Si está en Play, la generación falla con «should only be called from the server».
- **Pedir siempre la postura y orientación:** «side view», «horizontal pose», «lying flat». Si no, a veces sale de pie.
- **«WITHOUT wings» no siempre se respeta.** Hay que revisar cada resultado con una captura.
- **Orientación:**
  - El frente debe quedar hacia **−Z**.
  - En los **monstruos** se fija con el `PivotOffset` de la pieza principal: pivote en la base y sin rotación.
  - En los **dragones** se quita el `PrimaryPart` y se fija el `WorldPivot`.
  - `DragonBuilder` ya orienta por el pivote, no por la malla.
- **Tamaño:** los monstruos se escalan al guardarlos (Lagartija 5 studs, Salamandra 7); los dragones los escala el código según `Config/Dragons`.
- Los modelos quedan **publicados en el inventario de Guillermo** (cada generación tiene su `publishedAssetId`).

## 1. Cómo generar un modelo
1. En Studio abre el **Asistente** (pestaña Inicio o Ver → Asistente).
2. Escríbele: **«Generate a 3D model: …»** y pega el texto de la tabla, que está en inglés porque así da mejores resultados.
   - El menú puede variar según tu versión de Studio. Si no ves la opción de generar modelos, dímelo y usamos otra herramienta de IA (por ejemplo Meshy o Tripo), cuyos archivos se importan con **Archivo → Importar 3D**.
3. Si el resultado no te gusta, **genera otra vez**: cada intento sale distinto. Quédate con el que tenga **silueta clara** y colores vivos.
4. Antes de guardarlo, revisa la **lista de comprobación** (sección 4).

### Estilo común
Añade siempre al final del texto:
> `, stylized low-poly game asset, vibrant colors, clean readable silhouette, Roblox game style, single object, no base, no text`

## 2. Dragones (por especie)
- **Las especies con alas** se generan en **2 piezas**: el **cuerpo sin alas** y **una sola ala**. El código pone el ala a cada lado y la hace aletear. Si las alas vinieran pegadas al cuerpo, no se podrían mover.
- **Dónde se guardan:** `ReplicatedStorage › Assets › Dragons › <Id> › Body` (y `Wing`).

| Id | Especie | Pieza | Texto para la IA |
|---|---|---|---|
| `Egg` | Huevo Ardiente | Body | `a dragon egg with glowing orange cracks and small flames, dark red shell` |
| `Hatchling` | Cría de Dragón | Body | `a cute baby dragon without wings, big eyes, chubby body, small horns, red and orange scales, sitting` |
| `Hatchling` | Cría de Dragón | Wing | `a single tiny dragon wing, bat-like membrane, red and orange, flat` |
| `Draco` | Draco de Ceniza | Body | `a wingless four-legged dragon, heavy armored body, grey ash scales with ember cracks, long tail, horned head, walking pose` |
| `Lindwurm` | Lindwurm Escarlata | Body | `a lindworm dragon, long serpent body with only two front legs, no wings, scarlet red scales, spiked back` |
| `Wyvern` | Guiverno Sombrío | Body | `a wyvern dragon body without wings, two strong hind legs, long tail, horned head, dark purple and black scales, standing` |
| `Wyvern` | Guiverno Sombrío | Wing | `a single large bat-like dragon wing, membrane with bony fingers, dark purple and black, flat` |
| `Amphiptere` | Anfíptero Emplumado | Body | `a feathered winged serpent, long legless snake body covered in green and gold feathers, feathered head crest, Aztec inspired` |
| `Amphiptere` | Anfíptero Emplumado | Wing | `a single large feathered wing, green turquoise and gold feathers, flat` |
| `Tianlong` | Tianlong Celestial | Body | `a Chinese eastern dragon, very long serpentine body, four small legs, flowing whiskers and mane, holding a glowing pearl, gold and jade scales` |
| `Western` | Dragón Occidental Ancestral | Body | `a majestic western dragon body without wings, four legs, long neck and tail, big horns, red and gold scales, powerful stance` |
| `Western` | Dragón Occidental Ancestral | Wing | `a single huge western dragon wing, leathery membrane, red with gold edges, flat` |
| `Hydra` | Hidra de Lerna | Body | `a three-headed hydra dragon, three long necks with snake-like heads, four legs, no wings, dark green scales with teal glow` |
| `Nidhogg` | Níðhöggr | Body | `a primordial dark dragon body without wings, black scales with purple glowing runes, roots and thorns on its back, menacing` |
| `Nidhogg` | Níðhöggr | Wing | `a single huge torn dragon wing, black membrane with purple glowing veins, flat` |

## 3. Monstruos
**Dónde se guardan:** `ReplicatedStorage › Assets › Enemies › <Nombre exacto>`.

| Nombre (exacto) | Texto para la IA |
|---|---|
| `Lagartija` | `a small cartoon lizard monster, olive green, yellow eyes, four legs` |
| `Salamandra` | `a fire salamander monster, orange skin with glowing yellow spots, tail tip on fire` |
| `Gólem de lava` | `a lava golem made of dark rocks with glowing orange lava cracks, big arms` |
| `Serpiente de fuego` | `a fire serpent monster, segmented red body with flames, fangs` |
| `Murciélago Ígneo` | `a giant fire bat monster, membrane wings with glowing embers, red eyes` |
| `Caballero Cazadragones` | `a dragon hunter knight, silver plate armor, glowing sword and shield with red emblem` |
| `Titán de Magma` | `a huge magma titan, black obsidian body with rivers of glowing lava, fire aura, massive fists` |
| `Rey Volcán` | `a colossal magma king monster emerging from lava, obsidian crown, molten body, glowing eyes, huge arms` |

## 4. Lista de comprobación antes de guardar
- [ ] **Nombre exacto** según la tabla, dentro de la carpeta correcta.
- [ ] **Mira al frente.** El frente del modelo debe apuntar hacia donde mira la cámara de Studio al crear una pieza; si no, gíralo. Si no estás seguro, déjalo así y el código lo corrige con el atributo `FacingFix`.
- [ ] **Tamaño razonable:** cualquiera sirve, porque el código escala cada especie a su tamaño.
- [ ] **Sin suelo ni base** debajo, y sin texto.
- [ ] **Anclado** (*Anchored*): da igual, el código lo cambia.
- [ ] Si generaste varias versiones, **borra las que no uses**: pesan en el juego.

## 5. Qué hace el código con tus modelos
- **Arma el dragón:**
  - El `Body` es la raíz.
  - El `Wing` se duplica, se coloca a cada lado del lomo y se une con `Motor6D`.
  - Calcula la **boca** (de donde sale el aliento) y la **montura** a partir de la forma del modelo.
- **Anima por código:**
  - Respirar, aletear, ondular (serpientes y orientales) y caminar con rebote.
  - Atacar con anticipación y estirón, recibir golpe y desmayarse.
- **Elemento (renacimiento):** se muestra con **brillo, aura, partículas y estelas** del color del elemento sobre el modelo, no repintándolo. Así un solo modelo sirve para los 5 elementos.

## 6. Orden recomendado (de más a menos impacto)
1. **Primero, lo que todos ven al empezar:** `Egg`, `Hatchling` (cuerpo y ala), `Lagartija` y `Salamandra`.
2. **Después,** `Wyvern`, `Western` y el jefe `Rey Volcán`: son los momentos «wow».
3. **El resto** cuando puedas.
