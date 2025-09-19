extends Control

enum States {
	OPTIONS,
	TARGETS,
}

enum Actions {
	FIGHT,
}

enum {
	ACTOR,
	TARGET,
	ACTION,
}
var state: States = States.OPTIONS
var atb_queue: Array = []
var event_queue: Array = []
var action: Actions = Actions.FIGHT
var player: BattleActor = null
@onready var _options: WindowDefault = $Options
@onready var _options_menu: Menu = $Options/Options
@onready var _enemies_menu: Menu = $Enemies
@onready var _players_menu: Menu = $Players
@onready var _players_infos: Array = $GUIMargin/Bottom/Players/MarginContainer/VBoxContainer.get_children()
@onready var _cursor: MenuCursor = $MenuCursor
func _ready() -> void:
	_options_menu.connect_to_buttons(self)
	_enemies_menu.connect_to_buttons(self)
	_options.hide()
	for player in _players_infos:
		player.atb_ready.connect(_on_player_atb_ready.bind(player))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match state:
			States.OPTIONS:
				pass
			States.TARGETS:
				state = States.OPTIONS
				
				_options_menu.button_focus()

func advance_atb_queue() -> void:
	state = States.OPTIONS
	if atb_queue.is_empty():
		return
	var current_player_info_bar: PlayerInfoBar = atb_queue.pop_front()
	current_player_info_bar.reset()
	
	if atb_queue.is_empty():
		get_viewport().gui_release_focus()
		_options.hide()
		_cursor.hide()
	else:
		var next_player_info_bar: PlayerInfoBar = atb_queue.front()
		next_player_info_bar.highlight()
		player = Data.party[next_player_info_bar.get_index()]
		_options_menu.button_focus(0)

func run_event() -> void:
	if event_queue.is_empty():
		return
	var event: Array = event_queue.pop_front()
	var actor: BattleActor = event[ACTOR]
	var target: BattleActor = event[TARGET]
	match event[ACTION]:
		Actions.FIGHT:
			target.healhurt(-actor.strength)
		_:
			pass
func add_event(event: Array) -> void:
	event_queue.append(event)
	if event_queue.size() == 1:
		run_event()
func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Fight":
			action = Actions.FIGHT
			state = States.TARGETS
			# Disable player buttons by finding them directly
			var players_container = $GUIMargin/Bottom/Players
			for child in players_container.find_children("", "BaseButton", true):
				child.disabled = true
			_enemies_menu.button_focus()
func _on_player_atb_ready(_player: PlayerInfoBar) -> void:
	if atb_queue.is_empty():
		_player.highlight()
		_options.show()
		_options_menu.button_focus(0)
	
	atb_queue.append(_player)

func _on_enemies_button_pressed(button: EnemyButton) -> void:
	var target: BattleActor = button.data
	event_queue.append([player, target, action])
	add_event([player, target, action])
	advance_atb_queue()
	
func _on_players_button_pressed(button: PlayerButton) -> void:
	var target: BattleActor = button.data
	add_event([player, target, action])
	event_queue.append([player, target, action])
	advance_atb_queue()
