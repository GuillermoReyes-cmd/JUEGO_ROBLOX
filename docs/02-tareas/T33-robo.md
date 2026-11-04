---
tarea: T33
responsable: Claude
rama: tarea/T33-robo (desde integracion/v4)
estado: En revisión (probada en vivo, salvo lo que necesita 2 jugadores)
depende_de: T30, T31
actualizado: 2026-11-04
---

# T33: Robo entre jugadores

**Responsable:** Claude · **Rama:** `tarea/T33-robo` · **Estado:** En revisión

Diseño: [[Vision-v4]] §5.2–5.3 · Números: `Config/Raid.luau`

## Qué hace
- **Empujón:**
  - con **F** o el botón **«👊 Empujar (F)»** (derecha, y = 72 %), con 3 s de recarga;
  - afecta al jugador más cercano delante de ti (a 8 studs como mucho, en un cono de ±70°), que sale despedido;
  - **si llevaba un huevo, se le cae al suelo:** el huevo brilla y cualquiera lo recoge con E;
  - si nadie lo coge en 30 s, vuelve a su nido.
- **Robar de una guarida ajena:**
  - en las incubadoras con huevo de otro jugador aparece **«Robar huevo»** (mantener E 2 s);
  - el huevo pasa a llevarlo el ladrón, que tiene que llegar a **su** guarida;
  - el dueño recibe «⚠️ ¡X te robó un Huevo del Prado! Empújale (F) para recuperarlo»;
  - los dragones ya nacidos **nunca** se roban (D-021).
- **Puerta de la guarida:**
  - el botón **«🔒 Cerrar guarida»** (derecha, y = 52 %) la cierra **60 s**, con un campo de fuerza rojo en la entrada;
  - mientras está cerrada no aparece «Robar huevo» en tus incubadoras y el servidor rechaza los robos;
  - después hay **30 s de recarga** («⏳ Puerta 20 s»).
  - **El escudo de pago (T06)** pondrá el atributo `ShieldUntil` en el jugador, con el mismo efecto.
- **Seguridad:** el servidor comprueba todo (dueño, distancia, puerta, recargas, si ya lleva un huevo). El cliente solo pide.

## Archivos
- **Crear:**
  - `Config/Raid.luau`;
  - `Services/RaidService.luau`;
  - `client/RaidController.client.luau`.
- **Editar:**
  - `Config/init.luau`;
  - `NestService` (`GiveCarry` y `DropToGround`);
  - `DebugService` (`/soltar`).

## Probado en vivo en Studio (2026-11-04, un jugador)
- [x] Robar un huevo de un nido y usar `/soltar`: el huevo cae al suelo (1 huevo en el suelo, ya no lo llevo); E lo recoge.
- [x] «Cerrar guarida»: `LockedUntil` a 60 s, puerta roja de campo de fuerza y botón con cuenta atrás.
- [x] Sintaxis y `rojo build` correctos.
- [ ] **Falta probar con 2 jugadores** (Studio → Probar → Servidor local, 2 clientes):
  - empujar a quien lleva un huevo;
  - robar de la incubadora del otro;
  - que la puerta cerrada impida el robo.

## Pendiente
- Prueba con 2 jugadores.
- Animación del empujón (ahora solo hay salida despedida y aviso).
