extends Node

var enemies: Dictionary = {
	"Goofball": BattleActor.new()
}


var players: Dictionary = {
	"Karmen": BattleActor.new(),
	"Nepsen": BattleActor.new(),
	"Linpsy": BattleActor.new(),
	"Nilrem": BattleActor.new()
}
var party: Array = players.values()

func _init() -> void:
	Util.set_keys_to_names(enemies)
	Util.set_keys_to_names(players)
