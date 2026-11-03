---
tarea: T34
responsable: Codex
rama: tarea/T34-huevos (desde origin/integracion/lanzamiento)
estado: Pendiente
depende_de: —
actualizado: 2026-11-03
---

# T34: Huevos, rarezas, mutaciones y eclosión

**Responsable:** Codex · **Rama:** `tarea/T34-huevos`, **creada desde `origin/integracion/lanzamiento`** · **Estado:** Pendiente

Diseño: [[Vision-v4]] (§5.4 eclosión, §6 especies, §7 probabilidades visibles) · Arquitectura: [[ARQUITECTURA]] · Reglas: [[AGENTS]]

## Objetivo
Construir **todo lo que pasa cuando un huevo eclosiona**, aislado del resto del juego:
- el catálogo de huevos y especies;
- la tirada en el servidor (especie + mutación + gigante);
- el panel que **muestra las probabilidades** antes de abrir o comprar (obligatorio por política de Roblox);
- la **animación de revelado**: el huevo tiembla, se agrieta, estalla en luz y aparece la carta del dragón.

Las incubadoras, la guarida y el guardado de los dragones los hace Claude en **T30**, que llamará a tus módulos. Por eso tus módulos deben cumplir **exactamente el contrato** de abajo.

## Contexto (qué ya existe)
- **El juego cambió a la v4,** «Roba un Huevo de Dragón». Lee [[Vision-v4]] entero antes de empezar.
- **El dragón provisional** se construye con `DragonBuilder` según su `Kind`. Kinds válidos: `Egg`, `Hatchling`, `Draco`, `Lindwurm`, `Wyvern`, `Amphiptere`, `Tianlong`, `Western`, `Hydra`, `Nidhogg`. Tú no construyes modelos: solo guardas el `Kind` en el catálogo.
- **Modelo IA del huevo:** puede existir `ReplicatedStorage.Assets.Dragons.Egg.Body` (un `Model`). Úsalo en el revelado si existe; si no, usa una esfera provisional.
- **`Remotes.Get(nombre)`** crea u obtiene los RemoteEvents. **`Format`** (`src/shared/Format.luau`) formatea números grandes.
- **Contrato `PlayerGui.ActiveModal`:** solo una ventana abierta a la vez. Míralo en `EvolutionController.client.luau`, que sirve de referencia de estilo y de cinemática. Ese archivo se va a retirar: **no lo edites**.
- **Estilo de interfaz:**
  - fuente FredokaOne, fondos oscuros semitransparentes y esquinas redondeadas;
  - borde del color de la rareza.

## Archivos permitidos
- **Crear:**
  - `src/shared/Config/Eggs.luau`: rarezas, mutaciones y huevos.
  - `src/shared/Config/Species.luau`: catálogo de especies de la v4.
  - `src/shared/EggOdds.luau`: cálculo de probabilidades, compartido entre servidor y cliente.
  - `src/server/Eggs/EggRoller.luau`: la tirada, solo en el servidor.
  - `src/server/Services/EggDebugService.luau`: comandos de prueba, solo en Studio.
  - `src/client/EggOddsGui.luau`: ModuleScript con el panel de probabilidades.
  - `src/client/HatchReveal.client.luau`: revelado y aviso a todo el servidor.
- **Editar:**
  - `src/shared/Config/init.luau`: **solo** añadir `Config.Eggs = require(script.Eggs)` y `Config.Species = require(script.Species)`, y actualizar el comentario de uso. Nada más.
  - `docs/01-arquitectura/ARQUITECTURA.md`: módulos, remotes y contrato de dragón.
  - Esta ficha.
  - `docs/02-tareas/TABLERO.md`: tu estado.
  - `docs/04-bitacora/Bitacora.md`: tu entrada.
- **Solo lectura:** todo lo demás, incluidos `Config/Dragons.luau`, `DragonBuilder`, `DebugService` y el núcleo.

## Contrato (T30 depende de esto: respeta nombres y formas)

### `EggOdds` (ReplicatedStorage.Shared.EggOdds)
Funciones puras, sin estado. Usan `Config.Eggs` y `Config.Species`:

| Función | Devuelve |
|---|---|
| `EggOdds.GetEgg(eggId)` | La entrada del huevo, o `nil` |
| `EggOdds.GetSpecies(speciesId)` | La entrada de la especie, o `nil` |
| `EggOdds.GetRarity(rarityIndex)` | La entrada de la rareza |
| `EggOdds.GetMutation(mutationId)` | La entrada de la mutación |
| `EggOdds.GetSpeciesOdds(eggId, luck?)` | Lista `{ SpeciesId, Name, Rarity, Chance }` ordenada de más a menos probable. Las `Chance` suman 1 |
| `EggOdds.GetMutationOdds(luck?)` | Lista `{ Id, Name, Multiplier, Chance }`. Suman 1 |
| `EggOdds.GetGiantChance(luck?)` | Número entre 0 y 1 |
| `EggOdds.GetGoldPerSecond(speciesId, mutationId, giant)` | `BaseGold × Multiplier de la mutación × (giant and GiantGoldMultiplier or 1)` |
| `EggOdds.GetHatchSeconds(eggId)` | Segundos de incubación |
| `EggOdds.FormatChance(chance)` | Texto: `"35 %"`, `"1,5 %"` y, por debajo del 1 %, también `"1 entre 2.000"`. Coma decimal |
| `EggOdds.Validate()` | Lanza `error` si algo del catálogo está mal (ver requisito 2) |

**Regla de la suerte** (`luck`, por defecto 1, limitada a `[1, Config.Eggs.MaxLuck]`):
- **Especies:** el peso de las especies de rareza `>= Config.Eggs.LuckFromRarity` se multiplica por `luck`; luego se normaliza.
- **Mutaciones:**
  - la probabilidad de cada mutación que no sea `Normal` se multiplica por `luck`;
  - `Normal` es lo que falta hasta 1, pero nunca menos de `Config.Eggs.MinNormalChance`;
  - si se pasara de ese mínimo, se reescalan las demás para que todo sume 1.
- **Gigante:** `min(GiantChance × luck, Config.Eggs.MaxGiantChance)`.

### `EggRoller` (ServerScriptService.Server.Eggs.EggRoller)
| Función | Devuelve |
|---|---|
| `EggRoller.Roll(eggId, luck?, rng?)` | `{ SpeciesId, Mutation, Giant }`, o `nil` si el huevo no existe. `rng` es un `Random`; si no se pasa, usa uno propio |
| `EggRoller.MakeDragon(roll)` | El registro que T30 guardará: `{ Id = HttpService:GenerateGUID(false), SpeciesId, Mutation, Giant, HatchedAt = os.time() }` |

- **La tirada usa las mismas probabilidades** que `EggOdds.GetSpeciesOdds`, `GetMutationOdds` y `GetGiantChance`. Lo que se muestra es lo que sale.

### Remotes
- **`Hatched`** (servidor → todos):
  - Datos: `{ UserId, DisplayName, EggId, SpeciesId, Mutation, Giant }`.
  - El cliente saca el resto (nombre, rareza, color, oro/s) de `Config` con `EggOdds`.
  - **En el juego real lo disparará T30.** En esta tarea solo lo dispara `EggDebugService`.
- **`ShowEggOdds`** (servidor → un cliente):
  - Datos: `eggId`.
  - Abre el panel de probabilidades.
  - T30 y T31 lo usarán al mirar un huevo en un nido o en una incubadora.

### `EggOddsGui` (módulo de cliente)
- `EggOddsGui.Show(eggId, luck?)` y `EggOddsGui.Hide()`.
- Usa `ActiveModal = "EggOdds"`.

## Requisitos
1. **`Config/Species.luau`.** Lista con, por cada especie:
   - `Id` (ASCII, PascalCase), `Name`, `Rarity` (índice), `Biome`, `Kind`, `BaseGold`, `Color`, `Accent`;
   - `Myth`: **una frase**, verdadera y breve, sobre el origen de la leyenda (por ejemplo: «Dragón de la mitología asturiana que guarda tesoros en cuevas»).
   - **Prohibido** cualquier nombre o diseño de franquicia (regla 11 de [[AGENTS]]).

| Id | Name | Rareza | Bioma | Kind | BaseGold |
|---|---|---|---|---|---|
| Draco | Draco | 1 Común | Prado | Draco | 2 |
| Cuelebre | Cuélebre | 1 Común | Prado | Lindwurm | 3 |
| Guivernillo | Guivernillo | 2 Raro | Prado | Wyvern | 12 |
| Lindwurm | Lindwurm | 1 Común | Bosque | Lindwurm | 5 |
| Zmey | Zmey | 2 Raro | Bosque | Western | 20 |
| Guiverno | Guiverno | 3 Épico | Bosque | Wyvern | 80 |
| Anfiptero | Anfíptero | 2 Raro | Desierto | Amphiptere | 30 |
| Ouroboros | Ouroboros | 3 Épico | Desierto | Lindwurm | 120 |
| Basilisco | Basilisco Alado | 4 Legendario | Desierto | Draco | 450 |
| DragonHielo | Dragón de Hielo | 2 Raro | Glaciar | Western | 45 |
| Fafnir | Fafnir | 3 Épico | Glaciar | Western | 180 |
| LungEscarcha | Lung de Escarcha | 4 Legendario | Glaciar | Tianlong | 650 |
| Tarasca | Tarasca | 3 Épico | Volcán | Draco | 250 |
| Hidra | Hidra | 4 Legendario | Volcán | Hydra | 900 |
| Bakunawa | Bakunawa | 5 Mítico | Volcán | Tianlong | 3500 |
| Ryu | Ryū | 4 Legendario | Cielo | Tianlong | 1200 |
| SerpienteEmplumada | Serpiente Emplumada | 5 Mítico | Cielo | Amphiptere | 5000 |
| Nidhogg | Níðhöggr | 6 Divino | Cielo | Nidhogg | 25000 |
| ReinaDorada | Reina Dorada | 7 Secreto | Evento | Western | 60000 |

   - `Color` y `Accent`: elígelos tú, que encajen con el bioma (hielo azulado, volcán rojo y negro…).

2. **`Config/Eggs.luau`:**
   - **`Rarities`** (el índice es el orden). Cada una: `Name`, `Color`.

     | # | Name | Color |
     |---|---|---|
     | 1 | Común | 170, 170, 170 |
     | 2 | Raro | 60, 140, 255 |
     | 3 | Épico | 170, 70, 255 |
     | 4 | Legendario | 255, 190, 40 |
     | 5 | Mítico | 255, 60, 60 |
     | 6 | Divino | 255, 250, 235 |
     | 7 | Secreto | 255, 80, 200; el cliente lo anima en arcoíris |

   - **`Mutations`.** Cada una: `Id`, `Name`, `Multiplier`, `Chance` y `Color` (para la insignia).

     | Id | Name | Multiplier | Chance |
     |---|---|---|---|
     | Normal | Normal | 1 | el resto |
     | Gold | Dorada | 2 | 0,08 |
     | Diamond | Diamante | 4 | 0,03 |
     | Shadow | Sombra | 6 | 0,015 |
     | Rainbow | Arcoíris | 10 | 0,005 |

   - **Gigante:** `GiantChance = 0.02`, `GiantGoldMultiplier = 3`, `GiantScale = 1.5`, `MaxGiantChance = 0.2`.
   - **Suerte:** `MaxLuck = 10`, `LuckFromRarity = 2`, `MinNormalChance = 0.5`.
   - **Avisos:** `AnnounceFromRarity = 4`. Desde Legendario, o con mutación Arcoíris, se avisa a todo el servidor.
   - **`Eggs`.** Cada huevo: `Id`, `Name`, `Biome`, `Color`, `HatchSeconds`, `CarrySlow` (lo que frena al llevarlo; lo usará T31) y `Pool` = `{ { SpeciesId, Weight } }`.

     | Id | Name | HatchSeconds | CarrySlow | Pool (especie = peso) |
     |---|---|---|---|---|
     | Prado | Huevo del Prado | 30 | 0.05 | Draco 60, Cuelebre 35, Guivernillo 5 |
     | Bosque | Huevo del Bosque | 60 | 0.08 | Lindwurm 60, Zmey 32, Guiverno 8 |
     | Desierto | Huevo del Desierto | 120 | 0.12 | Anfiptero 60, Ouroboros 33, Basilisco 7 |
     | Glaciar | Huevo del Glaciar | 240 | 0.16 | DragonHielo 60, Fafnir 33, LungEscarcha 7 |
     | Volcan | Huevo del Volcán | 480 | 0.22 | Tarasca 60, Hidra 33, Bakunawa 7 |
     | Cielo | Huevo del Cielo | 900 | 0.30 | Ryu 60, SerpienteEmplumada 35, Nidhogg 5 |
     | Real | Huevo Real | 600 | 0.30 | Hidra 40, Bakunawa 30, SerpienteEmplumada 20, Nidhogg 9, ReinaDorada 1 |

   - **`EggOdds.Validate()`** comprueba que:
     - cada `SpeciesId` de los pools existe;
     - cada `Kind` es uno de los válidos;
     - no hay `Id` repetidos;
     - los pesos son > 0;
     - las mutaciones (sin contar `Normal`) suman menos que `1 - MinNormalChance`.

3. **`EggRoller`:**
   - tirada ponderada con el `Random` recibido, para poder repetirla en las pruebas;
   - sin `wait` y sin efectos secundarios. Solo calcula.

4. **Panel de probabilidades (`EggOddsGui`):**
   - Muestra:
     - nombre y color del huevo, bioma y tiempo de incubación («Eclosiona en 4 min»);
     - una fila por especie, con insignia de rareza de su color, nombre y probabilidad (`FormatChance`);
     - las mutaciones con su ×multiplicador y su probabilidad, y la fila «Gigante (×3 oro)»;
     - si `luck > 1`, la nota «Con tu suerte ×N».
   - Botón de cerrar. Se lee bien en móvil (escala con `UIScale` o tamaños relativos).
   - `HatchReveal.client.luau` escucha `ShowEggOdds` y llama a `EggOddsGui.Show`.

5. **Revelado (`HatchReveal.client.luau`), solo para el dueño (`UserId == LocalPlayer`):**
   - Pantalla oscurecida y un `ViewportFrame` con el huevo: copia de `Assets.Dragons.Egg.Body` teñida del color del huevo, o esfera provisional.
   - **Unos 2 s de tensión:** el huevo tiembla cada vez más, salen grietas (líneas o imágenes sobre el visor) y un brillo del color de la rareza.
   - **Estallido:** destello blanco y partículas del color de la rareza.
   - **Carta:**
     - nombre de la especie, insignia de rareza, insignia de mutación (si no es Normal) y «GIGANTE» si toca;
     - «+X 💰/s» con `Format`;
     - la frase `Myth`;
     - un retrato con `Color`/`Accent` (como hizo T19). Si te ves capaz, una vista 3D; si no, el retrato vale.
   - Botón «¡Genial!» que cierra.
   - **Ritmo según la rareza:** cuanto más rara, más larga la tensión y más fuerte el destello (los números van en `Config/Eggs`, por ejemplo `RevealSeconds` por rareza).
   - **Varias eclosiones seguidas se ponen en cola.** Usa `ActiveModal = "Hatch"`.
   - **Secreto:** borde y texto con el color animado en arcoíris.

6. **Aviso a todos:**
   - Si la rareza es `>= AnnounceFromRarity` o la mutación es `Rainbow`, **todos** ven arriba un banner de 4 s: «🥚 <Nombre> sacó <ESPECIE> <Rareza>!», con el color de la rareza.
   - Varios avisos se ponen en cola.
   - **Ojo con las mayúsculas:** `string.upper` estropea las letras con tilde («CRíA»). Usa `utf8` o deja el texto sin pasar a mayúsculas.

7. **`EggDebugService`** (solo hace algo si `RunService:IsStudio()`):
   - **Al arrancar** llama a `EggOdds.Validate()`.
   - **`/huevo <EggId> [veces]`:**
     - tira el huevo `veces` veces (por defecto 1, máximo 10.000);
     - imprime en Output una tabla con lo que salió frente a lo esperado, por especie y por mutación;
     - dispara `Hatched` con la última tirada.
   - **`/probs <EggId>`:** dispara `ShowEggOdds` a ese jugador.
   - **`/suerte <N>`:** guarda la suerte de prueba en el atributo `DebugLuck` del jugador. `/huevo` y `/probs` la usan.
   - **No toques `DebugService`.** Su patrón solo acepta números, así que no choca con estos comandos.

## Criterios de aceptación (cómo se prueba en Studio)
- [ ] Al darle a Play no hay errores en Output y `Validate` pasa.
- [ ] `/probs Prado` abre el panel: Draco 60 %, Cuélebre 35 %, Guivernillo 5 %, las mutaciones (Normal 87 %…) y Gigante 2 %.
- [ ] `/suerte 3` y luego `/probs Prado`: suben Guivernillo y las mutaciones; todo sigue sumando 100 %.
- [ ] `/huevo Prado`: se ve el revelado completo y la carta con oro/s, que es correcto (por ejemplo, un Draco Dorado da 4/s).
- [ ] `/huevo Cielo 10000`: en la tabla de Output, lo que salió se parece a lo esperado (±1 punto en las especies comunes).
- [ ] `/huevo Real` varias veces seguidas: los revelados se ponen en cola, sin solaparse.
- [ ] Con 2 jugadores (Test → Servidor local con 2 clientes): una Hidra (Legendario) muestra el banner al otro jugador, y un Draco Normal no.
- [ ] Panel y revelado se ven bien en el emulador de móvil.
- [ ] Sintaxis correcta (`luau` en cada archivo) y `rojo build default.project.json -o build.rbxlx` funciona.

## Fuera de alcance
- Incubadoras, guarida, inventario de dragones y guardado: **T30, Claude**.
- Nidos, madres y llevar huevos: T31.
- Comprar huevos o suerte con Robux: T06.
- Dragonario: T38.
- Modelos 3D.
- Cambiar `Config/Dragons.luau` o `DragonBuilder`.

## Bloqueos
(vacío)

## Resultado
Lo rellena Codex al terminar: qué hizo, cómo probarlo y qué quedó pendiente.
