# T38: Dragonario
Estado: En revisión · Rama: tarea/T38-dragonario desde origin/tarea/T37-renacer.

## Lecturas
AGENTS.md, Vision-v4 §5.8, ARQUITECTURA y Partida-Montar-un-dinosaurio §4 (origin/investigacion/partida-dino).

## Archivos permitidos
Crear src/server/Services/DexService.luau, src/client/DexController.client.luau y src/shared/Config/Dex.luau. Una línea en Config/init.luau; docs.

## Diseño y contrato
- Dex: claves SpeciesId|Mutation|true o false. Diez variantes actuales (cinco mutaciones × gigante sí/no).
- DexClaimed: recompensa de especie cobrada; DexBiomes: premio de bioma cobrado. No se reinician al renacer.
- Completar bioma significa descubrir todas sus especies al menos una vez; todas las variantes son colección adicional. Premio de oro y silla se cobran una sola vez mediante Reclamar todo; multiplicador permanente desde completar el bioma.
- Remotes DexRequest (sin argumentos), DexData (servidor→dueño), DexClaim (Id de especie o All). Validación y antispam en servidor.
- Recompensas, intervalos y multiplicadores en Config.Dex. El servicio observa Dragons al cargar y cada 2 s, sin editar StableService.
- ActiveModal Dex, botón y=65 % con indicador de recompensas.

## Bloqueos
Ninguno de implementación.

## Resultado
- Álbum por biomas derivado de Species, siluetas desconocidas, retratos provisionales propios, rareza, oro/s base, Myth y variantes X/10.
- Descubrimiento al cargar y cada 2 s. Recompensas por especie, Reclamar todo, indicador rojo y premio de bioma con silla/multiplicador.
- Marcas persistentes antes del pago, sin yield; reclamaciones duplicadas y falsas no pagan.
- Sintaxis de cuatro archivos y build Rojo correctos.
### Cómo probar en Studio
1. Play; abrir Dragonario: todos desconocidos en una partida nueva.
2. `/incubar Prado`, `/listo`, eclosionar. En 2 s debe aparecer ficha y aviso rojo.
3. Reclamar la especie; repetir: el oro no vuelve a subir. Vender el dragón no borra el descubrimiento.
4. Añadir en servidor variantes Normal/Gold con Giant true/false: comprobar contador y claves.
5. Descubrir Draco, Cuelebre y Guivernillo: Prado completo, SaddlePrado true y multiplicador ×1,05. Reclamar todo cobra premio de bioma una sola vez.
6. Renacer y reconectar: colección, premios cobrados y silla se conservan.
7. Probar tablet/teléfono, cambio de páginas y exclusión de modales.
### Pendiente
Validación visual, prueba multijugador y persistencia con DataStore publicado.
