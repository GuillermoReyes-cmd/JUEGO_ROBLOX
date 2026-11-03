---
tipo: bitacora
actualizado: 2026-11-03
---

# 📓 Bitácora del proyecto

Registro cronológico de todo lo hecho. La entrada más reciente va arriba. Cada entrada dice **qué** se hizo, **quién** lo hizo y **dónde** quedó.

Volver a [[INICIO]].

---

## 2026-11-03

### T21 Monstruos en el mundo (Claude, rama `tarea/T21-monstruos`)
- **Hecho:**
  - 5 zonas de prueba con puertas por Poder.
  - 26 monstruos que deambulan, persiguen, golpean al dragón y lanzan círculos.
  - Tu dragón vuela al monstruo marcado y lo ataca solo.
  - Clics = zarpazos con combo y crítico.
  - Recompensa compartida (≥ 10 % del daño) y MVP +50 %.
  - Vida del dragón con desmayo de 5 s.
- **Se eliminó la arena privada (T03 v2).** Sus fórmulas viven ahora en `DamageService`, que reutilizarán el jefe y los duelos.
- **Verificación:** 25 pruebas simuladas superadas y el proyecto compila. **Falta probarlo en Studio.**
- La simulación encontró un detalle que se corrigió: al despertar del desmayo, la vida empezaba a regenerarse al instante en vez de volver con el 50 %.
- Ficha: [[T21-monstruos-mundo]].

### T19 asignada a Codex
- Ficha [[T19-especies-evolucion]]: compra de evolución, ventana con vista previa, cinemática y aviso al servidor.
- Rama desde `tarea/T18-dragon`.

### Modelos 3D con IA: Claude puede generarlos (investigación)
- Studio incluye un **servidor MCP**: Assistant → … → Manage MCP Servers → «Enable Studio as MCP server».
- Con él, Claude Code puede usar `generate_mesh` (malla 3D con textura a partir de texto) y también `screen_capture`, `start_stop_play`, `get_console_output` y `execute_luau`.
- Es decir, **Claude podría generar los modelos y probar el juego en Studio por sí mismo**.
- Pendiente: que Guillermo active la conexión.

### T19 Especies y evolución v3 (Codex, rama `tarea/T19-especies`)
- Rama creada desde `origin/tarea/T18-dragon`. T04 queda sustituida y respaldada en `tarea/T04-evoluciones` (`91a1b0b`), sin integrar partes del avatar.
- Compra validada de especies con Victorias y límite de una compra cada 0,5 s por jugador. Reconstrucción automática del compañero por T18.
- Ventana con ActiveModal, nombre y tipo de especie, costos y multiplicador; previa mediante retrato con nombre y colores (alternativa autorizada en la ficha).
- Cinemática de 2 s solo para el dueño, con restauración de cámara, destello elemental y partículas en espiral. Avisos de 4 s para todos, en cola.
- Config y módulos del dragón intactos. Contrato de remotes y ActiveModal documentado en arquitectura.
- Verificación: sintaxis y Rojo correctos; pruebas simuladas del servicio con costos y especies reales aprobadas. Falta comprobar cámara, efectos, replicación y persistencia en Studio; pasos en [[T19-especies-evolucion]].
- Estado: **En revisión**. Sin merge a main.

### T18 Dragón compañero (Claude, rama `tarea/T18-dragon`)
- **Plan v3 aprobado** por Guillermo, con el calendario D-015.
- **Hecho:**
  - Cada jugador tiene su dragón, que todos ven.
  - Le sigue con física fluida, porque la propiedad de red es del dueño.
  - Se anima por código según su tipo: rebota, camina, repta, vuela u ondula.
  - Reacciona a cada clic de entrenamiento.
  - Cambia de especie con `/evo` y de elemento con `/rebirths`.
- **10 dragones provisionales distintos** mientras llegan los modelos de IA (T20).
- **Verificación:** se simuló el armado de las 10 especies (todo correcto) y el proyecto compila. **Falta probarlo en Studio.**
- **Organización:**
  - La carpeta de Claude pasa a llamarse `Juego Roblox - Claude` (worktree).
  - El enlace de Obsidian apunta ahí.
- Ficha: [[T18-dragon-companero]].

### Rediseño v3: entrenador + dragón compañero (Claude, diseño)
- **Tras probar la v2, Guillermo pidió:**
  - Animaciones más bonitas y con más movimiento.
  - Entender por qué no es un dragón.
  - Pelear en el mundo y no en otro lugar.
  - Competencia entre jugadores.
  - Que el dragón evolucione por todos los tipos de dragón.
  - Modelos generados con IA.
- **Notas nuevas o reescritas:**
  - [[Vision-v3]]
  - [[Dragones]]: 10 especies, de huevo a Níðhöggr.
  - [[Combate]]: v3.
  - [[Enemigos]]: zonas.
  - [[Competencia-y-Boosters]]
  - [[Arte-IA]]: textos para generar los 23 modelos.
- **Decisiones:** de [[Decisiones#D-011 Entrenador con dragón compañero]] a D-015.
- **Aviso de propiedad intelectual:** se descartan los nombres de Juego de Tronos y Tolkien; se usa mitología.
- **Estado:** diseño **pendiente de aprobar** antes de programar.
- **Consecuencias:**
  - T04 v1 (Codex) queda sustituida.
  - T03 v2 se reutilizará como núcleo de daño.

### Combate de acción v2 (Claude, rama `tarea/T03-combate`)
- El combate v1 (pisar una plataforma y ver barras) se sintió **demasiado básico** al probarlo.
- Rediseño completo en [[Combate]] y [[Enemigos]]:
  - El dragón ataca solo y con clic hace ataques rápidos (críticos y combos).
  - Los enemigos lanzan ataques marcados con círculos rojos que hay que esquivar.
  - Cada nivel tiene un enemigo con forma, animaciones y ataques propios.
  - El jefe tiene 2 fases.
- Decisión: [[Decisiones#D-010 Combate de acción en arena privada]].

### Bóveda de Obsidian (Claude)
- El proyecto se enlaza dentro de la bóveda `GuillermoObs`, en `002-Proyectos/Juego Roblox - Dragon`.
- Notas nuevas: [[INICIO]], esta bitácora, [[Decisiones]], [[Combate]] y [[Enemigos]].

### Combate v1 (Claude, T03)
- Plataformas de enemigo con cartel, duelo automático de 2 a 6 s, Victorias y tiempos de espera.
- Plataformas de prueba automáticas en Studio.
- Sustituido por la v2 el mismo día.

### Revisión de T04 Evoluciones (Claude revisa a Codex)
- Veredicto: **aprobable**.
- 4 mejoras pedidas a Codex:
  - Escala relativa al avatar original.
  - Botón de ancho fijo.
  - Evitar reconstruir las partes dos veces.
  - Documentar `ActiveModal`.
- Pendiente de comprobar en Studio: la posición de las partes al escalar.

### T04 Evoluciones (Codex, rama `tarea/T04-evoluciones`)
- Compra de evoluciones validada en el servidor.
- Partes visuales provisionales que se acumulan; escala en las evoluciones 8 y 10.
- Ventana con el contrato `ActiveModal`.

### Incidente: Codex y Claude en la misma carpeta
- Codex trabajaba en local en la carpeta principal. Al crear la rama de T03, sus cambios sin guardar quedaron en ella.
- Solución: la carpeta principal volvió a la rama de Codex y Claude pasó a un *worktree*, `Juego Roblox - T03`.
- Regla nueva: [[Decisiones#D-009 Una carpeta por agente]].

### Git y GitHub (Claude + Guillermo)
- Git 2.56 instalado; repositorio privado `GuillermoReyes-cmd/JUEGO_ROBLOX`.
- `.gitattributes` con finales LF para que Codex (Linux) y Windows no choquen.

### Organización para trabajar con Codex (Claude)
- Reglas comunes en [[AGENTS]].
- `docs/` dividido en visión, arquitectura, tareas y flujo.
- [[TABLERO]] con las tareas T00–T17 y fichas detalladas para T03–T06.
- El código se reorganizó en módulos que se cargan solos:
  - `Remotes.Get`.
  - `DataService.RegisterDefaults`.
  - `Config` dividido por sistema.
  - `DebugService` con trucos de chat para Studio.

### Entrenar con clic en cualquier lugar (Claude, T02)
- Petición: quitar el botón ENTRENAR. Ahora un clic o toque en cualquier parte entrena, con un «+X» flotante donde se hace clic.

### Rojo configurado (Claude, T00–T01)
- Rokit, Rojo 7.7.1 y Luau instalados; plugin de Rojo en Studio.
- Primer código:
  - Entrenar.
  - Guardado con DataStore, que no pisa la partida si la carga falla.
  - Leaderstats.
  - HUD.
- Probado por Guillermo en Studio: **funciona**.

### Diseño del juego (Claude)
- Se eligió el concepto «+1 Evolución de Dragón» frente a otros ganchos (globo, imán, teclado).
- Documento: [[Diseno-juego-Dragon]].

## 2026-11-02

### Análisis de mercado (Claude)
- Datos reales de Roblox: rankings, ingresos y precios de 16 juegos.
- Recomendación: un juego incremental «+1» como primer proyecto.
- Documento: [[Analisis-mercado-Roblox]].
