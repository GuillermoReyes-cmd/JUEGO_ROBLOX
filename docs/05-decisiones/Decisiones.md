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
