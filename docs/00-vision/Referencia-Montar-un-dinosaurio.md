---
tipo: investigacion
estado: para revisión
actualizado: 2026-11-03
autor: Codex
universo_referencia: 10758824872
lugar_referencia: 93523763376122
---

# Referencia: Montar un dinosaurio

Volver a [[INICIO]] · Diseño vigente: [[Vision-v4]] · Trabajo relacionado: [[TABLERO]]

**Conclusión:** la referencia más útil es la unión entre una acción física divertida, una captura confirmada, un corral que convierte esa captura en renta y una siguiente mejora visible. Para «Roba un Huevo de Dragón», sustituir la doma por robo → huida → incubación conserva esa estructura. El tutorial y la sensación de montar merecen prioridad sobre añadir más tiendas o monedas.

## Alcance, método y fiabilidad

Investigación del **3 de noviembre de 2026, hora de Lima**. Solo consultas públicas, sin cuenta, sin partida propia y sin compras. Se consultaron las API de los tres universos, se recorrieron todas las páginas de productos y se revisaron vídeos públicos, guías y miniaturas disponibles. No se entró al cliente de Roblox. La revisión audiovisual fue parcial: YouTube permitió reproducir fragmentos iniciales, pero varios saltos a minutos posteriores quedaron cargando o dieron error. **No se presenta un recorrido cronometrado propio ni una observación completa de todas las animaciones.**

Etiquetas usadas:

- **[API]**: respuesta pública consultada directamente; confirma lo que el desarrollador anuncia o pone a la venta, no una prueba del comportamiento interno.
- **[V]**: detalle visible directamente en los fragmentos de vídeo revisados. Se enlaza el momento aproximado.
- **[G]**: guía de terceros; puede estar desactualizada o equivocarse. Varios sitios parecen repetir fuentes: no se cuentan como pruebas independientes.
- **[C]**: observación de Claude aportada por Guillermo, sin reconfirmación independiente cuando se indica.
- **[P]**: propuesta o interpretación para nuestro juego; no decisión aprobada.
- **Pendiente**: información que las fuentes accesibles no permiten asegurar.

La petición de este chat es la ficha de investigación: autoriza esta nota, el enlace de inicio y la bitácora, en `investigacion/montar-dino`. No se modifica `src/`, el tablero, las fichas de implementación ni las decisiones aprobadas.

### Identidad y comparación de los tres juegos

Instantánea de la API; concurrencia y votos cambian continuamente. Aprobación = votos positivos / votos totales; **no equivale a retención ni a ingresos**.

| Juego y creador | Universo / lugar | Jugadores en la consulta | Visitas | Votos + / − | Aprobación | Plazas |
|---|---|---:|---:|---:|---:|---:|
| Ride a Dino — and Catch Them All | 10758824872 / 93523763376122 | 11.760 | 31.465.425 | 118.343 / 3.068 | 97,47 % | 8 |
| Ride a Dragon — Ride A Dragon [Glacius] | 10767814136 / 99432045075207 | 1.124 | 2.103.873 | 3.265 / 556 | 85,45 % | 6 |
| Steal A Pet And Ride It! — Snail Riders | 10769315427 / 95168737547508 | 29.021 | 21.002.254 | 22.113 / 1.248 | 94,66 % | 7 |

Fuentes: [datos de los tres universos](https://games.roblox.com/v1/games?universeIds=10758824872,10767814136,10769315427) y [votos](https://games.roblox.com/v1/games/votes?universeIds=10758824872,10767814136,10769315427).

| Comparación [API] | Ride a Dino | Ride a Dragon | Steal A Pet And Ride It! |
|---|---|---|---|
| Adquisición central | Saltar a la estampida y domar montando | Encontrar huevos, eclosionar | Robar jaulas a jefes dormidos y huir |
| Progreso de movimiento | Entrenar Grip en máquinas | Alimentar dragones para subir nivel y volar más rápido/alto | Cinta de entrenamiento y mascotas más rápidas |
| Economía | Corrales y capturas; mejoras de corral | Dragones producen dinero, según pase ×2 | Mascotas generan dinero en el granero |
| Amplitud anunciada | 9 eras, más de 50 especies, secretos ocasionales | Huevos más raros al llegar más alto | 20 biomas en 2 mundos, segundo granero |
| Bucle largo anunciado | Colección y secretos | Mejora de dragones; catálogo incluye renacer | Renacer conserva mascotas |
| Aporte más útil [P] | Montura, tutorial, escaparate social | Claridad de vuelo, incubación y utilidad de cada mejora | Tensión dormir → robar → perseguir → llegar a casa |

Fuentes oficiales: [Dino](https://www.roblox.com/games/93523763376122/Ride-a-Dino), [Dragon](https://www.roblox.com/games/99432045075207/Ride-a-Dragon), [Pet](https://www.roblox.com/games/95168737547508/Steal-A-Pet-And-Ride-It). La descripción de Dragon no confirma que se roben huevos de otros jugadores. Su catálogo sí confirma huevos transportados que pueden romperse. No extrapolar reglas de PvP a partir del título del género.

**Evitar un falso positivo:** otro Ride a Dino, de *Dino Riders!*, usa el lugar `131652231424227` y trata de huevos. Se descartaron sus guías de eclosión y mutaciones de velocidad. Aquí el bucle base es doma, aunque el catálogo actual también vende huevos estacionales.

## 1. Bucle completo: primeros diez minutos

**Reconstrucción orientativa, no tiempos medidos.** La secuencia se apoya en el tutorial observado, las notas de Claude y las guías. No hay evidencia suficiente para prometer que cualquier novato compre la máquina o complete todo en un minuto concreto. Los vídeos editados y las cuentas con compras no sirven como curva gratuita de referencia.

| Minuto orientativo | Acción del novato | Feedback y aprendizaje | Evidencia / límite |
|---|---|---|---|
| 0–1 | Leer el objetivo y acercarse al primer animal indicado | Una sola acción y un destino destacado | [V] Panel GOAL, objetivo Dodo; [C] flechas |
| 1–2 | Saltar/apuntar a un objetivo cercano y permanecer montado | Aprende dirección, salto y confirmación de captura | [V] Aviso de captura, guía izquierda/derecha; la grabación muestra reintentos |
| 2–3 | Seguir el siguiente objetivo y regresar con la captura | Domar no es todavía depositar ni activar renta | [G] Tutorial incluye Dodo y Pachycephalosaur; orden completo pendiente |
| 3–4 | Depositar en el corral propio | Criatura visible + mensaje de depósito + ingreso | [C] Corral con nombre y $/s; [G] confirmación separada |
| 4–5 | Ahorrar para la primera máquina de $300 | Entiende que la colección financia mejoras | [C] y [G] coinciden en precio; tiempo depende del rendimiento |
| 5–6 | Comprar y usar la máquina | El entrenamiento aumenta capacidad para sostener capturas | [API] Grip; [G] entrenamiento automático al interactuar |
| 6–7 | Volver a la estampida con mejores posibilidades | Comparar requisito del animal con la estadística propia | [V] Etiquetas Required; [G] barras de resistencia y captura |
| 7–8 | Encadenar intentos y volver a depositar | Repite la cadena acción → propiedad → renta | [V] Bandeja de capturas aseguradas; [G] regreso al corral |
| 8–9 | Revisar activos, almacenados y siguiente mejora | Selecciona qué criaturas ocupan capacidad productiva | [G] Active, Stored y Equip Best |
| 9–10 | Elegir entre aumentar entrenamiento, capacidad o colección | El siguiente objetivo nace de un límite visible | [P] Síntesis del sistema, no un paso obligatorio del tutorial |

El bucle recurrente es **domar → asegurar captura → depositar → producir dinero → mejorar entrenamiento/corral → intentar objetivos mejores**. La colección y las variantes dan objetivos después del tutorial. No se ha verificado cuánto tarda en amortizarse cada mejora.

Fuentes: [CHALLS, apertura](https://www.youtube.com/watch?v=KC5iiD8iHYc&t=15s), [guía de primera partida](https://rideadino.com/guides/beginners/), [controles y máquina de $300](https://9to5gaming.com/ride-dino-gameplay-tips/). Los minutos de la tabla son elaboración propia, no los capítulos de esos vídeos.

## 2. Onboarding: objetivos, flechas y avisos

| Observación aportada | Resultado de la comprobación | Qué enseña |
|---|---|---|
| Panel OBJETIVO a la izquierda | [V] GOAL en lateral izquierdo, texto de una tarea y subobjetivo | Mantiene visible la próxima acción sin abrir un menú |
| Domar → corral → máquina de $300 | [G] y [C]; primera captura confirmada directamente, resto de secuencia respaldada por guía | Conecta jugar con producir y reinvertir |
| Barra de progreso | [C]; el fragmento revisado muestra subobjetivo, pero no permitió medir el funcionamiento de la barra | Pendiente distinguir progreso de tarea y progreso de doma |
| Flechas blancas por el suelo | [C], sin reconfirmación directa del color y trazado | Indicación espacial hacia el objeto relevante |
| «!» rojo encima del cartel | [C]; [V] sí se ve un «!» **amarillo** y distancia en metros sobre el objetivo durante la doma | Son contextos distintos; no afirmar que todos los marcadores tienen el mismo color |
| Avisos grandes arriba | [V] Banner horizontal de captura y de apuntar al objetivo; [C] aviso de primera máquina | Una acción queda cerrada con confirmación explícita |
| Carteles de compra físicos | [C] y [G] distinguen Upgrade Pen de Upgrade Machine | La mejora aparece junto al sistema que modifica |

En el [fragmento de CHALLS alrededor de 0:32](https://www.youtube.com/watch?v=KC5iiD8iHYc&t=32s) se confirma la captura del Dodo mientras sigue visible el objetivo lateral. El jinete lleva un lazo y aparece una instrucción de dirección. Las guías atribuyen capítulos concretos a compras, pero algunos saltos no coincidieron con el fotograma cargado: **no se adoptan esos tiempos como verificación visual de precios**.

**Aplicación [P]:** objetivo persistente «Consigue un huevo» → «Llévalo a tu incubadora» → «Espera la eclosión» → «Coloca tu dragón» → «Cobra oro» → «Monta». Flecha a un destino accionable, mensaje de éxito solo tras confirmación del servidor y ayuda distinta si falta oro, capacidad o distancia. El tutorial no debe pedir comprar una mejora antes de mostrar cómo obtener su moneda.

## 3. Cómo se doma y monta: controles, agarre y máquinas

### Controles y estados

| Acción o indicador | Evidencia | Precisión disponible |
|---|---|---|
| Moverse con WASD | [G] guía de controles | No probado en una partida propia |
| Saltar con Space | [V] botón Space en el HUD; [G] confirma teclado | Sirve para los saltos de la carrera; no asumir idéntico comportamiento al estar en el rancho |
| Interactuar con E | [G] | No trasladar sin prueba a consola o móvil |
| Dirigir izquierda/derecha | [V] ayuda explícita bajo el jinete | Sensibilidad y giro exactos pendientes |
| Apuntar durante el salto | [V] lazo, anillo amarillo, «!» y distancia | No se pudo establecer si requiere clic sostenido o captura automática al entrar en alcance |
| Barra verde de resistencia y rosa de captura | [G] | Se deben leer separadamente: aguantar y completar captura |
| Capturas aseguradas | [V] bandeja a la izquierda con contador | No equivale a estar ya depositadas en el corral |
| Barra de siete huecos / Q | [V] siete huecos; [C] tecla Q | Función exacta de Q pendiente, no llamarla «desmontar» sin evidencia |

La [guía de controles](https://9to5gaming.com/ride-dino-gameplay-tips/) describe agotamiento de resistencia, expulsión hacia delante y saltos entre criaturas. Su afirmación de que cada salto restablece la resistencia no se ha probado aquí. La [guía de doma y Grip](https://rideadinowiki.wiki/guides/taming-and-grip/) también recoge expulsión y transferencias, pero reconoce que no publica todos los botones.

**Grip frente a Stamina:** la descripción oficial llama Grip a lo que entrenan las máquinas. Vídeos y tienda también usan Stamina. No hay base suficiente para afirmar que son dos saldos persistentes independientes ni para dar una fórmula de consumo. [V] El símbolo ⚡ aparece abajo a la izquierda; [API] los multiplicadores de Grip solo afectan entrenamiento futuro, no el saldo previo ni packs instantáneos.

### Entrenamiento

La primera máquina de **$300 de moneda interna** está respaldada por Claude y la guía de controles. [G] Al usarla, el entrenamiento sucede automáticamente. La máquina se describe como una montura de entrenamiento con muelle, junto al corral; no se ha medido su ciclo ni su tasa inicial.

La API confirma niveles de máquina vendidos por Robux: **2 Compy, 3 Parasaurolophus, 4 Raptor, 5 Triceratops, 6 Dilophosaurus, 7 Carnotaurus, 8 Allosaurus, 9 T-Rex, 10 Apex Rex**. Cada producto desbloquea y equipa solo ese nivel. Los precios están en §8 y en el catálogo; **no son la escalera de precios con dinero del juego**. [API]

Las auras añaden otra vía de progreso. [G] Se compran también con efectivo y modifican Stamina. El catálogo contiene doce niveles de aura y cosméticos que expresamente no cambian el bonus. No mezclar aura funcional y apariencia de aura.

**Aplicación [P]:** T32 puede conservar claridad de controles, objetivo alcanzable y sensación de movimiento. No importar el entrenamiento infinito de Grip: la v4 ya reemplaza ese eje por silla, velocidad, peso del huevo y sigilo (T35).

## 4. Animaciones: criatura, jinete, polvo y cámara

### Lo que se ha podido observar

- **[V]** Modelos de volúmenes gruesos y colores saturados, siluetas distinguibles en una estampida; cámara en tercera persona detrás del jinete. En [Radex, alrededor de 0:36](https://www.youtube.com/watch?v=JF_l5dWEois&t=36s), se ven varias criaturas, etiquetas, terreno y nubes claras de polvo alrededor de la acción.
- **[V]** El jinete lleva una mano levantada con un lazo durante la captura. En el salto del tutorial pasa a una pose extendida; el objetivo tiene anillo y distancia. No describir todo el sistema como «manos permanentemente sujetando riendas».
- **[V]** Hay desplazamiento de criatura y jinete durante los fragmentos reproducidos, con cámara que acompaña la marcha. **No se pudo aislar de forma fiable el patrón completo de patas, rebote de silla o flexión de cola.**
- **[C]** Las notas de visión destacan galope, polvo y velocidad como la cualidad deseada. Eso es una dirección artística del proyecto, no una medición del competidor.

### Qué sigue sin estar demostrado

Frecuencia del galope, desfase de patas, amplitud de rebote, ajuste de manos/riendas, animación de frenado y giro, partículas exactas de cada material, huellas persistentes, variación del FOV al acelerar y sacudida de cámara. Las nubes visibles no permiten atribuir cada partícula exclusivamente a una pisada; podrían incluir efectos de captura o de escenario. Una miniatura promocional tampoco demuestra una animación.

### Especificación propuesta para T32, no copia de una implementación

| Capa [P] | Comportamiento concreto | Cómo evaluar en Studio |
|---|---|---|
| Patas | Alternar apoyos en función de velocidad; congelar el avance del ciclo al parar | La montura no patina ni sigue galopando quieta |
| Cuerpo | Rebote pequeño y cabeceo subordinados a apoyos | El peso se percibe sin ocultar el huevo transportado |
| Jinete | Pelvis sobre silla, piernas a ambos lados; torso amortigua el rebote | No atraviesa cabeza, alas ni montura al girar |
| Cola y alas | Movimiento secundario; alas plegadas en carrera | Silueta legible y sin golpear visualmente al avatar |
| Polvo | Emisión breve en apoyos y al acelerar | No tapa la madre ni la salida del nido; limitar en móvil |
| Cámara | Seguimiento suave y apertura moderada opcional con velocidad | El jugador ve obstáculos; opción de reducir movimiento |
| Salto y aterrizaje | Anticipación breve, fase aérea y compresión al caer | El aterrizaje se distingue sin perder el control |

Son criterios de diseño propuestos para nuestro dragón original; no se extraen assets, rigs, código ni diseños del juego de referencia.

## 5. Corral/rancho: renta, mejoras y precios

**Confirmado [API]:** llevar capturas al rancho, mejorar corrales y ganar dinero mientras se monta. El pase ×2 dinero excluye rentas offline y packs. Un producto específico multiplica por tres el dinero acumulado durante la ausencia: hay renta offline anunciada, pero **no se conoce su tasa, límite de tiempo ni fórmula**.

**[G]** El panel distingue `Active` y `Stored`, muestra ingreso individual y permite `Equip Best` y desequipar. El regreso y el depósito son pasos separados; una captura en bandeja no demuestra renta activa. **[C]** El corral muestra propietario y $/s, y permite ver criaturas enormes de vecinos. Fuente: [guía del rancho](https://rideadino.com/guides/ranch/).

| Precio o cifra | Unidad | Fuente y alcance |
|---|---|---|
| Primera máquina: 300 | Dinero interno | [C] + [G]; no es un precio de Robux |
| Corral nivel 1 → 2: 1.000.000 | Dinero interno | [C] únicamente; capacidad añadida no reconfirmada |
| ×2 dinero: 199 | Robux | [API] pase activo; solo ingresos durante juego |
| ×3 renta offline: 29 | Robux | [API] producto contextual al volver |
| Criatura premium Magma Colossal T-Rex: 840.000/s | Dinero interno/s | [API] descripción del producto activo, no base gratuita |
| La misma criatura en pase retirado: 560.000/s | Dinero interno/s | [API] descripción antigua; ejemplo de por qué no mezclar ofertas |

No hay tabla verificada de todos los niveles del corral, tasas base por especie, límites offline o costes en efectivo de todas las máquinas. No rellenar huecos con los precios Robux de §8.

**Lectura de diseño [P]:** la base es un escaparate social y una explicación de la economía: ver una criatura más grande, su etiqueta y su renta enseña la aspiración sin un árbol de progreso. Para T30, mostrar claramente **oro acumulado**, **oro/s** y **capacidad ocupada**. Son tres magnitudes distintas. Para T35, enseñar el beneficio antes/después y la falta de oro; no solo un botón gris.

## 6. Rarezas y mutaciones

Hay que separar **especie**, **rareza**, **color/material**, **tamaño** y **evento de origen**. [API] El juego anuncia especies desde Common hasta Divine y Secret ocasionales. [V] La grabación de Radex muestra Common, Uncommon y Rare; también etiquetas Golden y Big sobre una criatura. No se ha reconstruido un catálogo completo de especies ni sus probabilidades.

| Eje | Nombres encontrados | Aspecto / anuncio y fiabilidad |
|---|---|---|
| Rareza | Common, Uncommon, Rare; Epic, Legendary, Mythic en guías; Divine y Secret en descripción oficial | [V] Texto flotante y color; [G] niveles intermedios, orden completo pendiente |
| Mutación | Silver, Golden, Rainbow | [API] Nombradas por los boosts de suerte; [V] Golden, [C] ARCOÍRIS |
| Mutación de evento | Magma | [API] Productos y criaturas; [G] asociada a tormenta y ×4 ingreso |
| Spectral | Listada por una guía de octubre como aún no obtenible | [G] Estado histórico, no confirmación vigente; Spectral Flames es además una moneda, no prueba de mutación |
| Tamaño | Tiny, Big, Giant, Huge, Colossal | [API] Fusiones confirman Big–Colossal; [G] Tiny; [C] ENORME |
| «Cósmico» | Etiqueta reportada por Claude | [C] No confirmado si designa rareza, mutación, especie o procedencia; no adjudicar multiplicador |

La [tabla de Pro Game Guides del 23 de octubre](https://progameguides.com/roblox/ride-a-dino-mutations-sizes-multipliers-how-to-get/) atribuye Silver ×1,25, Golden ×1,5, Rainbow ×2,25 y Magma ×4; Big ×1,5, Giant ×3, Huge ×5 y Colossal ×10. También propone acumulación aditiva entre tamaño y mutación. **Son cifras de una guía, no balance verificado:** su redacción de Tiny es ambigua y repite «Big» en otras filas. No trasladar esa fórmula al proyecto.

La tienda confirma una fusión de tres criaturas hacia un tamaño mayor y vende éxito garantizado para Big, Giant, Huge y Colossal; otra oferta solo duplica la probabilidad de la próxima fusión Colossal. Su texto especifica que el fallo conserva el Colossal como estaba. No inferir que todos los tipos de fusión tienen idénticas reglas de pérdida. [API]

**Anuncios:** [V] se confirma banner de captura y etiquetas sobre criaturas. [C] se ven variantes en corrales vecinos. No se ha probado que toda mutación rara provoque un anuncio global, un sonido distinto o una cinemática. **[P]** T34 puede hacer un revelado más expresivo según rareza, conservando texto legible y probabilidades verificables; T38 debe registrar cada variante sin confundir tamaño con rareza.

## 7. Eventos: noche, secretos y Halloween

| Sistema | Qué se sabe | Lo que no puede afirmarse |
|---|---|---|
| Día/noche | [C] contador como «en 4m 30s» | No es evidencia de que el ciclo dure 4m 30s, ni de un bonus nocturno específico |
| Secretos | [API] encuentros ocasionales; [G] guías muestran ejemplares raros | No hay horario universal, probabilidad ni vínculo demostrado con la noche |
| Meteor Storm | [G] anuncio histórico del 14 oct 18:30 UTC al 25 oct 15:00 UTC: esquivar impactos, entrar a cráteres por fragmentos y cofre; Magma ×4 | No confundir ventana de anuncio con frecuencia de aparición; actividad actual sin verificar |
| Halloween Island | [G] anuncio del 25 oct 16:00 UTC al 1 nov 14:00 UTC, isla tras la niebla | Una fecha de fin del anuncio no demuestra retirada de todo el contenido |
| Bone Island y Spectral Flames | [API] moneda para charms de Spooky Shop; el texto dice que se conserva después del evento | No conocemos ruta gratuita, precios de charms ni acceso actual |
| Cosméticos de Halloween | [API] apariencias de horda y aura; cosméticos permanentes, sin cambiar bonus de Stamina de aura | No asumir que comprarlos mejora la captura |
| Endless / Fossil Coins | [API] productos actuales compran moneda para mejoras permanentes de alcance de lazo, stamina, velocidad, dinero, salto de zona e imán | No se ha jugado el modo ni confirmado su entrada, duración o recompensas gratuitas |

Fuentes: [reseña de anuncios y fechas](https://rideadino.com/updates/), [evento oficial Meteor Storm](https://www.roblox.com/events/4645917996445991472), [evento oficial Halloween](https://www.roblox.com/events/7928673331056869969) y catálogo API. Las páginas oficiales de eventos solo devolvieron su envoltura JavaScript al lector web: los detalles históricos proceden de la reseña, no de una lectura directa completa del anuncio.

**[P] Para T36:** aviso anticipado, cuenta atrás estable, entrada reconocible, cambio visual y recompensa explicada. Para T26, la estructura moneda temporal + cosmético permanente puede dar un recuerdo del evento; posponer la moneda adicional si complica el lanzamiento. No copiar calendarios de aparición no verificados.

## 8. Monetización: pases, productos y precios

### Cómo se verificó

Consulta anónima el 2026-11-03. El endpoint antiguo `games.roblox.com/v1/games/{universeId}/game-passes` devolvió **404**. Funcionó **game-passes v1** en `apis.roblox.com`, con `passView=Full&pageSize=100`; las tres respuestas terminaron con `nextPageToken` vacío. Para **developer-products v2** se siguió `nextPageCursor` hasta agotarlo, sin deduplicar ofertas por nombre.

| Universo | Pases devueltos / a la venta | Productos únicos | Páginas de productos | Productos a la venta | Rango numérico de productos (Robux) |
|---|---:|---:|---:|---:|---:|
| Dino | 2 / 1 | 125 | 2 | 125 | 3–3.499 |
| Dragon | 3 / 3 | 216 | 3 | 216 | 5–4.999 |
| Pet | 14 / 13 | 225 | 3 | 224 | 5–3.999 |

Son precios públicos de `PriceInRobux` / `price`, **no recibos ni ventas observadas**. No se probó cada oferta dentro de la interfaz y `IsForSale` no demuestra que se muestre en todos los contextos. Precio nulo significa no disponible, nunca gratis. El anexo conserva los IDs y precios de los 125 productos de Dino, y todos los pases de los tres juegos.

### Familias principales de Ride a Dino

| Familia | Precios Robux | Función anunciada |
|---|---|---|
| Pase 2X Money | 199 | Doble renta online; excluye packs y offline |
| Grip permanente ×2 a ×4096, serie con guion | 3, 9, 24, 39, 79, 129, 199, 299, 499, 649, 949, 1.375 | Reemplaza multiplicador inferior; solo entrenamiento futuro |
| Grip permanente, serie con dos puntos | 6, 18, 48, 78, 158, 258, 398, 598, 998, 1.298, 1.898, 2.750 | Misma descripción, otros IDs; motivo de duplicación desconocido |
| Grip instantáneo: 150K, 1M, 10M, 50M, 500M, 1.000M | 59, 189, 525, 899, 1.499, 2.249 | Suma fija; no afectada por multiplicadores de entrenamiento |
| Máquinas niveles 2–10 | 19, 39, 69, 119, 199, 299, 499, 799, 1.299 | Desbloquear y equipar el nivel comprado |
| Auras niveles 1–12 | 9, 19, 29, 49, 79, 99, 149, 199, 299, 399, 499, 524 | Progreso adicional; no confundir con skins de aura |
| Revive I, II, III | 29, 59, 99 | Retomar donde se cayó, con el mismo dinosaurio; cada reanimación pagada de esa carrera cuesta más |
| Seis Pteranodon | 99, 199, 399, 699, 999, 1.499 | Desbloquean y equipan aeronave Air Jurrassik de nivel 1–6; solo la comprada, no vuelo universal |
| Packs de dinero: 24K, 200K, 800K, 4M, 8M | 45, 90, 225, 450, 720 | Acelerar compras internas |
| Starter Pack | 99 | Criatura, 50K, ×4 Stamina y aura nivel 1; una vez por cuenta |
| Tres criaturas premium | 499, 999, 2.499 | Criatura ya domada; rentas altas anunciadas |
| Halloween Eggs ×1/3/10/50 | 99, 249, 799, 3.499 | Huevos para el corral; descripción promete probabilidades antes de comprar |
| Garantizar fusión Big/Giant/Huge/Colossal | 19, 39, 79, 149 | Próxima fusión de ese tamaño |
| ×2 Fuse Luck | 49 | Mejora de probabilidad; no garantiza resultado |
| Suerte de servidor ×2 / ×4 durante 15 min | 99 / 349 | Tamaños y variantes concretos; repetir añade tiempo |
| ×3 recompensa offline | 29 | Solo al volver con renta por recoger |
| Spectral Flames 100/350/800/2.000 | 19, 59, 129, 299 | Moneda de Bone Island |
| Cuatro skins de horda | 49, 79, 129, 199 | Cosméticas y visibles a otros |
| Tres skins de aura | 79, 149, 229 | Cosméticas; no cambian Stamina |
| Fossil Coins 7.500/25.000/75.000/355.000 | 49, 129, 299, 799 | Mejoras permanentes de Endless |

Existen versiones `Gift` de varias familias, con IDs distintos; se enumeran en el anexo. El total de catálogo no equivale al número de botones distintos que ve un jugador. Tampoco se puede afirmar que estas sean las ofertas más vendidas.

### Qué parece más importante (inferencia, no ranking de ingresos)

1. **Pase ×2 dinero:** propuesta simple, permanente y ligada al bucle del corral. Es el único pase de Dino a la venta.
2. **Starter Pack:** empaqueta varios atajos comprensibles al principio; el límite de una compra está en la descripción.
3. **Máquinas, Grip y auras:** numerosas escalas de precio resuelven el límite de captura. Son parte estructural de la monetización observada, pero no justifican reproducir toda esa complejidad.
4. **Huevos de evento y criaturas premium:** enlazan colección, apariencia y producción. Son poder económico, no solo cosmética.
5. **Revivir, offline y fusión:** ofertas ligadas a un momento específico. Su efectividad comercial no puede medirse desde el catálogo.
6. **Skins de horda/aura:** ejemplo más claro de cosméticos explícitamente separados de estadísticas.

### Comparación útil para T06

| Juego | Oferta identificada | ID | Robux | Alcance |
|---|---|---:|---:|---|
| Dragon | Infinite Radar (pase) | 2009588258 | 99 | Localizador permanente |
| Dragon | 2x Money (pase) | 2011244253 | 149 | Doble dinero de dragones |
| Dragon | Auto Buy (pase) | 2010962267 | 20 | Compras automáticas de equipo/comida al reponer |
| Dragon | Starter Pack (producto) | 3718393632 | 20 | Oferta de entrada; no asumir mismo contenido que Dino |
| Dragon | 10x Offline Cash | 3716949947 | 15 | Multiplica renta de ausencia |
| Dragon | Egg Guard 30 min / 2 hours | 3718950112 / 3718950115 | 15 / 49 | Durante ese periodo, huevo transportado dura 15 s más; excluye huevos de evento |
| Dragon | Skip Egg Timer 9 / 25 / 49 | 3717293348 / 3717293355 / 3717293361 | 9 / 25 / 49 | Saltos de incubación; hay más escalones hasta 499 |
| Dragon | Lava Trail / Cosmic Trail | 3718950118 / 3721201064 | 199 / 199 | Estelas limitadas |
| Pet | VIP (pase) | 2038106843 | 199 | Descripción pública vacía; no atribuirle bonus exactos |
| Pet | Auto Collect (pase) | 2023022268 | 49 | Nombre indica cobro automático; descripción vacía |
| Pet | 3x Open Speed (pase) | 2022542273 | 299 | No confundir con Gift de 199, ID 3717400715 |
| Pet | Starter Pack (producto) | 3717321827 | 49 | Entrada |
| Pet | Open Now tier 1 / 2 / 3 | 3717401967 / 3717401991 / 3717402025 | 19 / 25 / 49 | Apertura contextual |
| Pet | Buy Second Barn | 3720711616 | 79 | Capacidad adicional |
| Pet | Keep Cage tier 1–5 | 3720334044 / 3720334118 / 3720334171 / 3720334280 / 3720334406 | 19 / 39 / 79 / 149 / 249 | Familia contextual; no probada en partida |

**Correcciones para interpretar [[Vision-v4]], sin editarla:**

- Dino devuelve **125 productos**, no 96; puede haber cambiado o haberse consultado un subconjunto. No concluir cuál fue la causa sin el registro anterior.
- La referencia de **Egg Guard no es un escudo de guarida**. Los precios 15/49 son comparables como importe, no como función.
- La franja 15–499 no resume todo el catálogo: existen ofertas de 3 y compras de miles de Robux. No se conoce qué franja concentra ventas.
- Vender ×2 renta, más capacidad o velocidad sí modifica progreso; si la velocidad ayuda en robos, revisar su impacto sobre PvP antes de describirla como mera comodidad.
- Los huevos aleatorios anuncian probabilidades visibles, pero no se inspeccionó su tarjeta actual. No inventar porcentajes ni certificar cumplimiento a partir del texto de tienda.

## 9. Interfaz: distribución de pantalla y mundo

| Zona | Contenido | Estado de comprobación |
|---|---|---|
| Arriba izquierda | Controles nativos Roblox | [V] |
| Arriba centro | Banner horizontal de instrucciones/éxito; durante carreras, tira de zonas y distancia | [V] Fragmentos de CHALLS y Radex; no necesariamente simultáneos |
| Izquierda media | Panel GOAL durante tutorial; bandeja y número de capturas durante carrera | [V] |
| Abajo izquierda | ⚡ y dinero con iconos diferentes | [V]; qué parte exacta de ⚡ es saldo o resistencia requiere más prueba |
| Abajo centro | Siete huecos de inventario/equipo; guía de dirección en tutorial | [V]; Q solo [C] |
| Derecha media | Botón naranja con pata | [V]; función de colección indicada por [C] |
| Abajo derecha en carrera | Control de salto con Space | [V] |
| Cuenta atrás día/noche | Texto temporal de cambio de fase | [C]; posición exacta y periodo no reconfirmados |
| Sobre criaturas | Nombre, rareza, tamaño/variante y Required ⚡; renta en corral | [V] carreras; [C] y [G] corrales |
| Sobre objetivo | Anillo, exclamación y metros | [V] tutorial de salto |
| Dentro de la base | Carteles de máquina/corral, propietario y renta | [C] + [G] |
| Ventana de gestión | Active, Stored, capacidad, ingreso, Equip Best | [G], vídeo de corral citado en la guía |

La información cambia según el estado del juego: tutorial, carrera, base o modal. **[P]** T16 necesita un mapa de zonas para la v4; no heredar sin revisión el HUD de Poder/Victorias de la arquitectura v3. T30, T31 y T32 deben poder mostrar sus indicaciones sin taparse ni ocupar el área de salto de móvil.

### Miniaturas consultadas

La [API de miniaturas](https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds=10758824872,10767814136,10769315427&countPerUniverse=10&defaults=true&size=768x432&format=Png&isCircular=false) devolvió **4 para Dino, 4 para Dragon y 6 para Pet**, todas en estado Completed. Enlaces representativos: [Dino, asset 96150419512214](https://tr.rbxcdn.com/180DAY-f8fecae0178a0050091a98a328c31ef4/768/432/Image/Png/noFilter), [Dragon, asset 71773537338111](https://tr.rbxcdn.com/180DAY-d74d2e4f898a29e6629385d7d882e5f7/768/432/Image/Png/noFilter), [Pet, asset 132202550969167](https://tr.rbxcdn.com/180DAY-2c31c54f52a3a79ef8c069711d76e346/768/432/Image/Png/noFilter). El lector web no pudo abrir las imágenes CDN; se conservan los enlaces, sin atribuirles detalles visuales no inspeccionados. Las imágenes de portada de YouTube sí se vieron, pero son arte de creadores y no prueba del aspecto real.

## 10. QUÉ COPIAR EN NUESTRO JUEGO

**Ideas de estructura e interacción, con textos, arte y especies propios.** No se propone reutilizar nombres de criaturas premium, personajes, ilustraciones, modelos, la identidad comercial ni assets del competidor. Las tareas se corresponden con el tablero v4 leído en esta rama; las nuevas sugeridas aún no tienen ID ni autorización de implementación.

| Prioridad | Idea concreta [P] | Tareas afectadas | Criterio de aceptación propuesto |
|---|---|---|---|
| P0 | Tutorial persistente de un solo paso: huevo → incubadora → eclosión → corral → cobro → montar | **Nueva: onboarding v4**, integra T30, T31, T32, T34 y T16 | Un jugador nuevo completa un ciclo sin ayuda externa; puede reanudar tras reconectar |
| P0 | Flecha al destino actual y marcador sobre objeto accionable | Nueva onboarding + T31, T30, T08 | Nunca apunta a un nido bloqueado ni a una incubadora llena; desaparece al completar |
| P0 | Confirmación inequívoca al recoger, depositar, eclosionar y cobrar | T31, T30, T34, T16 | El cliente anuncia éxito tras resultado del servidor; no confunde «llevar» con «guardado» |
| P0 | Guarida visible con nombre, oro/s y criaturas expuestas | T30 + T08 | Se reconoce la guarida propia desde la plaza y se distingue renta de saldo acumulado |
| P0 | Carteles de mejoras junto al objeto: coste, efecto actual → nuevo y requisito faltante | T35 + T30 | El jugador entiende qué compra y cuántos recursos faltan antes de confirmar |
| P0 | Montura con apoyos, peso, jinete anclado, salto y aterrizaje | T32 + T20 | Sin patinaje al parar, sin atravesar la silla y con lectura clara en móvil |
| P0 | Controles contextuales: mantener para robar, soltar/depositar, montar, empujar | T31, T32, T33, T16 | Cada acción tiene equivalente táctil; no depende de explicar una tecla PC |
| P0 | Separar rareza, mutación y tamaño; indicar renta individual antes de equipar | T34 + T30 | Una etiqueta grande no oculta ni sustituye la información de rareza y rendimiento |
| P1 | Primera mejora asequible después de experimentar una recompensa | T35 + nueva onboarding | Balancear con pruebas gratuitas; **no copiar automáticamente $300** |
| P1 | Inventario con activos/almacenados y «Equipar mejores» por oro/s | T30; posible ficha nueva de interfaz de establo | No consume ni vende criaturas; protege selección de montura favorita |
| P1 | Aviso de evento, cuenta atrás y ruta visible hacia la Reina | T36 + T16 | Se sabe cuándo, dónde y qué se puede ganar; aviso no tapa la persecución |
| P1 | Sonido y revelado escalados por rareza, anuncio social limitado | T34 + T16 | Evitar spam; la adquisición sigue confirmada aunque se cierre la animación |
| P1 | Tienda inicial corta: ×2 oro, comodidad explícita, pack de entrada y cosméticos | T06 | Efectos, duración, límites y precio claramente separados; no importar 125 productos |
| P1 | Dragonario que reconozca cada primera colección | T38 | Premio entendible y progreso persistente; no exigir duplicados pagos para completar tutorial |
| P1 | Revisar ventaja de velocidad, capacidad y escudo en PvP | T06 + T33 + T35 | Poder completar el primer ciclo sin compras y sin ser bloqueado por compradores |
| P2 | Polvo por superficie, cámara opcional de velocidad y estelas originales | T32 + T16 + T06 | Rendimiento con 8 jugadores y opción de reducir efectos |
| P2 | Evento estacional con recuerdo cosmético permanente | T26 + T06 | Se explica qué termina y qué se conserva; no añadir moneda si retrasa núcleo |
| P2 | Renta offline con límite explicado | Nueva: balance offline de guarida + T30 | Mostrar duración computada y oro resultante; distinta de incubación offline ya prevista |
| P2 | Fusión de duplicados | **Nueva, posterior al lanzamiento**; T30, T34, T38 | Solo tras probar necesidad; confirmación de consumo y probabilidades antes de una compra aleatoria |

**Lo que no trasladaría al lanzamiento [P]:** otra estadística de entrenamiento infinito, múltiples monedas estacionales, escalera de miles de Robux, cobro por evitar una pérdida durante el tutorial o una dependencia entre secreto y noche no comprobada. La v4 ya tiene suficientes decisiones con nidos, madres, incubación y monturas.

### Revisión pendiente por el humano

Para cerrar los puntos no verificables en las fuentes, en una partida gratuita futura registrar: primer minuto y orden exacto de metas; flechas y barra; función de Q; controles táctiles; coste y capacidad del corral nivel 2; veinte segundos de carrera lateral para analizar patas y silla; giro y frenada; dos cambios día/noche; tarjeta de un huevo con probabilidades y descripción de cada bonus. **No es necesario comprar para revisar el diseño.**

Estas son propuestas de investigación, no decisiones incorporadas a [[Decisiones]]. No se alteró el estado de ninguna tarea de implementación.

## Anexo A. Fuentes y trazabilidad

Todas consultadas el 2026-11-03; fechas de publicación de vídeos/guías corresponden a versiones anteriores.

| Fuente | Uso y límite |
|---|---|
| [Games API](https://games.roblox.com/v1/games?universeIds=10758824872,10767814136,10769315427) | Identidad, descripción, jugadores, visitas y tamaño de servidor |
| [Votes API](https://games.roblox.com/v1/games/votes?universeIds=10758824872,10767814136,10769315427) | Recuentos, no retención |
| [Pases Dino](https://apis.roblox.com/game-passes/v1/universes/10758824872/game-passes?passView=Full&pageSize=100) | Dos entradas, una a la venta |
| [Productos Dino](https://apis.roblox.com/developer-products/v2/universes/10758824872/developerproducts?limit=100) | Dos páginas mediante cursor; 125 IDs |
| [Pases Dragon](https://apis.roblox.com/game-passes/v1/universes/10767814136/game-passes?passView=Full&pageSize=100) · [Productos Dragon](https://apis.roblox.com/developer-products/v2/universes/10767814136/developerproducts?limit=100) | Tres pases y tres páginas de productos |
| [Pases Pet](https://apis.roblox.com/game-passes/v1/universes/10769315427/game-passes?passView=Full&pageSize=100) · [Productos Pet](https://apis.roblox.com/developer-products/v2/universes/10769315427/developerproducts?limit=100) | Catorce pases y tres páginas de productos |
| [CHALLS, 21 oct](https://www.youtube.com/watch?v=KC5iiD8iHYc) | Fragmentos iniciales revisados: tutorial, lazo, HUD, primer éxito; saltos posteriores fallaron |
| [Radex Tips, 20 oct](https://www.youtube.com/watch?v=JF_l5dWEois) | Fragmento de carrera revisado: etiquetas, capturas, Space, polvo; consulta posterior limitada por carga |
| [Superlex Plays, 17 oct](https://www.youtube.com/watch?v=EMr-gDdLs_M) | Grabación localizada; referencia secundaria del panel de corral; tiene compras y no sirve de curva gratuita |
| [Guía de controles](https://9to5gaming.com/ride-dino-gameplay-tips/) | WASD, E, máquina $300 y entrenamiento; datos comunitarios |
| [Guía de inicio](https://rideadino.com/guides/beginners/) | Secuencia de objetivos y depósitos; no tiempos propios |
| [Guía de rancho](https://rideadino.com/guides/ranch/) | Active/Stored/Equip Best; datos comunitarios |
| [Mutaciones y tamaños](https://progameguides.com/roblox/ride-a-dino-mutations-sizes-multipliers-how-to-get/) | Multiplicadores reportados, con errores de redacción señalados |
| [Eventos](https://rideadino.com/updates/) | Fechas históricas y mecánicas anunciadas; actividad actual no probada |
| Notas de Claude en la petición | Flechas blancas, «!» rojo, corral $1M, Q y noche; distinguidas de verificación propia |

## Anexo B. Catálogo público completo de Ride a Dino y pases comparados

Las tablas siguientes son una instantánea de datos públicos, no recomendaciones de compra. Se conserva el nombre original para identificar cada oferta; esos nombres **no se proponen para nuestro juego**. Los IDs de pases son `id`; los de productos son `ProductId`, no `DeveloperProductId`.

### Pases: Ride a Dino

| ID del pase | Nombre | Robux | A la venta |
|---|---|---:|---|
| 2018396419 | Magma Colossal T-Rex | No disponible | No |
| 2006762742 | 2X Money | 199 | Sí |

### Pases: Ride a Dragon

| ID del pase | Nombre | Robux | A la venta |
|---|---|---:|---|
| 2009588258 | Infinite Radar | 99 | Sí |
| 2011244253 | 2x Money | 149 | Sí |
| 2010962267 | Auto Buy | 20 | Sí |

### Pases: Steal A Pet And Ride It!

| ID del pase | Nombre | Robux | A la venta |
|---|---|---:|---|
| 2038106843 | VIP | 199 | Sí |
| 2022542273 | 3x Open Speed | 299 | Sí |
| 2023022268 | Auto Collect | 49 | Sí |
| 2061162272 | Mastery Pass | 399 | Sí |
| 2053734037 | Halloween Trail | 249 | Sí |
| 2052198031 | Halloween Treadmill | 249 | Sí |
| 2039936622 | Sakura Barn | 149 | Sí |
| 2052120021 | Halloween Aura | 199 | Sí |
| 2054190005 | 2x Candy | 249 | Sí |
| 2036378867 | Open Pens Barn | 99 | Sí |
| 2062943781 | Extra Boss Drop | 199 | Sí |
| 2063105813 | Boss Luck Boost | 199 | Sí |
| 2040212412 | TREEHOUSE BARN | 149 | Sí |
| 2021522293 | OP Pet Pack | No disponible | No |

### Los 125 productos de Ride a Dino

Ordenados por ProductId. Todos devolvieron `IsForSale = true`. Las versiones Gift y las dos series de Grip se conservan como entradas diferentes.

| ProductId | Nombre de la oferta | Robux |
|---|---|---:|
| 3714142713 | Ride A Dino - x2 Grip | 3 |
| 3714142831 | Ride A Dino - x4 Grip | 9 |
| 3714142836 | Ride A Dino - x8 Grip | 24 |
| 3714142840 | Ride A Dino - x16 Grip | 39 |
| 3714142845 | Ride A Dino - x32 Grip | 79 |
| 3714142998 | Ride A Dino - x64 Grip | 129 |
| 3714143001 | Ride A Dino - x128 Grip | 199 |
| 3714143004 | Ride A Dino - x256 Grip | 299 |
| 3714143008 | Ride A Dino - x512 Grip | 499 |
| 3714143010 | Ride A Dino - x1024 Grip | 649 |
| 3714143014 | Ride A Dino - x2048 Grip | 949 |
| 3714143019 | Ride A Dino - x4096 Grip | 1375 |
| 3714143023 | Ride A Dino - 150,000 Grip | 59 |
| 3714143027 | Ride A Dino - 1,000,000 Grip | 189 |
| 3714143030 | Ride A Dino - 10,000,000 Grip | 525 |
| 3714143036 | Ride A Dino - 50,000,000 Grip | 899 |
| 3714143039 | Ride A Dino - 500,000,000 Grip | 1499 |
| 3714143042 | Ride A Dino - 1,000,000,000 Grip | 2249 |
| 3714143045 | Ride A Dino - Compy Machine | 19 |
| 3714143046 | Ride A Dino - Parasaurolophus Machine | 39 |
| 3714143050 | Ride A Dino - Raptor Machine | 69 |
| 3714143051 | Ride A Dino - Triceratops Machine | 119 |
| 3714143058 | Ride A Dino - Dilophosaurus Machine | 199 |
| 3714143060 | Ride A Dino - Carnotaurus Machine | 299 |
| 3714143067 | Ride A Dino - Allosaurus Machine | 499 |
| 3714143074 | Ride A Dino - T-Rex Machine | 799 |
| 3714143078 | Ride A Dino - Apex Rex Machine | 1299 |
| 3715442825 | Ride A Dino - Revive | 29 |
| 3715442831 | Ride A Dino - Revive II | 59 |
| 3715442837 | Ride A Dino - Revive III | 99 |
| 3715442845 | Ride A Dino - Silver Aura (Lvl 1) | 9 |
| 3715442852 | Ride A Dino - Lime Aura (Lvl 2) | 19 |
| 3715442862 | Ride A Dino - Cyan Aura (Lvl 3) | 29 |
| 3715442865 | Ride A Dino - Cobalt Aura (Lvl 4) | 49 |
| 3715442869 | Ride A Dino - Violet Aura (Lvl 5) | 79 |
| 3715442875 | Ride A Dino - Pink Aura (Lvl 6) | 99 |
| 3715442885 | Ride A Dino - Golden Aura (Lvl 7) | 149 |
| 3715442892 | Ride A Dino - Blaze Aura (Lvl 8) | 199 |
| 3715442900 | Ride A Dino - Crimson Aura (Lvl 9) | 299 |
| 3715442905 | Ride A Dino - Emerald Aura (Lvl 10) | 399 |
| 3715442910 | Ride A Dino - Divine Aura (Lvl 11) | 499 |
| 3715442918 | Ride A Dino - Rainbow Aura (Lvl 12) | 524 |
| 3715442930 | Ride A Dino - Dune Hopper Pteranodon | 99 |
| 3715442940 | Ride A Dino - Frostwing Pteranodon | 199 |
| 3715442951 | Ride A Dino - Canopy Cruiser Pteranodon | 399 |
| 3715442956 | Ride A Dino - Abyss Glider Pteranodon | 699 |
| 3715442964 | Ride A Dino - Emberwing Pteranodon | 999 |
| 3715442972 | Ride A Dino - Apex Soarer Pteranodon | 1499 |
| 3715620300 | Ride A Dino - $24,000 | 45 |
| 3715620306 | Ride A Dino - $200,000 | 90 |
| 3715620307 | Ride A Dino - $800,000 | 225 |
| 3715620316 | Ride A Dino - $4,000,000 | 450 |
| 3715620319 | Ride A Dino - $8,000,000 | 720 |
| 3717106727 | Ride A Dino - x3 Offline Rewards | 29 |
| 3717257417 | Ride A Dino - x2 Luck (15 Min) | 99 |
| 3717257426 | Ride A Dino - x4 Luck (15 Min) | 349 |
| 3717257434 | Ride A Dino - Starter Pack | 99 |
| 3717667662 | Ride A Dino - Magma Colossal T-Rex | 499 |
| 3718212375 | Ride A Dino - 1 Halloween Egg | 99 |
| 3718212379 | Ride A Dino - 3 Halloween Eggs | 249 |
| 3718212387 | Ride A Dino - 10 Halloween Eggs | 799 |
| 3718212396 | Ride A Dino - 50 Halloween Eggs | 3499 |
| 3718212413 | Ride A Dino - Gift 1 Halloween Egg | 99 |
| 3718212422 | Ride A Dino - Gift 3 Halloween Eggs | 249 |
| 3718212427 | Ride A Dino - Gift 10 Halloween Eggs | 799 |
| 3718212432 | Ride A Dino - Gift 50 Halloween Eggs | 3499 |
| 3718212443 | Ride A Dino - Magma Skeletal Rex | 2499 |
| 3718762117 | Ride A Dino - 100% Fuse - Big | 19 |
| 3718762122 | Ride A Dino - 100% Fuse - Giant | 39 |
| 3718762137 | Ride A Dino - 100% Fuse - Huge | 79 |
| 3718762143 | Ride A Dino - 100% Fuse - Colossal | 149 |
| 3718770260 | Ride A Dino - x2 Fuse Luck | 49 |
| 3719215171 | Ride A Dino: x2 Grip | 6 |
| 3719215178 | Ride A Dino: x4 Grip | 18 |
| 3719215184 | Ride A Dino: x8 Grip | 48 |
| 3719215191 | Ride A Dino: x16 Grip | 78 |
| 3719215197 | Ride A Dino: x32 Grip | 158 |
| 3719215206 | Ride A Dino: x64 Grip | 258 |
| 3719215213 | Ride A Dino: x128 Grip | 398 |
| 3719215218 | Ride A Dino: x256 Grip | 598 |
| 3719215228 | Ride A Dino: x512 Grip | 998 |
| 3719215233 | Ride A Dino: x1024 Grip | 1298 |
| 3719215247 | Ride A Dino: x2048 Grip | 1898 |
| 3719215258 | Ride A Dino: x4096 Grip | 2750 |
| 3719486666 | Ride A Dino - Magma Big King Yeti | 999 |
| 3722217039 | Ride A Dino - 100 Spectral Flames | 19 |
| 3722217054 | Ride A Dino - 350 Spectral Flames | 59 |
| 3722217060 | Ride A Dino - 800 Spectral Flames | 129 |
| 3722217066 | Ride A Dino - 2,000 Spectral Flames | 299 |
| 3722217075 | Ride A Dino - Horde Skin: Pumpkin Patch | 49 |
| 3722217085 | Ride A Dino - Horde Skin: Candy Corn | 79 |
| 3722217093 | Ride A Dino - Horde Skin: Bat Swarm | 129 |
| 3722217104 | Ride A Dino - Horde Skin: Skull Horde | 199 |
| 3722217114 | Ride A Dino - Aura Skin: Pumpkin Ascension | 79 |
| 3722217129 | Ride A Dino - Aura Skin: Midnight Wings | 149 |
| 3722217145 | Ride A Dino - Aura Skin: Wandering Spirits | 229 |
| 3722217154 | Ride A Dino - Gift 100 Spectral Flames | 19 |
| 3722217163 | Ride A Dino - Gift 350 Spectral Flames | 59 |
| 3722217174 | Ride A Dino - Gift 800 Spectral Flames | 129 |
| 3722217181 | Ride A Dino - Gift 2,000 Spectral Flames | 299 |
| 3722217191 | Ride A Dino - Gift Horde Skin: Pumpkin Patch | 49 |
| 3722217199 | Ride A Dino - Gift Horde Skin: Candy Corn | 79 |
| 3722217214 | Ride A Dino - Gift Horde Skin: Bat Swarm | 129 |
| 3722217225 | Ride A Dino - Gift Horde Skin: Skull Horde | 199 |
| 3722217237 | Ride A Dino - Gift Aura Skin: Pumpkin Ascension | 79 |
| 3722217245 | Ride A Dino - Gift Aura Skin: Midnight Wings | 149 |
| 3722217264 | Ride A Dino - Gift Aura Skin: Wandering Spirits | 229 |
| 3722899921 | Ride A Dino - Gift $24,000 | 45 |
| 3722899935 | Ride A Dino - Gift $200,000 | 90 |
| 3722899946 | Ride A Dino - Gift $800,000 | 225 |
| 3722899954 | Ride A Dino - Gift $4,000,000 | 450 |
| 3722899961 | Ride A Dino - Gift $8,000,000 | 720 |
| 3722899978 | Ride A Dino - Gift 150,000 Grip | 59 |
| 3722899991 | Ride A Dino - Gift 1,000,000 Grip | 189 |
| 3722900004 | Ride A Dino - Gift 10,000,000 Grip | 525 |
| 3722900012 | Ride A Dino - Gift 50,000,000 Grip | 899 |
| 3722900023 | Ride A Dino - Gift 500,000,000 Grip | 1499 |
| 3722900037 | Ride A Dino - Gift 1,000,000,000 Grip | 2249 |
| 3722900053 | Ride A Dino - Gift x2 Luck (15 Min) | 99 |
| 3722900069 | Ride A Dino - Gift x4 Luck (15 Min) | 349 |
| 3722900078 | Ride A Dino - Gift Starter Pack | 99 |
| 3726656734 | Ride A Dino - 7,500 Fossil Coins | 49 |
| 3726656741 | Ride A Dino - 25,000 Fossil Coins | 129 |
| 3726656746 | Ride A Dino - 75,000 Fossil Coins | 299 |
| 3726656755 | Ride A Dino - 355,000 Fossil Coins | 799 |
