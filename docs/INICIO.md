---
tipo: indice
proyecto: "+1 Evolución de Dragón"
actualizado: 2026-11-03
---

# 🐉 +1 Evolución de Dragón: inicio

Juego de Roblox del género «+1 Evolución». Cada clic da Poder, con el Poder se vencen enemigos en batallas de acción, y las Victorias compran evoluciones de dragón.

> **Meta:** lanzar antes del 1 de diciembre de 2026 y estrenar con un evento de Navidad.

## 🧭 Mapa del proyecto

| Área | Nota | Para qué |
|---|---|---|
| Visión | [[Analisis-mercado-Roblox]] | Por qué este juego: datos reales de Roblox |
| Visión | [[Diseno-juego-Dragon]] | Diseño general: bucle, evoluciones, monetización |
| Visión | [[Combate]] | **Diseño detallado del combate de acción** |
| Visión | [[Enemigos]] | Ficha de cada enemigo: niveles, ataques y aspecto |
| Código | [[ARQUITECTURA]] | Cómo está hecho el código y qué es de quién |
| Tareas | [[TABLERO]] | Qué falta, quién lo hace y su estado |
| Trabajo | [[FLUJO-CON-CODEX]] | Cómo repartir el trabajo entre Codex y Claude |
| Historia | [[Bitacora]] | **Todo lo que se ha hecho, por fecha** |
| Historia | [[Decisiones]] | Cada decisión importante y su porqué |
| Reglas IA | [[AGENTS]] | Reglas que siguen Codex y Claude |

## 📌 Estado actual
- ✅ Base: Rojo, guardado, entrenar con clic en cualquier lugar.
- ✅ Evoluciones (T04, Codex): en revisión, con mejoras pedidas.
- 🔨 Combate de acción v2 (T03, Claude): auto-ataque, clics rápidos, esquivar y enemigos animados por nivel.
- ⏳ Renacimiento (T05), Tienda (T06), Mapa (T08) y Modelos (T09).

## 🗂️ Convenciones de esta bóveda
- Las notas viven en el repositorio de Git: Codex y Claude las leen y las actualizan.
- Cada vez que se termina algo, se añade una entrada en [[Bitacora]].
- Cada decisión de diseño o técnica va a [[Decisiones]], con fecha y motivo.
- Los números del juego **no** se cambian en las notas sino en `src/shared/Config/`. Las notas explican el porqué.
