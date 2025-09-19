class_name EnemyButton extends TextureButton

const HIT_TEXT: PackedScene = preload("res://scenes/hit_text.tscn")
var data: BattleActor = Data.enemies.Goofball.duplicate()
@onready var _atb_bar: ATBBar = $ATBBar
	
func _ready() -> void:
	data.hp_changed.connect(_on_data_hp_changed)

func _on_data_hp_changed(hp: int, change: int) -> void:
	var hit_text: Label = HIT_TEXT.instantiate()
	print("hello")
	hit_text.text = str(abs(change))
	add_child(hit_text)
	hit_text.position = Vector2(0, -24) # for Control nodes
