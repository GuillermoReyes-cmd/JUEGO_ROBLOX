---
tarea: T03
responsable: Claude
rama: tarea/T03-combate
estado: En revisión
version: 2
---

# T03: Combate de acción (v2)

**Responsable:** Claude · **Rama:** `tarea/T03-combate` · **Estado:** En revisión

> La v1 (duelo automático en la plataforma) se descartó porque al probarla se sintió muy básica. Ver [[Decisiones#D-010 Combate de acción en arena privada]].

## Objetivo
Pisar la plataforma de un enemigo lleva a una arena privada. Allí:
- El dragón ataca solo.
- Cada clic es un ataque rápido, con críticos y combo.
- Hay que esquivar los círculos rojos de los ataques especiales.

Cada nivel tiene un enemigo distinto, animado y más impresionante.

## Diseño
- Reglas, números y sensación de la batalla: [[Combate]].
- Los 8 enemigos (tabla, aspecto y animaciones): [[Enemigos]].

## Archivos de esta tarea
- **Creados:**
  - `src/server/Services/CombatService.luau`
  - `src/client/CombatController.client.luau`
  - `src/client/EnemyVisuals.luau`
  - `src/shared/Config/Combat.luau`
- **Editados:**
  - `src/shared/Config/Enemies.luau`: campos de batalla y aspecto.
  - `src/shared/Config/init.luau`: registra `Config.Combat` (núcleo, dueño Claude).
  - `src/client/TrainController.client.luau`: no entrena en batalla.
  - `src/client/HUD.client.luau`: oculta el texto guía en batalla.
  - `src/server/Services/DebugService.luau`: truco `/pelea N`.
  - `docs/01-arquitectura/ARQUITECTURA.md`.
- **Documentación (bóveda de Obsidian):**
  - `docs/INICIO.md`
  - `docs/00-vision/Combate.md`
  - `docs/00-vision/Enemigos.md`
  - `docs/04-bitacora/Bitacora.md`
  - `docs/05-decisiones/Decisiones.md`

## Criterios de aceptación
- [ ] Sin el Poder requerido aparece «Necesitas ⚡ X…» y no entra.
- [ ] Con Poder suficiente entra a la arena, con cuenta atrás 3·2·1·¡PELEA!.
- [ ] Se ve al enemigo de su nivel, animado.
- [ ] El dragón lanza bolas de fuego solo (cada 1 s) y los clics hacen zarpazos con números de daño, críticos y combo.
- [ ] Los círculos rojos dañan si te quedas dentro y muestran «¡ESQUIVADO!» si sales a tiempo.
- [ ] Ganar suma 🏆 y devuelve al mundo delante de la plataforma.
- [ ] Perder (vida a 0) o agotar el tiempo devuelve sin premio.
- [ ] Con el jefe, la fase 2 aparece al 50 %.
- [ ] En batalla, los clics no entrenan.
- [ ] Un cliente modificado no puede hacer más de 8 golpes por segundo ni ganar sin pelear.
- [x] Sintaxis correcta y `rojo build` funciona.

## Bloqueos
(ninguno)

## Resultado

### Qué se hizo
- **Servidor (`CombatService`):**
  - Arenas privadas que se reutilizan.
  - Estado de cada batalla y un bucle en `Heartbeat` que maneja auto-ataque, golpes del enemigo, especiales con círculos, fase 2 y tiempo límite.
  - Validación de la plataforma, límite de 8 clics/s y vida virtual (el personaje no muere).
  - Si el jugador sale o reaparece, la batalla se cancela.
- **Cliente:**
  - `EnemyVisuals` construye los 8 enemigos con piezas y animaciones por código: respirar, embestir, aletear, ondular, tajo, retroceso al recibir golpe, hundirse al morir y brillo rojo en fase 2.
  - Si existe `ReplicatedStorage.Assets.Enemies.<Nombre>`, usa ese modelo.
  - `CombatController` dibuja la interfaz y los efectos: bolas de fuego, zarpazos, números, círculos, explosiones, temblor de cámara y combo.

### Verificación
- La sintaxis de todos los archivos es correcta y `rojo build` funciona.
- **Simulación de batallas con el servicio real: 29 pruebas superadas.** Cubren:
  - Entrada y requisito de Poder.
  - Cuenta atrás.
  - Daño del auto-ataque y de los clics con combo.
  - El límite de 8 clics.
  - Victoria con Victorias y regreso.
  - El tiempo de espera.
  - Círculo bajo el jugador: golpear y esquivar.
  - Derrota.
  - Jefe con vida ×40 y fase 2 una sola vez, con 5 círculos.
  - Liberar la arena al salir.
- **No probado todavía en Studio:** el aspecto de los enemigos, las animaciones y la sensación de juego.

### Cómo probarlo en Studio
1. Conecta Rojo a esta rama y pulsa **Play**. Delante de ti verás 8 plataformas brillantes con su cartel (nivel, ⚡ necesario, 🏆).
2. **Lagartija:**
   - Pisa la plataforma con 0 ⚡: debe salir el aviso.
   - Escribe `/power 10` en el chat y vuelve a pisarla: entras a la arena.
   - Clica rápido y muévete cuando aparezca el círculo rojo.
3. **Para ver cada enemigo directamente:** escribe `/power 5000000` y luego `/pelea 1` … `/pelea 8`. El 8 es el jefe Rey Volcán, con fase 2.
4. **Para perder a propósito:** escribe `/power 10` y `/pelea 5`. El Poder es muy bajo y no da tiempo.

### Pendiente
- Ajustar números (vida, daño, tiempos) cuando se sienta en juego. Todo está en `Config/Combat.luau` y `Config/Enemies.luau`.
- Modelos reales de enemigos (T09), Aliento de fuego (T10) y sonidos (T16).
