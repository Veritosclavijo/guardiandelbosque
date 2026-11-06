# Guardián del Bosque

Serious game top-down (estilo *The Legend of Zelda*, 1986) sobre prevención y control de incendios forestales.
Hecho en **Godot 4.7** con la misma organización que el proyecto Zelda: escenas `.tscn` con sus nodos,
sprites en `Assets/` y el mapa pintado en un `TileMapLayer`.

Incluye introducción en viñetas, 3 zonas, música y efectos de sonido.

## Cómo abrirlo

1. Abre Godot 4.7 → **Importar** → selecciona `project.godot` de esta carpeta.
2. Presiona **F5** para jugar (empieza en `Scenes/World/titulo.tscn`).

## Controles

| Acción | Teclas |
| --- | --- |
| Mover | WASD o flechas |
| Usar ítem | Espacio o J |
| Cambiar ítem | Q o Tab |
| Hablar con un NPC | E |
| Aceptar / continuar | Enter |

## Escenas

| Escena | Nodos principales |
| --- | --- |
| `Scenes/World/titulo.tscn` | Control, TileMapLayer (borde), Labels, TextureRects |
| `Scenes/World/zona_1_camping.tscn` | Mundo → Suelo y Fuego (TileMapLayer), Riesgos, NPCs, Enemigos, Player · TimerFuego · HUD · Dialogo |
| `Scenes/World/zona_2_montana.tscn` | Igual que la zona 1, con viento y fuego inicial pintado en la capa Fuego |
| `Scenes/World/zona_3_incendio.tscn` | Gran incendio: el viento cambia cada 25 s (`cambio_viento_segundos`), campistas que hay que evacuar (`evacuar` en el NPC) hasta el Marker2D `PuntoEncuentro` |
| `Scenes/World/intro.tscn` | Introducción en viñetas (imágenes y textos en el Inspector) |
| `Scenes/Audio/sonido.tscn` | Autoload Sonido → Musica, Efectos (Canal1…Canal6) |
| `Scenes/Objetos/salpicadura.tscn` | AnimatedSprite2D del agua cayendo y salpicando al usar la cubeta |
| `Scenes/World/resultados.tscn` | Panel con estrellas, estadísticas y "Aprendiste" |
| `Scenes/Player/player.tscn` | CharacterBody2D → CollisionShape2D, AnimatedSprite2D |
| `Scenes/Enemies/chispa.tscn` | CharacterBody2D → AnimatedSprite2D, CollisionShape2D, 4 RayCast2D (misma IA del Octorok) |
| `Scenes/NPC/npc.tscn` | StaticBody2D → Sprite2D, CollisionShape2D, Label "!" |
| `Scenes/Objetos/fogata.tscn`, `basura.tscn` | Area2D → AnimatedSprite2D, CollisionShape2D |
| `Scenes/UI/hud.tscn`, `dialogo.tscn` | CanvasLayer con la interfaz |

## Sonido, música y animaciones

- Todo el audio se sintetizó por código y está en `Assets/Audio/`; se reproduce con el autoload `Sonido`.
- Efectos: pasos, agua, pala, recoger basura, sembrar, chispa apagada, daño, diálogo, acierto/error, victoria
  y el crepitar del fuego (nodo `SonidoFuego` de cada zona: suena más fuerte mientras más casillas arden).
- Al usar un ítem, el guardabosques lo muestra en la mano (nodo `ItemMano` del Player). La cubeta se inclina
  y aparece el agua cayendo y salpicando (`salpicadura.tscn`) en la casilla de enfrente y en las vecinas que se apagan.

## Cómo editarlo

- **Mapa:** abre una zona, selecciona `Mundo/Suelo` y pinta con el TileSet (`Assets/tileset.tres`).
  Cada tile tiene datos personalizados: `tipo` y `inflamable` (probabilidad de quemarse).
- **Fuego inicial:** pinta el tile de fuego en la capa `Mundo/Fuego`.
- **Diálogos de los NPC:** selecciona el NPC y edita pregunta, opciones y respuestas en el Inspector.
- **Riesgos:** duplica una fogata o basura y cambia `tipo` en el Inspector.
- **Viento, objetivo y textos de la zona:** selecciona el nodo raíz de la zona y edítalos en el Inspector.
- **Velocidad del fuego:** `EDAD_MAXIMA_FUEGO` y `FACTOR_PROPAGACION` en `Scripts/World/zona.gd`,
  y el tiempo del nodo `TimerFuego`.

## Evaluación del aprendizaje

Flujo completo: título → **evaluación inicial** → introducción → juego → **evaluación final** → comparación antes/después → **encuesta de valoración**.

- Las 6 preguntas y sus opciones están en `Scripts/evaluacion.gd` (las opciones se mezclan al mostrarlas).
- Al terminar la última zona y la encuesta, el participante queda guardado como una fila (P01, P02…) en
  `%APPDATA%\Godot\app_userdata\Guardian del Bosque\resultados.csv`. Se abre en Excel.
- **R (o F2) en la pantalla de título** abre el panel del docente: participantes, promedios antes y después, ganancia, aciertos por pregunta y valoración.

## Shaders, tipografía y menú de pausa

- `Assets/Shaders/`: efectos hechos con shaders de Godot (ver la documentación en Word).
- `Assets/Fonts/`: fuente propia *Silvestre Pixel* (Regular y Bold). El tema `tema.tres` la aplica a todo el juego; los tamaños son múltiplos de 8 para que se vea nítida.
- **ESC** abre el menú de pausa: continuar, reiniciar, activar o quitar sonido y efectos visuales, y ver los controles.
