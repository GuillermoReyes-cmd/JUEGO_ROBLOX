---
tarea: T19
responsable: Codex
rama: tarea/T19-especies (desde tarea/T18-dragon)
estado: En revisión
depende_de: T18
actualizado: 2026-11-03
---

# T19: Especies y evolución v3

**Responsable:** Codex · **Rama:** `tarea/T19-especies`, **creada desde `origin/tarea/T18-dragon`** · **Estado:** En revisión

Diseño: [[Dragones]] · Contrato del dragón: [[T18-dragon-companero]] · Arquitectura: [[ARQUITECTURA]]

## Objetivo
El jugador gasta 🏆 para que **su dragón evolucione a la siguiente especie**. La evolución debe sentirse épica:
- Ventana clara con la especie actual y la siguiente.
- Cinemática de 2 s sobre su dragón.
- Aviso a todo el servidor.

## Contexto (qué ya existe)
- **T18 (rama base):**
  - `DragonService` reconstruye el dragón **automáticamente** cuando cambia el atributo `Evolution` del jugador (lo pone `StatsService.Refresh`).
  - Las especies están en `Config.Dragons.Species`, una por evolución.
  - Usa `Config.Dragons.GetSpecies(evolution)`.
- **Costos y multiplicadores:** `Config.Evolutions`. **No cambies los números.**
- **Tu trabajo anterior en T04** (rama `tarea/T04-evoluciones`): la **compra validada** en el servidor (`Remotes.Get("Evolve")`) y la ventana con `ActiveModal` **se reutilizan**. Las **partes pegadas al avatar NO**: el dragón compañero las sustituye.
- **Para probar:** en el chat de Studio, `/wins 100000` da Victorias y `/evo N` cambia la evolución.

## Archivos permitidos
- **Crear:**
  - `src/server/Services/EvolutionService.luau`
  - `src/client/EvolutionController.client.luau`
- **Editar:**
  - `docs/01-arquitectura/ARQUITECTURA.md`: remotes y contrato `ActiveModal`.
  - Esta ficha.
  - `docs/02-tareas/TABLERO.md`: tu estado.
  - `docs/04-bitacora/Bitacora.md`: tu entrada.
- **Solo lectura (NO editar):** `DragonService`, `DragonBuilder`, `DragonController`, `Config/Dragons.luau`, `Config/Evolutions.luau` y el núcleo.

## Requisitos
1. **Compra (servidor):**
   - `Remotes.Get("Evolve")`, sin argumentos del cliente.
   - Valida que exista la siguiente evolución y que `Wins >= Cost`. Cobra, hace `Evolution += 1` y llama a `StatsService.Refresh`, que provoca la reconstrucción del dragón.
   - Antispam: como máximo 1 compra cada 0,5 s por jugador.
2. **Aviso al servidor:**
   - Remote `Evolved`, servidor → todos.
   - Datos: `{ UserId, DisplayName, SpeciesId, SpeciesName, SpeciesType }`.
3. **Ventana (cliente):**
   - Botón **«🐉 Evolucionar»** a la izquierda (y = 35 %), **ancho fijo de unos 200 px**.
   - La ventana muestra:
     - especie actual y siguiente, con **nombre y tipo** (por ejemplo «Guiverno Sombrío · Guiverno»);
     - costo en 🏆 y el multiplicador nuevo;
     - una **vista previa 3D** de la siguiente especie: `ViewportFrame` con una copia del modelo de la siguiente especie girando. Si clonar el modelo es complejo, vale un retrato con el nombre y el color de la especie; anótalo en «Resultado».
   - Botón gris si no alcanza. Evolución máxima: «¡Tu dragón es legendario!».
   - Usa el contrato `PlayerGui.ActiveModal = "Evolution"`.
4. **Cinemática (solo el dueño):**
   - Al confirmar, la cámara se acerca a su dragón 2 s (`Camera.CameraType = Scriptable` con un tween, y vuelve después).
   - Destello de luz del color del elemento (atributo `Element` del modelo del dragón).
   - Partículas en espiral.
   - Texto grande «¡EVOLUCIONASTE A <NOMBRE>!» con el tipo debajo.
   - El dragón nuevo aparece por la reconstrucción automática de T18: **no** lo crees tú.
5. **Aviso para todos:** banner arriba durante 4 s: «🐉 <Nombre> evolucionó a <ESPECIE>».
6. **Estilo:** imita el de `CombatController` y `HUD`: fuente FredokaOne, fondos oscuros y esquinas redondeadas.

## Criterios de aceptación
- [ ] Con `/wins 5` puedo pasar del Huevo a la Cría. Veo la cinemática y el dragón cambia.
- [ ] Sin 🏆 suficientes, el botón está gris y el servidor rechaza el remote disparado a mano.
- [ ] Con 2 jugadores, el otro ve el banner y el dragón nuevo.
- [ ] En la evolución 10 no se puede comprar más.
- [x] Sintaxis correcta (`luau`) y `rojo build default.project.json -o build.rbxlx` funciona.

## Bloqueos

## Resultado

### Qué se hizo
- `EvolutionService`: compra secuencial validada con los costos existentes, sin argumentos del cliente, sin esperas entre validación y cobro. Una compra como máximo cada 0,5 s por jugador, con limpieza al salir.
- `StatsService.Refresh` actualiza Evolution y T18 reconstruye el compañero; T19 no llama a DragonBuilder ni añade partes al avatar.
- Remote `Evolved` con los cinco campos especificados, generado exclusivamente por el servidor después de cobrar; aviso para todos en cola, visible 4 s por mensaje.
- Ventana con ActiveModal, botón lateral fijo de 200 × 48 px, nombres y tipos de especie, costo, nuevo multiplicador, compra gris, solicitud pendiente y mensaje «¡Tu dragón es legendario!» al llegar al máximo.
- **Previa alternativa permitida:** retrato gráfico con nombre, tipo, fondo Color y borde Accent de la siguiente especie. No se implementó ViewportFrame: los modelos provisionales se construyen en el servidor y no se duplicó el constructor de T18 ni se inventó un modelo cliente.
- Cinemática local del dueño: espera hasta 2 s a que se replique la especie confirmada, acerca la cámara mediante tween y la sigue durante la presentación de 2 s. Highlight, PointLight del Element del modelo y dos emisores recorren espirales alrededor del dragón; texto grande con nombre y tipo.
- Se restaura CameraType, CFrame, Focus, FieldOfView y CameraSubject al finalizar o interrumpir; se desconectan los efectos al desaparecer el modelo, cambiar la cámara o reaparecer el jugador. Una confirmación posterior sustituye la cinemática anterior.
- Si el modelo no se replica a tiempo, se presenta el texto durante 2 s sin tomar la cámara ni crear otro dragón.
- Config, DragonService, DragonBuilder, DragonController y núcleo permanecen intactos. T04 queda conservada como respaldo en su rama, commit `91a1b0b`.

### Verificación realizada
- `luau` en ambos archivos nuevos: sin errores de parseo; el error de ejecución en `game:GetService` es el esperado fuera de Roblox.
- `rojo build default.project.json -o build.rbxlx`: correcto. El build no se incluye en git.
- Prueba temporal Luau del servicio real con dependencias simuladas y tablas reales de Config: cobro exacto de 5 para pasar del Huevo a la Cría, saldo insuficiente, argumentos falsos ignorados, límite a 0 / 0,1 / 0,49 s y aceptación a 0,5 s, independencia entre jugadores, costos y avisos de las diez especies, máximo, perfil ausente y limpieza al salir. Todas las aserciones pasaron.
- Las pruebas visuales y la replicación real requieren Studio; no se marcan como verificadas.

### Cómo probar en Studio
1. Sincronizar esta rama con Rojo y ejecutar Play. Abrir «🐉 Evolucionar»: Huevo Ardiente · Huevo como actual y Cría de Dragón · Occidental (cría) como siguiente, costo 5, multiplicador ×1,5 y retrato de sus colores.
2. Con `/wins 4`, comprobar compra gris. En consola cliente ejecutar `game.ReplicatedStorage.Remotes.Evolve:FireServer(10, 0)`; no debe cobrar ni cambiar de especie ni anunciar nada.
3. Con `/wins 5`, comprar: Wins baja a 0, el compañero cambia a Cría, la cámara se acerca 2 s, hay destello y espirales del color de su Element, nombre y tipo en grande. La cámara vuelve al control normal; entrenar añade +1,5 sin renacimientos.
4. Con `/wins 100000`, disparar el remote varias veces seguidas: solo una compra durante 0,5 s. Esperar y volver a disparar; revisar cada costo y especie hasta la 10, donde aparece «¡Tu dragón es legendario!» y se bloquean más compras.
5. Probar `/rebirths 1` a `/rebirths 4`, dar Victorias y comprar: el destello debe usar el color del Element del modelo.
6. Iniciar un servidor con dos clientes. Comprar con uno: ambos ven «🐉 <Nombre> evolucionó a <ESPECIE>» 4 s y el nuevo dragón; únicamente el dueño ve la cinemática. Hacer compras simultáneas para revisar la cola de avisos.
7. Reiniciar el personaje durante la cinemática y repetir compras rápidas mediante consola. Comprobar que se recupera la cámara, no quedan luces ni emisores temporales y el compañero sigue funcionando. Probar también al moverse y en batalla.
8. Probar en emulador móvil y escritorio: botón fijo, cierre, texto legible y retrato. Cambiar `PlayerGui.ActiveModal` a otro nombre: la ventana de evolución debe cerrarse sin borrar el identificador ajeno.
9. En un lugar publicado con acceso a DataStore, salir y entrar tras evolucionar para confirmar que T18 restaura la especie guardada.

### Pendiente
- Verificar en Studio el aspecto, encuadre, espirales, orden de replicación, multijugador y persistencia real.
- La previa es un retrato con nombre y colores, no un modelo 3D, según la alternativa de esta ficha.
