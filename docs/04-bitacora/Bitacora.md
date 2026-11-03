---
tipo: bitacora
actualizado: 2026-11-03
---

# 📓 Bitácora del proyecto

Registro cronológico de todo lo hecho. La entrada más reciente va arriba. Cada entrada dice **qué** se hizo, **quién** lo hizo y **dónde** quedó.

Volver a [[INICIO]].

---

## 2026-11-03

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
