## Herramientas de dibujo con el estilo del juego (cuadros GBA, texto pixelado, casillas).
## Todas las pantallas dibujan a través de esta clase, así el estilo vive en un solo lugar.
class_name UIKit
extends RefCounted

const VIEW_W := 240
const VIEW_H := 160
const TILE := 16

const TEXT := Color("404040")
const SHADOW := Color("d0d0c8")
const INK := Color("283040")
const WHITE := Color("f8f8f8")
const PAPER := Color("f0f0e8")
const BORDER := Color("4868a0")
const BORDER_LIGHT := Color("88a8d8")
const GOLD := Color("f8d030")
const ALERT := Color("c03030")
const ACCENT := Color("a04020")
const MUTED := Color("6878a0")
const NONE := Color(0, 0, 0, 0)

## Posición de cada casilla dentro de art/atlas.png
const ATLAS := {
	"grass": 0, "grass2": 1, "tall_grass": 2, "path": 3, "tree": 4, "flower_red": 5,
	"flower_yellow": 6, "sign": 7, "floor": 8, "wall": 9, "wall_top": 10,
	"red_up": 11, "red_down": 12, "blue_up": 13, "blue_down": 14, "key": 15,
	"stairs": 16, "door": 17, "door_open": 18, "num": 19, "num_lit": 20,
	"covered": 21, "revealed": 22, "mine": 23, "flag": 24, "void": 25,
	"portal": 26, "entrance": 27, "foot": 28, "flame": 29, "flower_pink": 30,
	"door_padlock": 31, "door_unlocked": 32, "wall_cracked": 33,
}

var time := 0.0
var title_bg: Texture2D
var _canvas: CanvasItem
var _atlas: Texture2D
var _chars: Texture2D
var _houses: Texture2D
var _font: FontFile
var _box_outer: StyleBoxFlat
var _box_inner: StyleBoxFlat
var _pill: StyleBoxFlat
var _dark_pill: StyleBoxFlat


func _init(canvas: CanvasItem) -> void:
	_canvas = canvas
	_atlas = load("res://art/atlas.png")
	_chars = load("res://art/chars.png")
	_houses = load("res://art/houses.png")
	title_bg = load("res://art/title_bg.png")
	_font = load("res://fonts/PressStart2P.ttf")
	_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	_font.hinting = TextServer.HINTING_NONE
	_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	_box_outer = _style(BORDER_LIGHT, 4, BORDER, 1)
	_box_inner = _style(WHITE, 2)
	_pill = _style(PAPER, 3, INK, 1)
	_dark_pill = _style(INK, 3)


static func _style(fill: Color, radius: int, border := NONE, border_w := 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.anti_aliasing = false
	return s


func tile(name: String, at: Vector2, modulate := Color.WHITE) -> void:
	var i: int = ATLAS[name]
	_canvas.draw_texture_rect_region(_atlas, Rect2(at, Vector2(TILE, TILE)), Rect2((i % 16) * TILE, (i / 16) * TILE, TILE, TILE), modulate)


func character(frame: int, at: Vector2) -> void:
	_canvas.draw_texture_rect_region(_chars, Rect2(at + Vector2(0, -3), Vector2(TILE, TILE)), Rect2(frame * TILE, 0, TILE, TILE))


func house(sprite: int, at: Vector2) -> void:
	_canvas.draw_texture_rect_region(_houses, Rect2(at, Vector2(48, 48)), Rect2(sprite * 48, 0, 48, 48))


func image(texture: Texture2D, at: Vector2) -> void:
	_canvas.draw_texture(texture, at)


func rect(r: Rect2, color: Color) -> void:
	_canvas.draw_rect(r, color)


## Contorno de 1 píxel (por ejemplo, el cursor sobre una baldosa).
func frame(r: Rect2, color: Color) -> void:
	_canvas.draw_rect(r.grow(-0.5), color, false, 1.0)


func line(a: Vector2, b: Vector2, color: Color) -> void:
	_canvas.draw_line(a, b, color)


## Texto simple, sin sombra. "at" es la esquina superior izquierda.
func label(s: String, at: Vector2, color := TEXT, size := 8) -> void:
	_canvas.draw_string(_font, at + Vector2(0, size), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## Texto con la sombra gris clara de los cuadros de diálogo de GBA.
func text(s: String, at: Vector2, color := TEXT, shadow := SHADOW) -> void:
	if shadow.a > 0.0:
		label(s, at + Vector2(1, 1), shadow)
	label(s, at, color)


func text_centered(s: String, y: float, color := TEXT, shadow := SHADOW) -> void:
	text(s, Vector2(floor((VIEW_W - s.length() * 8) / 2.0), y), color, shadow)


## Texto con el valor alineado a la derecha: "TIEMPO     3:12"
func key_value(x: float, y: float, key: String, value: String, width := 104.0) -> void:
	text(key, Vector2(x, y))
	text(value, Vector2(x + width - value.length() * 8, y), BORDER)


func box(r: Rect2, fill := WHITE) -> void:
	_canvas.draw_style_box(_box_outer, r)
	if fill == WHITE:
		_canvas.draw_style_box(_box_inner, r.grow(-3))
	else:
		_canvas.draw_style_box(_style(fill, 2), r.grow(-3))


func pill(r: Rect2, dark := false) -> void:
	_canvas.draw_style_box(_dark_pill if dark else _pill, r)


func cursor(at: Vector2, color := TEXT) -> void:
	_canvas.draw_colored_polygon(PackedVector2Array([at, at + Vector2(0, 7), at + Vector2(4, 3.5)]), color)


func more_arrow(at: Vector2) -> void:
	_canvas.draw_colored_polygon(PackedVector2Array([at, at + Vector2(8, 0), at + Vector2(4, 4)]), Color("e05040"))


func blink(rate := 2.0) -> bool:
	return int(time * rate) % 2 == 0


func dim(amount := 0.6) -> void:
	rect(Rect2(0, 0, VIEW_W, VIEW_H), Color(0.06, 0.09, 0.16, amount))


static func wrap_text(t: String, width: int) -> Array:
	var out: Array = []
	var line_text := ""
	for word in t.split(" "):
		if line_text == "":
			line_text = word
		elif line_text.length() + 1 + word.length() <= width:
			line_text += " " + word
		else:
			out.append(line_text)
			line_text = word
	if line_text != "":
		out.append(line_text)
	return out
