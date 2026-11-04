# T13: Rankings v4
Estado: En revisión · Rama: tarea/T13-rankings desde origin/tarea/T38-dragonario.

## Archivos permitidos
Crear src/server/Services/LeaderboardService.luau y src/shared/Config/Leaderboards.luau; docs.

## Objetivo
Top 10 de oro/s y huevos eclosionados en SurfaceGui, OrderedDataStore, refresco cada 60 s y pcall. Sin datos ni errores del servicio cuando Studio no está publicado.

## Diseño
Usar partes/modelos etiquetados Leaderboard (atributo opcional LeaderboardId = GoldPerSecond o EggsHatched; en modelos se usa Board o PrimaryPart). Si faltan, crear soportes provisionales al extremo positivo X de la carretera. Datos globales: oro/s actual y total eclosionado; redondear a enteros para OrderedDataStore. Config se requiere directamente, sin editar init.

## Bloqueos
Ninguno.

## Resultado
- Dos tablones SurfaceGui Top 10 con soportes etiquetados o provisionales y refresco a 60 s.
- OrderedDataStore por métrica. Oro/s refleja la última muestra; huevos conserva el máximo histórico. Enteros acotados para el almacenamiento ordenado.
- Llamadas de almacén y nombres bajo pcall. Place sin publicar omite acceso y muestra Sin datos.
- Sintaxis de ambos Luau y build Rojo correctos.
### Cómo probar en Studio
1. Play en un lugar sin publicar: ver ambos tablones al final positivo X de la carretera, con Sin datos y sin errores de LeaderboardService.
2. Antes de Play, crear dos modelos con parte Board y tag Leaderboard; asignar LeaderboardId GoldPerSecond y EggsHatched. Deben recibir las pantallas.
3. En un lugar publicado de prueba con API habilitada, eclosionar huevos y generar ingresos; esperar 60 s.
4. Verificar orden descendente, máximo diez jugadores, nombres y valores. Probar datos de dos servidores.
5. Sin acceso a DataStore, confirmar que el resto del juego funciona y el tablón indica Sin datos.
### Pendiente
Prueba de persistencia y clasificación entre servidores en lugar publicado.
