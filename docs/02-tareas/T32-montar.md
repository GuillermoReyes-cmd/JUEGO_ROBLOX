---
tarea: T32
responsable: Claude
rama: tarea/T32-montar (desde integracion/v4)
estado: En revisión (probada en vivo)
depende_de: T30, T31 · usa T35 (Silla) y T38 (sillas de bioma)
actualizado: 2026-11-04
---

# T32: Montar dragones

**Responsable:** Claude · **Rama:** `tarea/T32-montar` · **Estado:** En revisión

Diseño: [[Vision-v4]] §5.5 · Referencia: [[Partida-Montar-un-dinosaurio]] · Números: `Config/Mount.luau`

## Qué hace
- **Subir y bajar:**
  - con la **tecla R** o el botón **«🐉 Montar (R)»** (derecha, y = 62 %, pensado para móvil);
  - al reaparecer, el jugador empieza a pie.
- **Elegir montura:**
  - en el **Establo**, cada tarjeta tiene un botón **🏇**, dorado en la montura actual;
  - si no se elige ninguna, se monta la más rápida.
- **Cómo funciona por dentro:**
  - el dragón (`DragonBuilder` + aspecto de su mutación) se **suelda debajo del jinete**;
  - el personaje sube (`HipHeight`) lo justo para que las patas del dragón toquen el suelo;
  - el jinete va **sentado** (animación con prioridad máxima, para que no la tapen los packs de animación del avatar) y hay una **silla** de cuero en el lomo;
  - el dragón **galopa solo**: `DragonController` lo anima con la velocidad del jinete. No hay física nueva que sincronizar.
- **Velocidad:**
  - según la rareza: Común 24, Raro 27, Épico 30, Legendario 34, Mítico 38, Divino 43, Secreto 48;
  - gigante +10 %, **Silla** de Mejoras +4 % por nivel y **sillas de bioma** del Dragonario (atributos `Saddle<Bioma>`) +3 % cada una;
  - el peso del huevo que se lleva también frena la montura (`NestService.RefreshSpeed`).
- **Ruido:** ir montado hace más ruido cerca de las madres (×1,5, atributo `Mounted`).
- **Efectos:** polvo bajo las patas al correr y la cámara se abre con la velocidad (FOV de 70 a 82).

## Archivos
- **Crear:**
  - `Config/Mount.luau`;
  - `Services/MountService.luau`;
  - `client/MountController.client.luau`.
- **Editar:**
  - `Config/init.luau`;
  - `NestService` (velocidad base de la montura y `RefreshSpeed`);
  - `DragonDisplay` (`Decorate`);
  - `StableController` (botón 🏇).

## Probado en vivo en Studio (2026-11-04)
- [x] Eclosionar y pulsar «Montar»: monta el dragón más rápido; velocidad 16 → 24; `HipHeight` 1,39 → 2,54.
- [x] Al andar, el dragón se mueve con el jinete. Con el Draco de Blender, el jinete va sentado en la silla y las alas se ven abiertas.
- [x] La animación de sentarse se tapaba por el pack de animaciones del avatar: se arregló con prioridad Action4.
- [x] Sintaxis y `rojo build` correctos.

## Pendiente
- Volar con las especies aladas en Islas del Cielo (T25, actualización de Navidad).
- Riendas visuales (cuerdas de la silla a la cabeza): pulido.
- Probar con 2 jugadores que cada uno ve la montura del otro animada.
