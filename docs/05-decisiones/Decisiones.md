---
tipo: decisiones
actualizado: 2026-11-03
---

# 🧠 Registro de decisiones

Cada decisión importante, con su **fecha**, el **porqué** y qué **alternativas** se descartaron. Si una decisión cambia, no se borra: se marca como sustituida.

Volver a [[INICIO]].

---

## D-001 Género: incremental «+1 Evolución»
- **Fecha:** 2026-11-03
- **Decisión:** juego «+1 Evolución» con tema de dragón.
- **Por qué:** es la familia de juegos más en auge en el momento del análisis (Ojos de anime 22k CCU, Veneno 19k), y los competidores con dragones son débiles (máx. ~450 CCU). Detalle en [[Analisis-mercado-Roblox]].
- **Descartado:**
  - «Roba un X»: el más rentable pero el más saturado, y más difícil para un nivel básico.
  - Globo, imán, teclado escape: ganchos más débiles.

## D-002 Monetización: escalera de 49–499 R$
- **Fecha:** 2026-11-03
- **Decisión:** la mayoría de productos entre 49 y 499 R$, multiplicadores desde 3 R$ y un ancla de 3.999 R$.
- **Por qué:** es la estructura real de los juegos «+1» exitosos. Ver [[Diseno-juego-Dragon#7. Monetización]].

## D-003 Herramientas: Rojo + Rokit
- **Fecha:** 2026-11-03
- **Decisión:** el código vive en archivos `.luau` sincronizados con Rojo 7.7.1.
- **Por qué:** permite que las IAs escriban código directamente y que Git guarde el historial.
- **Descartado:** copiar y pegar scripts en Studio, porque es lento al iterar.

## D-004 Entrenar con clic en cualquier lugar
- **Fecha:** 2026-11-03
- **Decisión:** sin botón de ENTRENAR.
- **Por qué:** petición de Guillermo tras probarlo; se siente más natural.

## D-005 Módulos autocargables y núcleo protegido
- **Fecha:** 2026-11-03
- **Decisión:** los servicios se cargan solos, con `Remotes.Get`, `RegisterDefaults` y `Config` por sistema.
- **Por qué:** así varias tareas en paralelo no editan los mismos archivos.

## D-006 Trabajo en equipo Codex + Claude
- **Fecha:** 2026-11-03
- **Decisión:**
  - Reglas comunes en [[AGENTS]].
  - Cada tarea tiene ficha y «archivos permitidos».
  - Claude se encarga del núcleo y de los sistemas críticos, y revisa a Codex.
- Ver [[FLUJO-CON-CODEX]].

## D-007 Git + GitHub privado
- **Fecha:** 2026-11-03
- **Decisión:** repositorio `GuillermoReyes-cmd/JUEGO_ROBLOX`, privado, con una rama por tarea.
- **Por qué:** permite deshacer, trabajar en paralelo y conectar Codex en la nube.

## D-008 Trucos de prueba solo en Studio
- **Fecha:** 2026-11-03
- **Decisión:** `DebugService` con `/power`, `/wins`, `/evo`, `/rebirths` y `/reset` en el chat; desactivado fuera de Studio.
- **Por qué:** la barra de comandos de Studio no comparte módulos con el juego.

## D-009 Una carpeta por agente
- **Fecha:** 2026-11-03
- **Decisión:** Codex y Claude nunca trabajan en la misma carpeta a la vez. Si los dos están en local, uno usa un *worktree*.
- **Por qué:** pasó una vez y los cambios de Codex quedaron en la rama de Claude (ver [[Bitacora]]).

## D-010 Combate de acción en arena privada
- **Fecha:** 2026-11-03
- ⚠️ **Sustituida por [[#D-012 Combate en el mundo con competencia]]:** se conserva la mecánica, pero no la arena privada.
- **Sustituye a:** combate v1 (duelo automático en la plataforma).
- **Decisión:**
  - Al pisar la plataforma de un enemigo, el jugador entra en una **arena privada**.
  - El dragón **ataca solo**, y el **clic** da ataques rápidos con críticos y combo.
  - El enemigo tiene ataques normales y **ataques especiales marcados con círculos rojos** que se esquivan.
  - Hay tiempo límite y vida propia de la batalla.
- **Por qué:** al probarlo, Guillermo encontró la v1 muy básica. Los «+1» exitosos hacen participar al jugador en la pelea.
- **Detalles técnicos:**
  - El servidor manda: vida, daño, golpes y esquivas se calculan allí.
  - El enemigo y sus animaciones se dibujan en el cliente, porque en la arena privada solo lo ve su jugador. Así las animaciones son fluidas.
  - Las animaciones son procedurales (por código) hasta que existan modelos animados reales (T09).
- **Descartado:** enemigos sueltos por el mapa con IA, porque cuesta mucho más.
- Ver [[Combate]] y [[Enemigos]].

## D-011 Entrenador con dragón compañero
- **Fecha:** 2026-11-03
- **Decisión:** el jugador conserva su avatar y tiene un **dragón compañero** que le sigue, pelea y, más adelante, se puede montar.
- **Por qué:**
  - Con el v2, Guillermo no entendía por qué no era un dragón.
  - El compañero da un dragón completo y visible sin perder el avatar del jugador.
  - Es el mayor escaparate social del juego.
- **Sustituye a:** las partes de dragón pegadas al avatar (T04 v1).
- **Descartado:**
  - Ser un dragón desde el inicio: se pierde el avatar.
  - Humano que se transforma: se ve poco dragón.
- Ver [[Vision-v3]] y [[Dragones]].

## D-012 Combate en el mundo con competencia
- **Fecha:** 2026-11-03
- **Decisión:** se pelea en el mapa compartido.
  - Hay monstruos por zonas con recompensa compartida y MVP.
  - Hay un **jefe mundial cada 10 min** con ranking de daño en vivo.
  - Habrá **duelos PvP en un Coliseo** visible para todos.
- **Por qué:** Guillermo encontró simple irse a una arena privada y quiere competencia entre jugadores que impulse los boosters.
- **Se mantiene de la v2:** auto-ataque, clics con crítico y combo, círculos para esquivar, fase 2 y servidor con autoridad.
- Ver [[Combate]] y [[Competencia-y-Boosters]].

## D-013 Modelos 3D generados con IA en Studio
- **Fecha:** 2026-11-03
- **Decisión:**
  - Guillermo genera los modelos con el Asistente de Studio, siguiendo las indicaciones de [[Arte-IA]].
  - Los dragones con alas se generan en piezas (cuerpo + ala) para poder animarlos.
  - El elemento se muestra con efectos, sin repintar el modelo.
- **Por qué:** con piezas hechas por código nunca se verá «bonito»; la IA da modelos únicos y gratis.
- **Descartado:**
  - Toolbox: repetido en otros juegos.
  - Solo código: se ve de bloques.

## D-014 Sin propiedad intelectual ajena
- **Fecha:** 2026-11-03
- **Decisión:** no se usan nombres ni diseños de personajes con derechos de autor (Smaug, Drogon, Rhaegal, Viserion, Balerion, Caraxes, Syrax, Vermithrax, Glaurung, Haku, el Shenron de Dragon Ball…). Sí se usan los tipos de dragón y los dragones de mitología, que son de dominio público.
- **Por qué:** Roblox retira juegos por infracción de propiedad intelectual. Arriesgar el juego entero no compensa.

## D-015 Alcance: duelos en la actualización 1
- **Fecha:** 2026-11-03
- **Estado:** ✅ **aprobada por Guillermo** («Aprobado, empieza»), junto con todo el plan v3.
- **Decisión propuesta:**
  - **Lanzamiento (1 dic):** dragón compañero, monstruos en el mundo, jefe mundial, boosters, renacimiento, tienda y mapa.
  - **Actualización 1 (~15 dic):** duelos PvP, montar y evento de Navidad.
- **Por qué:** el jefe mundial ya da competencia desde el primer día; los duelos requieren más equilibrio y sirven de gran novedad para que la gente vuelva.

## D-016 Monstruos: raíz en el servidor, cuerpo en el cliente
- **Fecha:** 2026-11-03
- **Decisión:**
  - El servidor solo mueve una **raíz invisible** por monstruo, 10 veces por segundo, con su vida y estado en atributos.
  - Cada cliente **dibuja y anima el cuerpo** y lo desliza suavemente hacia la raíz.
- **Por qué:** con unos 40 monstruos de ~20 piezas, mover todas las piezas desde el servidor saturaría la red y se vería a tirones. Así el servidor manda en todo, pero lo visual es fluido y gratis para la red.
- **Consecuencia:** los efectos (números, bolas de fuego, círculos) los dibuja cada cliente a partir de eventos del servidor.

## D-017 Recompensa compartida y MVP
- **Fecha:** 2026-11-03
- **Decisión:** todo jugador que haga ≥ 10 % del daño a un monstruo cobra sus 🏆 completas; el de más daño es MVP y cobra +50 %.
- **Por qué:** evita los «robos» de presa, que frustran, y mantiene la competencia (MVP) que impulsa los boosters de daño. Ver [[Competencia-y-Boosters]].

## D-018 Puertas de zona abiertas en el cliente
- **Fecha:** 2026-11-03
- **Decisión:** la colisión de la puerta se quita **solo en el cliente** de quien tiene el Poder. Además, el servidor no deja marcar monstruos de una zona sin su Poder.
- **Por qué:** la física del personaje la simula su propio cliente: es la forma estándar en Roblox. Si alguien hace trampa y cruza la puerta, el servidor igualmente le impide pelear allí.

## D-019 El jefe es un monstruo especial de MobService
- **Fecha:** 2026-11-03
- **Decisión:** el Rey Volcán se crea con `MobService.SpawnBoss` y aprovecha todo el combate de T21. `BossService` solo gestiona el ciclo, el ranking y los premios por puesto.
- **Por qué:** cero código de combate duplicado y una sola forma de marcar y golpear para el jugador. Los arreglos del combate valen también para el jefe.

## D-020 Claude genera y prueba en Studio vía MCP
- **Fecha:** 2026-11-03
- **Decisión:** Claude se conecta al Studio de Guillermo mediante el servidor MCP de Roblox para:
  - generar los modelos 3D (`generate_mesh`) y revisarlos con capturas;
  - colocarlos en `Assets`;
  - jugar pruebas en vivo y leer la consola.
- **Por qué:** quita a Guillermo el trabajo repetitivo, y los fallos se ven en el juego real y no solo en la simulación.
- **Límites:**
  - Guillermo debe **guardar el lugar** (los modelos no están en Git).
  - Rojo se conecta con un botón que solo Guillermo puede pulsar.

## D-021 Giro a «roba un huevo» con montar dragones
- **Fecha:** 2026-11-03
- **Estado:** **aprobada** por Guillermo el 2026-11-03.
- **Decisión:** el juego pasa a ser «Roba un Huevo de Dragón». El bucle es robar huevos a dragonas madre dormidas → incubarlos en tu guarida → los dragones dan oro → mejorar → nidos más raros. Se montan los dragones con animaciones al estilo de «Montar un dinosaurio». Diseño completo en [[Vision-v4]].
- **Por qué:**
  - La v3 tenía muchos sistemas pero no un objetivo que se entienda en 5 segundos.
  - Guillermo prefiere la estructura de «Roba un huevo» y los personajes y animaciones de «Montar un dinosaurio».
  - Estos géneros lideran Roblox en noviembre de 2026; «Montar un dinosaurio» lleva 31 M de visitas en 10 semanas.
- **Consecuencias:**
  - Se conservan los rigs, la animación, la IA de monstruos, el ciclo del jefe y el guardado.
  - Se retiran el clic +1, el combate y la evolución por compra (siguen en Git).
  - Solo se pueden robar **huevos en incubación**, nunca dragones ya conseguidos, para no frustrar a los jugadores.
- **Riesgo conocido:** «Monta un dragón» (sep 2026) es un competidor directo. Nos diferenciamos con las madres dormidas, la mitología real, el evento de la Dragona Reina y mejores animaciones.

## T35 · Niveles y costes (2026-11-03)
Upgrades usa claves Incubator, Pen, Boots, Stealth, Saddle y Radar. Costes geométricos configurables. Stealth/Saddle/Radar solo exponen nivel hasta T31/T32; no simulan efectos aún inexistentes.
