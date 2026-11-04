---
tarea: T06
responsable: Claude
rama: tarea/T06-tienda (desde integracion/v4)
estado: En revisión (probada en modo prueba de Studio)
actualizado: 2026-11-04
---

# T06: Tienda con Robux

**Responsable:** Claude · **Rama:** `tarea/T06-tienda` · **Estado:** En revisión

Diseño: [[Vision-v4]] §7 · Orden copiado de la referencia: [[Partida-Montar-un-dinosaurio]] §6 · Catálogo: `Config/Shop.luau`

## Qué hay
| Sección | Producto | R$ | Qué da |
|---|---|---|---|
| ⭐ Destacado | Huevo Real ×1 / ×3 | 49 / 129 | Huevos de evento a tus incubadoras (si están llenas, esperan turno). **Botón «📊 Probabilidades» antes de comprar** |
| ⭐ Destacado | Pack de inicio (una vez) | 29 | Huevo del Desierto + 2.000 💰. Es la «primera compra barata» de la referencia |
| 🎟️ Pases | ×2 Oro para siempre | 199 | Multiplicador ×2 (`IncomeService.AddMultiplier`) |
| 🎟️ Pases | Auto-cobrar | 99 | La placa pasa sola a la cartera cada 10 s |
| 🧪 Ayudas | Suerte ×2 · 15 min | 45 | Atributo `Luck` (lo usa la eclosión) |
| 🧪 Ayudas | Eclosionar todo ya | 25 | Termina todas tus incubadoras |
| 🧪 Ayudas | Escudo 30 min / 2 h | 15 / 49 | `ShieldUntil`: nadie puede robar en tu guarida (T33) |
| 💰 Oro | Saco / Cofre / Tesoro | 25 / 99 / 249 | 10 min / 1 h / 5 h de tu producción (con un mínimo), así vale en cualquier momento |
| Bienvenida | Reclamar ×3 | 29 | Al volver, ventana «Ganancias sin conexión» con **¡Reclamar!** (gratis) o **Reclamar ×3** |

- **Seguridad:**
  - solo `ShopService` usa `ProcessReceipt` (regla 9 de [[AGENTS]]);
  - recuerda las últimas 50 compras para no dar dos veces la misma;
  - guarda los datos antes de confirmar la compra;
  - si el jugador no está cargado, responde `NotProcessedYet`.
- **Modo prueba:** con `ProductId` o `GamePassId` = 0, en Studio la compra se simula (no se cobra nada) y en el juego publicado dice «Próximamente».

## ⚠️ Lo que tiene que hacer Guillermo al publicar
1. **Publicar el juego** en Roblox (Archivo → Publicar en Roblox).
2. **Crear los productos:** en [create.roblox.com](https://create.roblox.com) → tu experiencia → **Monetización → Productos de desarrollador**. Crea uno por cada producto de la tabla, con su nombre y precio. Copia el **ID** de cada uno.
3. **Crear los pases:** en **Monetización → Pases**, crea «×2 Oro» y «Auto-cobrar» y copia sus **ID**.
4. **Pasarle los ID a Claude**, que los pondrá en `Config/Shop.luau` (`ProductId` y `GamePassId`).

## Probado en Studio (modo prueba, 2026-11-04)
- [x] Saco de oro: 50 → 1.250 💰 (se aplicó el mínimo de 1.000 + 200).
- [x] Pase ×2: oro/s de 2 a 4, y el botón pasa a «✅ Tuyo».
- [x] Huevo Real ×1: aparece en la incubadora 1.
- [x] Suerte ×2: `Luck` = 2. Escudo 30 min: `ShieldUntil` a 1.799 s.
- [x] `/ausente 3600`: se abre la ventana de bienvenida con 7,2K y los dos botones.
- [x] La tienda se ve por secciones, con iconos, precios y probabilidades.

## Pendiente
- Los ID reales, cuando se publique el juego.
- Botón de **regalo** 🎁 (comprar para otro jugador), como en la referencia: después del lanzamiento.
- **Pase VIP:** decidir sus ventajas.
