# Documento de diseño: «+1 Evolución de Dragón»

Versión 0.1 · 3 de noviembre de 2026 · Estado: borrador para validar.

Este documento se basa en [Analisis-mercado-Roblox.md](Analisis-mercado-Roblox.md) y en una revisión de 283 juegos «+1» en Roblox.

---

## 1. Concepto en una frase

**Cada clic te da +1 de Poder. Con ese Poder derrotas enemigos y con las victorias evolucionas de humano a dragón legendario.** La transformación se ve en tu avatar: te salen escamas, cuernos, cola y alas, y al final puedes planear y volar.

### Por qué este concepto

- **La familia "+1 Evolución" está en su mejor momento.** Varios juegos creados hace 3–6 semanas ya tienen miles de jugadores conectados a la vez (CCU):

  | Juego | CCU | Likes | Creado |
  |---|---|---|---|
  | +1 Ojos de anime | 22,5k | 96% | 14-oct-2026 |
  | +1 Evolución de Veneno | 19,5k | 97% | 05-oct-2026 |
  | +1 Nivel de Asesino | 8,5k | — | 24-sep-2026 |
  | +1 Evolución de Titán | 2,6k | — | 05-oct-2026 |

- **La competencia directa con dragones es débil.** Hay varios «+1 Dragon Evolution»; el mejor tiene unos 450 CCU y el resto entre 2 y 30. El tema dragón es atractivo y nadie lo ha ejecutado bien todavía.
- **La lección de los ganadores** (Brazo de araña, Lengua, Ojos) es que **la mejora tiene que cambiar cómo juegas, no solo un número.** Por eso aquí las alas no son decoración: **desbloquean planear y volar.** Esa es nuestra diferencia.

### Riesgos y cómo mitigarlos

| Riesgo | Mitigación |
|---|---|
| Hay más de 280 juegos «+1»; el género está saturado | Diferenciarse con una transformación visible y vuelo, y con miniaturas e icono de calidad |
| La moda puede bajar | Lanzar en 4–5 semanas y sacar un mundo nuevo cada 1–2 semanas |
| Tu nivel es básico | Primera versión con alcance pequeño; yo escribo los scripts y tú montas el mapa y los modelos |

---

## 2. Bucle principal de juego

```
ENTRENAR (clic = +1 Poder × multiplicadores)
      ↓
PELEAR (si tu Poder ≥ el del enemigo, ganas → +Victorias)
      ↓
EVOLUCIONAR (gastas Victorias → nueva forma de dragón + multiplicador)
      ↓
AVANZAR (enemigos más fuertes → jefe del mundo → mundo nuevo)
      ↓
RENACER (reinicias Poder y Victorias → multiplicador permanente + nuevo elemento)
      ↺
```

- **Poder:** estadística que solo sube y nunca se gasta. Es el requisito para vencer enemigos.
- **Victorias:** la moneda que ganas al vencer enemigos. Se gasta en evolucionar.
- **Duración de las sesiones (a ajustar en pruebas):**
  - Primera evolución en menos de 60 segundos.
  - Primer jefe en 15–20 minutos.
  - Primer renacimiento en unos 30–40 minutos.

### Entrenar

- Clic, tap o botón = +1 Poder × (evolución × renacimiento × game passes × mascotas × boosts).
- **Zonas de entrenamiento** en el mapa con multiplicador: x1 gratis, x3 por victorias y una "Zona Dorada" x10 de pago. Este patrón se repite en todos los juegos top.
- Límite en el servidor de unos 12 clics por segundo, como protección contra trampas (exploits).

### Pelear (sistema simple, apto para nivel básico)

- Cada enemigo está en su plataforma (pad) y muestra el **Poder necesario**.
- Pisas el pad y comienza un duelo automático de 3 segundos con barras de vida y animación.
- Si tu Poder es mayor o igual al del enemigo, ganas y cobras Victorias; si no, pierdes.
- Hay un tiempo de espera corto (cooldown) entre peleas contra el mismo enemigo.
- **Jefe del mundo:** pelea con fases. A partir de la evolución 7 puedes usar el **Aliento de fuego** (tecla o botón) para hacer más daño.

---

## 3. Evoluciones del Mundo 1 «Volcán»

Las evoluciones se aplican al avatar del jugador, pegándole partes y cambiando su tamaño. No hace falta crear un personaje dragón completo en la primera versión.

| # | Forma | Costo (Victorias) | Mult. Poder | Cambio visible y de juego |
|---|---|---|---|---|
| 1 | Marca de Dragón | inicio | ×1 | Ojos brillantes |
| 2 | Escamas | 5 | ×1,5 | Escamas en los brazos |
| 3 | Cuernos | 20 | ×2 | Cuernos pequeños |
| 4 | Garras | 60 | ×3 | Garras en las manos |
| 5 | Cola | 150 | ×5 | Cola animada |
| 6 | **Alas jóvenes** | 400 | ×8 | **Puede planear** al caer |
| 7 | **Aliento de fuego** | 1.000 | ×12 | **Ataque especial contra jefes** |
| 8 | Dragón joven | 2.500 | ×18 | Tamaño ×1,25 |
| 9 | **Alas mayores** | 6.000 | ×27 | **Vuelo corto o doble salto** |
| 10 | Dragón adulto | 15.000 | ×40 | Tamaño ×1,5 + aura de fuego |

**Los mundos siguientes** suman 10 evoluciones más cada uno, con multiplicadores crecientes: Anciano, Elemental, Legendario, Cósmico…

## 4. Enemigos del Mundo 1

| Enemigo | Poder necesario | Victorias |
|---|---|---|
| Lagartija | 10 | 1 |
| Salamandra | 75 | 3 |
| Gólem de lava | 500 | 8 |
| Serpiente de fuego | 3.000 | 20 |
| Wyvern | 20.000 | 50 |
| Caballero Cazadragones | 120.000 | 120 |
| Titán de Magma | 800.000 | 300 |
| **JEFE: Rey Volcán** | 5.000.000 | 1.000 + **desbloquea el Mundo 2** |

## 5. Renacimiento (Rebirth)

- **Requisito:** 250.000 de Poder el primero, y cada siguiente cuesta ×3.
- **Reinicia** el Poder, las Victorias y la evolución actual.
- **A cambio da:**
  - Un multiplicador permanente: ×(1 + 0,5 × número de renacimientos).
  - Un **nuevo elemento de color:** Fuego → Hielo → Tormenta → Sombra → Cósmico. Es una recompensa visible para presumir.
- Ranking de renacimientos en el lobby.

## 6. Sistemas de apoyo

Se añaden en la fase 2.

- **Mascotas de huevos** (crías de dragón y bestias) que dan +% de Poder. Hay que mostrar las probabilidades de cada huevo, como exige Roblox.
- **Recompensas diarias** (7 días), **misiones diarias y semanales**, y **códigos** en la descripción. Ejemplos: «DRAGON», «1KLIKES».
- **Recompensa por unirse al grupo** (aumenta los miembros del grupo, útil para anunciar actualizaciones) y **+10% de Poder jugando con amigos.**
- **Rankings** de Poder, Victorias y Renacimientos.
- **Servidores de 12 jugadores**, como los juegos top (entre 8 y 16): hay más servidores llenos y más interacción social.

---

## 7. Monetización

El diseño copia la estructura real de «+1 Ojos de anime», «Evolución de Veneno» y «Nivel de Asesino».

### Game passes (permanentes)

| Pase | R$ | Referencia en el mercado |
|---|---|---|
| Starter Pack (solo una vez) | 29 | Ojos 29 · Asesino 29 · Veneno 39 |
| Poder x2 | **3** | Ojos 3 · Asesino 3 (enganche para la primera compra) |
| Poder x4 | 19 | Ojos 19 · Asesino 19 |
| Poder x8 | 39 | Ojos 39 · Asesino 39 |
| Poder x16 | 69 | Ojos 69 · Asesino 69 |
| Poder x32 | 99 | Asesino 99 · Ojos 139 |
| Poder x64 | 149 | Asesino 149 · Ojos 229 |
| Poder x128 | 349 | Asesino 349 · Ojos 359 |
| Poder x256 | 599 | Asesino 599 · Ojos 589 |
| Poder x512 | 999 | Asesino 999 · Ojos 799 |
| Velocidad x2 | 29 | Ojos 29 · Asesino 29 |
| 2x Victorias | 99 | Veneno 99 · Brazo 149 |
| Auto-entrenar | 79 | — |
| Auto-renacer | 99 | Ojos 99 |
| +1 / +2 mascotas equipadas | 49 / 99 | Ojos 49 / 99 |
| Zona Dorada (entrenamiento x10) | 249 | Salto de piedras 249 |
| VIP (chat dorado, +10% Poder) | 199 | Ojos 199 · Brazo 299 |
| Dragón exclusivo «Dragón del Vacío» | 799 | Ojos (Kyubi) 799 |
| **Pack OP Definitivo (ancla)** | 3.999 | Ojos 3.999–4.999 |

Los multiplicadores de Poder no se suman entre sí: se aplica el más alto que tengas.

### Developer products (consumibles, repetibles)

| Producto | R$ |
|---|---|
| Paquete de Poder 1 / 2 / 3 (escala con tu progreso) | 9 / 49 / 199 |
| Saltar evolución (escalera del nivel 1 al 10) | 9 · 14 · 24 · 39 · 69 · 99 · 179 · 249 · 499 · 899 |
| Saltar renacimiento | 19 · 49 · 99 |
| Revivir en pelea / Saltar jefe | 14 / 29 |
| Boost x2 Poder 10 min · x5 15 min · x10 15 min | 14 · 49 · 99 |
| Boost de servidor x2 Poder, 30 min (lo ven todos) | 149 |
| Huevo normal x1 / x3 / x10 | 49 / 129 / 399 |
| Huevo premium x1 / x3 / x10 | 199 / 549 / 1.499 |
| Suerte x2 / x4 para huevos | 49 / 189 |
| Refrescar misiones | 29 |
| Dragón limitado de evento | 799 |
| Versión **[REGALO]** de los principales | igual |

### Reglas de monetización

- **En la primera versión: unos 6 game passes y unos 10 productos.** El resto se añade con los mundos 2 y 3.
- Mostrar las probabilidades de todos los huevos y explicar numéricamente cuánto mejora cada boost de suerte.
- Activar los **precios regionales** (Managed Pricing) en los productos.
- Nada de presión engañosa: el público es joven y Roblox modera esas prácticas.

---

## 8. Diferenciadores frente a los otros «+1 Dragon Evolution»

1. **Transformación progresiva visible del avatar.** Se ve en el servidor y en las miniaturas, y da mucho material para TikTok y Shorts.
2. **Las alas desbloquean movimiento:** planear (evolución 6) y volar (evolución 9). Además hay **atajos aéreos** en el mapa, a los que solo llega quien evolucionó.
3. **Aliento de fuego** como habilidad activa contra jefes. Hace que el combate no sea solo comparar números.
4. **Elementos por renacimiento** (Fuego, Hielo, Tormenta, Sombra, Cósmico): un cambio de color que sirve para presumir.
5. **Mundos nuevos cada 1–2 semanas**, con la etiqueta [W2], [W3]… en el título. Todos los «+1» exitosos lo hacen.

---

## 9. Plan técnico

Pensado para nivel básico: yo escribo los scripts y tú montas el mapa en Studio.

### Herramientas

- **Roblox Studio**: mapa, modelos y pruebas.
- **Opción recomendada: Rojo + VS Code.** Yo escribo el código directamente en esta carpeta y Rojo lo sincroniza con Studio. Te ahorra copiar y pegar scripts. Lo configuramos juntos.
- **Alternativa:** te entrego cada script y lo pegas en Studio. Es más simple de empezar, pero más lento al iterar.

### Estructura del código

```
ServerScriptService/
  DataService        → guardar y cargar el progreso (ProfileStore / DataStore)
  TrainService       → clics → Poder (validado en el servidor, límite de clics por segundo)
  CombatService      → duelos contra enemigos y jefes, entrega de Victorias
  EvolutionService   → comprar evolución, aplicar partes y tamaño al avatar
  RebirthService     → renacimientos y elementos
  ShopService        → game passes y ProcessReceipt (compras seguras, sin duplicados)
ReplicatedStorage/
  Config/            → tablas de evoluciones, enemigos y productos (los números de este documento)
  Remotes/           → eventos cliente-servidor
StarterPlayerScripts/
  UI                 → contador de Poder, botones de tienda, ventana de evolución
```

**Reglas clave:**
- Todo el progreso se calcula en el **servidor**, para evitar trampas.
- Las compras se procesan con un `ProcessReceipt` que no repite la entrega aunque Roblox reintente la compra.
- Los números grandes se muestran con formato (1,2K · 3,4M · 5,6B).

---

## 10. Plan de trabajo

Hoy es 3 de noviembre: **la meta es lanzar antes del 1 de diciembre** para llegar con un evento de Navidad.

| Semana | Entregable |
|---|---|
| 1 (3–9 nov) | Configuración (Studio, grupo, Rojo), mapa base del Mundo 1, entrenamiento y Poder, guardado de datos |
| 2 (10–16 nov) | Enemigos, duelo, Victorias y las 10 evoluciones con las partes visuales del avatar |
| 3 (17–23 nov) | Renacimiento, jefe con Aliento de fuego, interfaz, 6 game passes y 10 productos, rankings |
| 4 (24–30 nov) | Huevos y mascotas, recompensas diarias, códigos, miniatura e icono, pruebas con amigos → **lanzamiento** |
| 5+ | Mundo 2 «Hielo» + **evento de Navidad**, y luego un mundo nuevo cada 1–2 semanas |

## 11. Nombre del juego (pendiente de decidir)

Roblox traduce el nombre automáticamente, así que el nombre principal debe estar en inglés. Opciones:

- **+1 Become a Dragon 🐉** (recomendado: claro, sin conflicto con los juegos existentes)
- +1 Dragon Power Evolve
- [🔥] +1 Dragon Evolution Legends

## 12. Métricas para saber si vamos bien

Se miden en el panel de Analytics de Roblox:

- Retención al día 1 de 25% o más, y al día 7 de 8% o más.
- Sesión media de 15 minutos o más.
- Tasa de pagadores de 1% o más, y que el ingreso diario por jugador mejore cada semana.
- Likes por encima de 90%. Los juegos «+1» exitosos tienen entre 95% y 98%.
