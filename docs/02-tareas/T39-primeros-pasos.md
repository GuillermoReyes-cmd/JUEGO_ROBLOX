---
tarea: T39
responsable: Claude
rama: tarea/T39-tutorial (desde integracion/v4-base)
estado: En revisión
depende_de: T30, T34 (usa T31 y T35 si están)
actualizado: 2026-11-04
---

# T39: Primeros pasos (tutorial guiado)

**Responsable:** Claude · **Rama:** `tarea/T39-tutorial` · **Estado:** En revisión

**Inspiración:** [[Partida-Montar-un-dinosaurio]] §1 y §7. Allí el jugador nuevo nunca duda de qué hacer: hay un objetivo a la izquierda, flechas en el suelo hasta el sitio y un «!» encima del destino.

## Objetivo
En los primeros 2–3 minutos, el jugador nuevo aprende el bucle completo sin leer nada largo:

| # | Objetivo en pantalla | Se cumple cuando… | Guía | Premio |
|---|---|---|---|---|
| 1 | «¡Tu primer huevo está en la incubadora! Acércate y pulsa E para eclosionarlo» | Eclosiona un huevo | Flechas + «!» sobre la incubadora | 50 💰 |
| 2 | «Tu dragón da oro. ¡Pisa la placa amarilla para cobrarlo!» | Tiene oro en la cartera | Flechas + «!» sobre la placa | 100 💰 |
| 3 | «Abre el Establo para ver a tus dragones» | Abre la ventana del Establo | El botón «🐉 Establo» brilla | 50 💰 |
| 4 | «Ve al Prado y roba un huevo de un nido» | Deposita otro huevo o eclosiona el segundo | Flechas + «!» sobre el nido más cercano | 200 💰 |
| 5 | «Compra tu primera mejora» | Compra cualquier mejora | El botón de Mejoras brilla | — |
| ✔ | «¡Ya sabes jugar! Busca huevos más raros en nidos lejanos» | (4 s y desaparece) | — | — |

**Regalo de bienvenida:** al empezar, si no tiene huevos ni dragones, recibe un **Huevo del Prado** que eclosiona en **8 s** (no en 30), para que el primer revelado llegue enseguida.

**Pasos que aún no existen se saltan solos:**
- el 4 si en el mapa no hay nidos (etiqueta `Nest`, T31);
- el 5 si no está T35 (`data.Upgrades`).

Cuando se fusionen esas tareas, el tutorial las incluye sin tocar nada.

## Diseño técnico
- **`TutorialService` (servidor):**
  - **Dato:** `Tutorial` = paso actual (pasado el último = terminado) y `TutorialGift`.
  - **Cada 0,5 s** comprueba la condición del paso actual leyendo los datos del jugador.
    - No hace falta que los otros servicios avisen: ningún archivo ajeno se edita.
  - **Atributos del jugador que lee el cliente:**
    - `TutorialStep` y `TutorialTotal`;
    - `TutorialText`;
    - `TutorialTarget` (Vector3 o nil);
    - `TutorialButton` (nombre del ScreenGui cuyo botón brilla, o nil).
  - **Remote `TutorialAction`** (cliente → servidor), solo para lo que únicamente ve el cliente: «abrí el Establo». No da nada que se pueda repetir: cada paso paga una vez.
- **`TutorialController` (cliente):**
  - **Panel «OBJETIVO»** a la izquierda (encima del botón del Establo), con el texto y la barra de pasos «2/5».
  - **Flechas blancas en el suelo,** una cada 3 studs desde el jugador hasta el objetivo. Son locales, sin colisión.
  - **«!» rojo flotante** encima del objetivo, visible a través de las paredes.
  - **Botón resaltado** con un borde amarillo que late.
  - **Al cumplir un paso:** el panel parpadea en verde y llega el aviso «¡Hecho! +X 💰».
- **Los números van en `Config/Tutorial.luau`:** textos, premios, segundos del primer huevo y distancia entre flechas.

## Archivos
- **Crear:**
  - `Config/Tutorial.luau`;
  - `Services/TutorialService.luau`;
  - `client/TutorialController.client.luau`.
- **Editar:**
  - `Config/init.luau` (1 línea);
  - la documentación.

## Criterios de aceptación
- [ ] Con un jugador nuevo (`/reset`): sale el objetivo 1, hay un huevo en la incubadora y las flechas llevan a él.
- [ ] Eclosionar el huevo completa el paso, paga 50 💰 y pasa al 2.
- [ ] Pisar la placa completa el paso 2. Abrir el Establo, el 3.
- [ ] Sin nidos ni mejoras en el mapa, los pasos 4 y 5 se saltan y sale «¡Ya sabes jugar!».
- [ ] Al salir y volver, el tutorial sigue en el mismo paso, y no se repite al terminarlo.
- [ ] Sintaxis correcta y `rojo build` funciona.

## Resultado

### Qué se hizo
- **`Config/Tutorial.luau`:** 5 pasos (textos, premios, objetivo de las flechas y botón que brilla), el huevo de regalo (Prado, 8 s) y las medidas de las flechas.
- **`TutorialService`** (Order 60):
  - comprueba el paso cada 0,5 s leyendo los datos;
  - salta los pasos de sistemas que no existen;
  - paga el premio una sola vez y avisa «¡Hecho! +X 💰» y «¡Ya sabes jugar!»;
  - publica los atributos `Tutorial*`;
  - API `TutorialService.Reset(player)`.
- **`TutorialController`:** panel «OBJETIVO» con barra «k/5», flechas en «V» sobre el suelo (raycast), «!» rojo flotante visible a través de las paredes y borde amarillo que late en el botón.
- **Remote `TutorialAction`** («OpenedStable»).
- **Truco `/tutorial`** en DebugService.
- **No se editó ningún servicio ajeno.**

### Probado en vivo en Studio (2026-11-04)
- [x] Al entrar: panel «1/5», huevo de regalo del Prado en la incubadora 1, 14 flechas y «!» sobre la incubadora.
- [x] Eclosionar → paso 2 y +50 💰.
- [x] Pisar la placa con oro → paso 3 (+100 💰) y el botón del Establo brilla.
- [x] Abrir el Establo → +50 💰.
- [x] Sin nidos ni mejoras en esta rama, los pasos 4 y 5 se saltan.
- [x] Sintaxis y `rojo build` correctos.
- [ ] Corregido después de la prueba, sin volver a probar: el aviso final «¡Ya sabes jugar!» no salía cuando los últimos pasos se saltaban.

### Pendiente
- Cuando lleguen T31 (nidos con la etiqueta `Nest`) y T35 (`data.Upgrades`), probar los pasos 4 y 5.
- Probar en móvil que el panel no tape nada.
