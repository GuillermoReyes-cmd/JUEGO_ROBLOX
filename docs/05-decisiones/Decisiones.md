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
- **Estado:** ⏳ **propuesta, pendiente de que Guillermo la confirme.**
- **Decisión propuesta:**
  - **Lanzamiento (1 dic):** dragón compañero, monstruos en el mundo, jefe mundial, boosters, renacimiento, tienda y mapa.
  - **Actualización 1 (~15 dic):** duelos PvP, montar y evento de Navidad.
- **Por qué:** el jefe mundial ya da competencia desde el primer día; los duelos requieren más equilibrio y sirven de gran novedad para que la gente vuelva.
