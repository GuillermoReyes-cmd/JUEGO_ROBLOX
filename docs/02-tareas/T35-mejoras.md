---
tarea: T35
responsable: Codex
rama: tarea/T35-mejoras
estado: En revisión
---
# T35: Mejoras con oro

## Objetivo
Implementar Vision-v4 §5.6. Seis mejoras compradas con oro, validadas por el servidor; costes crecientes y topes en Config.Upgrades. Incubadoras 2→8 y corrales 3→12. Botas modifica WalkSpeed; Stealth, Saddle y Radar exponen niveles para T31/T32.

## Archivos permitidos
- Crear src/server/Services/UpgradeService.luau, src/client/UpgradeController.client.luau y src/shared/Config/Upgrades.luau.
- Editar src/shared/Config/init.luau (una línea) y docs.

## Contrato
Upgrades es un diccionario de niveles por Id: Incubator, Pen, Boots, Stealth, Saddle, Radar. Atributos Upgrade<Id> y, para los consumidores T31/T32, Stealth, Saddle, Radar. Remote Upgrade recibe únicamente Id. IncomeService.SpendGold cobra; IncubatorService.Render y StableService.Refresh actualizan el mundo. UpgradeService.Refresh reaplica atributos y botas (también después del renacer). ActiveModal = Upgrades, botón 200×48 en y=45 %.

## Bloqueos
Ninguno de implementación.

## Resultado
- Implementadas seis mejoras, precios crecientes, límites y antispam de 0,3 s. Cobro y datos exclusivamente en servidor. Botas reaplicadas al reaparecer.
- Sintaxis de los cuatro Luau y build Rojo correctos.
### Cómo probar en Studio
1. Sincronizar con Rojo y Play. Escribir `/oro 1000000`.
2. Abrir Mejoras (45 %). Comprar cada mejora y comprobar descuento, nivel y próxima tarifa.
3. Verificar incubadoras y corrales desbloqueados, topes 8/12 y botas tras reaparecer.
4. Abrir Establo: Mejoras debe cerrarse. Probar móvil y compras sin saldo.
5. En servidor comprobar atributos Stealth/Saddle/Radar. En cliente enviar Id desconocido, tabla, argumentos extra y ráfagas: no deben conceder niveles ni saldo.
### Pendiente
Prueba interactiva y persistencia real en Studio; no se declaran verificadas por la compilación.
