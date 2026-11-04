# T37: Renacer v4
Estado: En revisión · Rama: tarea/T37-renacer desde origin/tarea/T35-mejoras.

## Objetivo
Coste creciente en oro, multiplicador permanente, confirmación clara y aviso global. Reinicia Gold, PlateGold, niveles Upgrades y capacidades; conserva dragones y huevos.

## Archivos permitidos
Crear src/server/Services/RebirthService.luau y src/client/RebirthController.client.luau. Editar src/shared/Config/Rebirth.luau y docs.

## Bloqueos
Ninguno.

## Resultado
- Coste inicial 1 M de oro, ×3 por renacimiento; +0,5 al multiplicador permanente por renacer, configurable.
- Reinicia oro, placa, niveles y plazas; conserva Dragons e Incubators íntegros. Los corrales sobrantes se vacían sin borrar dragones. Los huevos en incubadoras bloqueadas se recuperan al recomprar plazas.
- Confirmación detallada; la petición incluye el Rebirths mostrado para rechazar confirmaciones antiguas. Aviso global mediante Notify.
- Sintaxis de los tres Luau y build Rojo correctos.
### Cómo probar en Studio
1. Play, `/oro 1000000`; abrir Renacer en y=75 %. Cerrar sin confirmar: nada debe cambiar.
2. Comprar mejoras y volver a dar oro. Incubar varios huevos y eclosionar dragones.
3. Confirmar: oro y mejoras a cero, capacidad 2/3, botas a 16, Rebirths +1. Colecciones intactas, oro/s ×1,5.
4. Repetir la petición anterior: no debe renacer dos veces. Ver aviso con dos clientes.
5. Salir y volver con DataStore habilitado para comprobar permanencia.
### Pendiente
Pruebas en vivo y persistencia: la conexión de Studio cambia de modo durante la sincronización; no se dan por verificadas todavía.
