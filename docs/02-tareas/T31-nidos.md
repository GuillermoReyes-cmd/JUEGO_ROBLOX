---
tarea: T31
responsable: Claude
rama: tarea/T31-nidos (desde integracion/v4)
estado: En revisión (probada en vivo)
depende_de: T30, T34 · usa T35 (Sigilo, Botas), T41 (IsNight) y T43 (NestSpawn) si existen
actualizado: 2026-11-04
---

# T31: Nidos y dragonas madre

**Responsable:** Claude · **Rama:** `tarea/T31-nidos` · **Estado:** En revisión

Diseño: [[Vision-v4]] §5.1–5.2 · Números: `Config/Nests.luau` · Arquitectura: [[ARQUITECTURA]]

## Qué hace
1. **Nidos:**
   - cada pieza con la etiqueta **`NestSpawn`** (atributo `Biome` = Id del huevo) recibe un nido de ramas con **3 huevos** y una **dragona madre dormida** al lado;
   - si el mapa (T43) aún no existe, a los 3 s se crean **nidos provisionales**: 2 por bioma, en fila detrás de las guaridas (X ≥ 200).
2. **Barra de sueño** (0–100, sobre la madre «💤 zzz»):
   - **Sube** con el ruido de los jugadores a menos de 32 studs: más cuanto más cerca; correr ×2,5; ir montado ×1,5 (T32); llevar un huevo de ese nido ×1,5.
   - **Baja** con el Sigilo de Mejoras (−12 % por nivel) y de noche (×0,6, cuando exista T41).
   - **Coger un huevo** suma 30 de golpe. Si nadie molesta, baja 8 por segundo.
3. **Robar:** mantener **E** 1,2 s sobre un huevo.
   - El huevo va a la espalda, con brillo de su color.
   - Se corre más lento según el `CarrySlow` del huevo (5 % el Prado, 30 % el Cielo).
   - Aparece el aviso «🥚 Llevas un Huevo del Prado · ¡a tu guarida!».
   - El hueco del nido se rellena a los 40 s.
4. **Persecución:**
   - con la barra llena, la madre persigue al que lleva su huevo (o al más ruidoso);
   - el jugador ve un **borde rojo** en la pantalla y «¡La madre te persigue!»;
   - si sale de su territorio (`Leash`), la madre vuelve;
   - **si le alcanza:** el huevo vuelve al nido, el jugador sale despedido y la madre vuelve a dormir **más alerta** (barra en 45).
5. **Entregar:** al entrar en la propia guarida con el huevo, va solo a la incubadora (`IncubatorService.TryDeposit`) y suma `EggsStolen`. Si las incubadoras están llenas, se sigue llevando.
6. **Madres por bioma:**
   - más rápidas y más despiertas cuanto más lejos (Prado: velocidad 13, al que se escapa a pie; Cielo: 23, que obliga a ir montado);
   - las mueve el servidor con `AlignPosition` y las anima `DragonController` (postura de dormir nueva: tumbada, cabeza baja y alas plegadas).

## Archivos
- **Crear:**
  - `Config/Nests.luau`;
  - `Services/NestService.luau`;
  - `client/NestController.client.luau`.
- **Editar:**
  - `Config/init.luau`;
  - `client/DragonController.client.luau` (postura de dormir).

## Para otras tareas
| API o dato | Uso |
|---|---|
| `NestService.DropEgg(player)` → `eggId?` | **T33:** por ahora el huevo vuelve a su nido; T33 lo cambiará para que caiga al suelo y cualquiera lo recoja |
| `NestService.GetCarry(player)` | Saber si lleva huevo |
| `NestService.GetNests()` | **T36** (Dragona Reina) y el Radar de Mejoras |
| Atributo del jugador `Mounted` | **T32:** si va montado, hace más ruido |
| Atributos del jugador `CarryingEgg` y `ChasedBy` | Interfaz |
| Atributos de la madre `Sleep`, `State` y `Sleeping`; etiquetas `Nest` y `Mother` | Cliente y tutorial (el paso 4 de T39 se activa al existir `Nest`) |
| Remote `Knockback` (servidor → jugador) | Empujón |

## Probado en vivo en Studio (2026-11-04)
- [x] Sin mapa: 12 nidos provisionales (2 por bioma) con 3 huevos y 12 madres dormidas. Las de Prado usan el Draco de Blender.
- [x] Mantener E junto al nido: coge el Huevo del Prado, la velocidad baja de 16 a 15,2 y la barra de la madre sube a 45.
- [x] Correr cerca: la madre se despierta, persigue, alcanza (el huevo vuelve al nido) y regresa; se duerme con la barra en 45.
- [x] Robar en otro nido y entrar en la guarida: el huevo va a la incubadora 2 y se recupera la velocidad 16.
- [x] Sintaxis y `rojo build` correctos.

## Pendiente
- **Probar con 2 jugadores:** que la madre persiga al ladrón correcto.
- **Cuando llegue T43:** comprobar los nidos sobre el mapa real (deben salir de sus `NestSpawn`, sin provisionales).
- **El Radar** (nivel de Mejoras) aún no señala nidos: queda para T35b o para el pulido.
