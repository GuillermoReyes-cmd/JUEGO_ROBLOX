# T06: Game passes, productos y ProcessReceipt

**Responsable:** Claude · **Rama:** `tarea/T06-tienda` · **Estado:** Pendiente

## Objetivo
El jugador puede comprar game passes (multiplicadores de Poder, 2x Victorias, VIP…) y productos consumibles (paquetes de Poder, boosts, saltar evolución) de forma segura.

## Contexto
- Implementa la sección 7 de `docs/00-vision/Diseno-juego-Dragon.md`.
- Es una tarea crítica porque mueve dinero real. La hace Claude.
- **Tú** creas los game passes y productos en el Creator Dashboard y anotas sus IDs en `Config/Shop.luau`.

## Archivos permitidos
- Crear:
  - `src/server/Services/ShopService.luau`
  - `src/client/ShopController.client.luau`
  - `src/shared/Config/Shop.luau`
- Editar:
  - `src/shared/Config/init.luau`: solo para registrar `Config.Shop` y que `GetPowerPerClick` acepte un multiplicador extra.
  - `src/server/Services/TrainService.luau`: aplicar el multiplicador de los passes.
  - `docs/01-arquitectura/ARQUITECTURA.md`.

## Requisitos
1. Toda compra se procesa con `ProcessReceipt`, de forma **idempotente**: guarda los recibos ya entregados para no entregar dos veces.
2. Los multiplicadores de Poder no se suman entre sí: se aplica el más alto que se tenga.
3. Botón **«🛒 Tienda»** a la izquierda (y = 55%), con pestañas «Pases» y «Productos».
4. Lista inicial: unos 6 game passes y unos 10 productos (lista exacta en el diseño, sección 7).
5. Precios regionales (Managed Pricing) compatibles: el precio se muestra con `GetProductInfo`, nunca escrito en el código.

## Criterios de aceptación
- [ ] Una compra de prueba en Studio entrega el producto **una sola vez**.
- [ ] Tener el pase x8 multiplica el +X por clic.
- [ ] Sintaxis correcta y `rojo build` funciona.

## Bloqueos
Necesita los IDs de los pases y productos creados en Roblox. Tú los creas.

## Resultado
