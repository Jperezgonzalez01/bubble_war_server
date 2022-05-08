extends Node2D


var id : int = 0
var lobby_id : int = 0
var game_id : int = 0

func _ready():
	pass


func get_id() -> int:
	return id

func set_id(new_id:int) -> void:
	id = new_id

func get_lobby_id() -> int:
	return lobby_id

func set_lobby_id(new_lobby_id:int) -> void:
	lobby_id = new_lobby_id
