---
tarea: T36
responsable: Claude
rama: tarea/T36-reina (desde integracion/v4)
estado: En revisión (probada en vivo)
depende_de: T31
actualizado: 2026-11-04
---

# T36: Evento de la Dragona Reina

**Responsable:** Claude · **Rama:** `tarea/T36-reina` · **Estado:** En revisión

Diseño: [[Vision-v4]] §5.7 · Números: `Config/Queen.luau`

## Qué hace
- **Ciclo** (cada 10 min):
  - **Espera** (contador arriba a la derecha «👑 Reina en 4:32»);
  - **Aviso** a todo el servidor 60 s antes («👑 ¡Viene!» y una corona flotante visible desde lejos en el lugar);
  - **Activo** durante 3 min («👑 ¡AHORA!»).
- **Evento activo:**
  - **nido gigante con 5 Huevos Reales** al oeste de las guaridas (X = −190); si el mapa tiene una pieza con la etiqueta `QueenSpawn`, se usa esa;
  - los huevos **no reaparecen**: es una carrera de todo el servidor, con empujones (T33) y persecución.
- **La Reina:**
  - grande (24 studs) y despierta con facilidad;
  - **nunca duerme del todo**: su barra empieza en 55 y no baja de 50.
  - Su aspecto es la especie «Reina Dorada»; de momento con el modelo provisional, hasta que haya uno de Blender.
- **Fin:** al acabarse el tiempo o los huevos, el nido y la Reina desaparecen. Los huevos que ya se han llevado siguen siendo de quien los lleva.
- **Reutiliza T31:**
  - `NestService.CreateEventNest`, `RemoveNest` y `CountEggs`;
  - las madres aceptan `StartSleep`, `MinSleep` y `CalmSleep`.
- **Truco:** `/reina` lo lanza ya (aviso de 3 s).

## Archivos
- **Crear:**
  - `Config/Queen.luau`;
  - `Services/QueenService.luau`;
  - `client/QueenController.client.luau`.
- **Editar:**
  - `Config/init.luau`;
  - `NestService` (nidos de evento);
  - `DebugService` (`/reina`).

## Probado en vivo en Studio (2026-11-04)
- [x] Al arrancar: «Waiting», con 533 s para el aviso, y los 12 nidos normales siguen bien tras el cambio de código.
- [x] `/reina`: a los 3 s pasa a «Active»; nido en (−190, 0, 0) con 5 Huevos Reales y la Reina Dorada; contador «👑 ¡AHORA! 2:55».
- [x] Ajuste tras la prueba: su barra bajaba a 41, así que se añadió el mínimo `MinSleep` = 50.

## Pendiente
- Modelo de Blender para la Reina (dorado y más grande).
- Un cráter o una plaza bonita en el mapa (T08/T43) con la etiqueta `QueenSpawn`.
