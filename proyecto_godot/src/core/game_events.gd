## Catálogo de eventos que viajan por el EventBus (patrón Observer).
## Usar constantes evita errores de tipeo y deja todos los eventos documentados en un solo lugar.
class_name GameEvents
extends RefCounted

const STEP := &"step"
const BUMP := &"bump"
const STONES_TOGGLED := &"stones_toggled"
const KEY_PICKED := &"key_picked"
const SUM_CHANGED := &"sum_changed"
const TRAP_TRIGGERED := &"trap_triggered"
const FLAG_TOGGLED := &"flag_toggled"
const FIELD_CLEARED := &"field_cleared"
const PLAYER_FELL := &"player_fell"
const ROOM_ENTERED := &"room_entered"
const ROOM_CLEARED := &"room_cleared"
const TEMPLE_ENTERED := &"temple_entered"
const TIME_WARNING := &"time_warning"
const TIME_UP := &"time_up"
const GAME_WON := &"game_won"
const GAME_LOST := &"game_lost"
const MENU_MOVE := &"menu_move"
const MENU_CONFIRM := &"menu_confirm"
const DIALOG_CHAR := &"dialog_char"
const GUIDE_TOGGLED := &"guide_toggled"
