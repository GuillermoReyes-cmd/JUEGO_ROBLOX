---
tarea: T30
responsable: Claude
rama: tarea/T30-guaridas (desde integracion/lanzamiento)
estado: En revisión
depende_de: T34 (contrato EggOdds / EggRoller)
actualizado: 2026-11-03
---

# T30: Guaridas, incubadoras, corrales y oro

**Responsable:** Claude · **Rama:** `tarea/T30-guaridas` · **Estado:** En revisión

Diseño: [[Vision-v4]] §5.3 (guarida) y §5.4 (eclosión) · Contrato de huevos: [[T34-huevos-eclosion]] · Arquitectura: [[ARQUITECTURA]]

## Objetivo
Al entrar, cada jugador recibe **su guarida**. Allí:
- pone huevos en las **incubadoras** y, cuando acaban, los **eclosiona**;
- los dragones nacidos van a los **corrales** y generan **oro por segundo**;
- el oro se acumula en la **placa de cobro**, y pisándola pasa a su cartera;
- desde el **establo** elige qué dragones están en los corrales y puede vender los que sobran.

T30 es la base sobre la que se montan el robo de huevos (T31), montar (T32), el robo entre jugadores (T33) y las mejoras (T35).

## Diseño

### Mapa provisional (hasta que exista el mapa de T08)
- **8 parcelas de 64 × 64 studs, en dos filas de 4** a ambos lados de una carretera central (eje X). Cada parcela mira a la carretera.
- **Cada parcela tiene:**
  - suelo y muro bajo, con una **entrada** de 14 studs hacia la carretera; T33 pondrá ahí la puerta;
  - **8 pedestales de incubadora** junto al muro del fondo; los que no están desbloqueados muestran 🔒;
  - **12 corrales** de 10 × 10 en 3 filas de 4;
  - la **placa de cobro**, junto a la entrada;
  - el **cartel** «Guarida de <Nombre> · 💰 X/s» y un punto de aparición.
- **Si el humano construye el mapa:** un `Model` con la etiqueta `Base` en Workspace, con hijos `Incubator1..8`, `Pen1..12`, `CollectPlate`, `Spawn`, `Sign` y `Door`. Si existe, se usa en vez del provisional. El contrato está en [[ARQUITECTURA]].
- **Al entrar** se asigna la primera parcela libre; **al salir** se vacía.
- **Al aparecer o reaparecer**, el jugador sale en su guarida.
- **Desde lejos** se ve un marcador «🏠 Tu guarida» (solo para su dueño).

### Incubadoras
- Al principio hay **2 desbloqueadas** (`IncubatorCount`). T35 las sube hasta 8.
- **`IncubatorService.TryDeposit(player, eggId)`** pone el huevo en la primera incubadora libre. Lo llamará T31 cuando el jugador llegue a su guarida con un huevo.
- **El tiempo se guarda como hora real (`os.time`)**, así que los huevos **siguen incubándose aunque el jugador esté desconectado**.
- **Sobre cada huevo** se ve una cuenta atrás. La calcula el cliente con el atributo `ReadyAt`, sin tráfico de red.
- **Cuando termina:** el huevo brilla y aparece un aviso «Eclosionar» (`ProximityPrompt`), **solo para el dueño**. El servidor comprueba quién lo pulsa.
- **Al eclosionar:**
  - `EggRoller.Roll(eggId, suerte)` + `MakeDragon`;
  - el dragón se añade a `Dragons` y, si hay corral libre, entra en él;
  - se dispara `Hatched` a todos, y el revelado de T34 hace el resto.
- **La eclosión es manual a propósito:** el jugador vive el momento del revelado, también con los huevos que acabaron mientras estaba desconectado.
- **Suerte:** atributo `Luck` del jugador (por defecto 1). En Studio también se usa `DebugLuck`, de T34.
- **Para otras tareas:**
  - `IncubatorService.RemoveEgg(player, slot)` → robo de huevos (T33);
  - `IncubatorService.FinishNow(player, slot)` → producto «eclosión instantánea» (T06).

### Corrales y oro
- **Corrales:** al principio 3 (`PenCount`); T35 los sube hasta 12.
- **Oro por segundo** = suma de `EggOdds.GetGoldPerSecond` de los dragones en corrales × los multiplicadores registrados.
- **Multiplicadores:** `IncomeService.AddMultiplier(nombre, función)`. Así T06 (pase ×2), T37 (renacer) y T38 (Dragonario) suman el suyo **sin editar IncomeService**.
- **Placa de cobro:**
  - el oro se acumula en la placa (`PlateGold`);
  - al pisarla, el dueño lo cobra, con un «+X 💰» flotante;
  - obliga a volver a la guarida, que es justo cuando se ven las incubadoras y los corrales.
- **Ganancias desconectado:**
  - al volver, la placa suma `oro/s × tiempo fuera × 50 %`, con un máximo de 2 h;
  - aparece el aviso «Mientras no estabas, tus dragones ganaron X 💰».
- **Dragones en corrales:**
  - se construyen con `DragonBuilder` (provisional según su `Kind`), quietos y respirando (animación de `DragonController`);
  - tamaño según la rareza;
  - aspecto según la mutación: Dorada metálica, Diamante de cristal, Sombra oscura, Arcoíris con colores que van cambiando, Gigante ×1,5;
  - encima, el nombre con el color de su rareza y su oro/s.

### Establo (interfaz)
- **Botón «🐉 Establo»** a la izquierda, que abre una ventana con todos tus dragones en tarjetas:
  - nombre y rareza, con borde de color;
  - mutación, si tiene;
  - oro/s.
- **En cada tarjeta:**
  - **«Al corral» / «Quitar»**;
  - **«Vender»** por `oro/s × 60`, con confirmación.
- **Arriba:** «Corrales 2/3» y «Dragones 14/300».
- **Máximo 300 dragones** (para que los datos guardados no crezcan sin límite). Con el establo lleno no se puede eclosionar, y avisa.

## Contrato de datos (nuevos campos)
| Campo | Tipo | Significado |
|---|---|---|
| `Gold` | número | Oro en la cartera |
| `PlateGold` | número | Oro acumulado en la placa, sin cobrar |
| `Dragons` | lista | `{ Id, SpeciesId, Mutation, Giant, HatchedAt }` (forma de `EggRoller.MakeDragon`) |
| `Pens` | lista de `Id` | Dragones en corrales, en orden y sin huecos |
| `Incubators` | diccionario `"1".."8"` | `{ EggId, StartedAt, HatchSeconds }` |
| `IncubatorCount` | número | Incubadoras desbloqueadas (2 → 8) |
| `PenCount` | número | Corrales desbloqueados (3 → 12) |
| `LastSeen` | número | Último `os.time()` en el que el jugador estaba conectado |
| `EggsHatched` | número | Total de huevos eclosionados (para T13) |

**Atributos del jugador:**
- `Gold`, `GoldPerSecond`, `PlateGold`, `BaseIndex`;
- `Luck`, que lo ponen otros sistemas.

## Remotes
| Nombre | Dirección | Datos |
|---|---|---|
| `Hatched` | servidor → todos | Contrato de T34 |
| `Stable` | cliente → servidor | `{ Action = "SetPen", DragonId, InPen }` o `{ Action = "Sell", DragonId }` |
| `StableData` | servidor → dueño | `{ Dragons, Pens, PenCount, MaxDragons }` cuando cambia algo |
| `GoldCollected` | servidor → dueño | cantidad cobrada |
| `Notify` | servidor → un jugador | `{ Text, Color? }`: avisos genéricos que reutilizan otras tareas |

## Lo que se retira (aprobado en D-021)
- **Clic +1:** `TrainService`, `TrainController`, `Config/Train`.
- **Combate:** `DamageService`, `MobService`, `BossService`, `CombatController`, `MobController`, `BossController`, `Config/Combat`, `Config/Enemies`, `Config/Zones`, `Config/Boss`.
  - T31 y T36 recuperarán del historial de Git la IA de persecución y el ciclo del evento.
  - **Se conservan** `EnemyVisuals` y `MobRegistry`, que serán el cuerpo de las dragonas madre.
- **Evolución por compra:** `EvolutionService`, `EvolutionController`, `Config/Evolutions`.
- **Dragón compañero que sigue al jugador:** `DragonService`. Vuelve en T32 como montura. `DragonBuilder` y la animación de `DragonController` se quedan.

## Archivos
- **Crear:**
  - `Config/Base.luau`;
  - en `Services/`: `BaseService`, `IncomeService`, `StableService`, `IncubatorService`;
  - `server/Dragon/DragonDisplay.luau`;
  - en `client/`: `BaseController`, `StableController`.
- **Editar:**
  - `Config/init.luau`, `StatsService`, `DebugService`;
  - `HUD`, `DragonController`;
  - la documentación.
- **Borrar:** los archivos de la lista anterior.

## Criterios de aceptación
- [ ] Al darle a Play aparezco en mi guarida, con 2 incubadoras y 3 corrales libres; el resto, con candado.
- [ ] `/incubar Prado` pone un huevo con su cuenta atrás de 30 s, y `/listo` lo termina al momento.
- [ ] Al pulsar «Eclosionar» se ve el revelado de T34, el dragón aparece en un corral y el cartel muestra su oro/s.
- [ ] La placa acumula oro; al pisarla lo cobro y sube la cartera del HUD.
- [ ] Desde el establo puedo quitar un dragón del corral, poner otro y vender. El oro/s cambia al momento.
- [ ] Con 2 jugadores: cada uno tiene su guarida, ve los dragones del otro y **no** puede eclosionar ni cobrar en la guarida ajena.
- [ ] Al salir y volver, los huevos han seguido incubándose y la placa trae ganancias de mientras no estaba.
- [ ] Sintaxis correcta, `rojo build` funciona y no hay errores en Output.

## Bloqueos
- Depende de T34: se fusiona **después** de T34. En el conflicto de `Config/init.luau` hay que dejar Base, Dragons, Eggs, Rebirth y Species.

## Resultado

### Qué se hizo
- **Guaridas (`BaseService`):**
  - 8 parcelas provisionales (o las del mapa con la etiqueta `Base`);
  - al entrar se asigna una; se aparece en ella; cartel con el dueño.
- **Oro (`IncomeService`):**
  - oro/s de los corrales, que se acumula en la placa y se cobra pisándola, solo la propia;
  - ganancias desconectado (50 %, máximo 2 h) con aviso;
  - API de multiplicadores para T06, T37 y T38.
- **Establo (`StableService` + `StableController`):**
  - dragones en los corrales, construidos con `DragonDisplay`: tamaño por rareza, aspecto por mutación, nombre y oro/s encima;
  - ventana con tarjetas para quitar, poner y vender (con confirmación);
  - límite de 300 dragones.
- **Incubadoras (`IncubatorService` + `BaseController`):**
  - huevos con forma de huevo y color de su tipo, sobre pedestales;
  - cuenta atrás en el cliente;
  - «Eclosionar» solo para el dueño, y validado en el servidor;
  - la eclosión dispara `Hatched` (revelado de T34);
  - APIs `TryDeposit`, `RemoveEgg` y `FinishNow` para T31, T33 y T06.
- **HUD:** oro y oro/s, más avisos genéricos `Notify`.
- **Retirado:** el clic +1, el combate y la evolución (lista en la ficha). `DragonController` queda solo para animar, y no anima lo que esté lejos de la cámara.
- **Streaming:** las guaridas y los dragones se envían enteros al cliente (`ModelStreamingMode = Atomic`). Era la causa de que no se vieran las cuentas atrás.

### Probado en vivo en Studio (2026-11-03, con una copia de los archivos de T34 aún sin terminar)
- [x] Aparezco en mi guarida (Base1), con 2 incubadoras y 3 corrales; el resto, bloqueado.
- [x] `/incubar Prado` y `/incubar Volcan`: huevos con su cuenta atrás. `/listo`: «¡Listo!» y aviso «Eclosionar».
- [x] Eclosión de un Cuélebre y un Ryū, con el revelado de T34. Pulsar «Eclosionar» dos veces seguidas solo da un dragón. Los dragones aparecen en los corrales y el oro/s pasa a 1.203.
- [x] Placa: cobré 58.363. Pisar la placa de otra guarida no cobra.
- [x] Establo: quitar del corral el Ryū (oro/s 1.203 → 3), volver a ponerlo y vender el Cuélebre (+180). Las peticiones falsas se ignoran.
- [x] `/ausente 3600`: +2,16 M en la placa (1.200 × 3.600 × 0,5) con aviso.
- [x] Sintaxis (`luau`) y `rojo build` correctos. Sin errores de mis scripts en Output.

### Cómo probarlo en Studio
1. **Hace falta T34 fusionada**, porque T30 usa `EggOdds` y `EggRoller`.
2. Play y aparecerás en tu guarida.
3. En el chat:
   - `/incubar Volcan`, luego `/listo`;
   - acércate al pedestal y pulsa **E** («Eclosionar»).
4. Espera unos segundos y pisa la placa amarilla para cobrar.
5. Abre **🐉 Establo**: quita, pon y vende.
6. Prueba también:
   - `/corrales 6` e `/incubadoras 8`;
   - `/ausente 3600` para las ganancias desconectado.
7. **Para probar con 2 jugadores:** Test → Servidor local con 2 clientes. Comprueba que no puedes cobrar ni eclosionar en la guarida del otro.

### Pendiente
- **Por probar:** 2 jugadores reales y guardado con DataStore (requiere el juego publicado).
- **La Hidra provisional parece mirar de lado** en el corral. Revisar la orientación del rig `Hydra` en T20, cuando tenga modelo IA.
- **Faltan modelos IA** de las especies nuevas (T20): ahora usan el rig provisional de su `Kind`.
- **Revisión de T34 (Codex):** al abrir el revelado sale en Output `rbxassetid://203785492 … Asset type does not match`. Avisarle.
