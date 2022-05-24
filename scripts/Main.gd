extends Node

var delta_acc = 0

func _ready():
	Network.init()
	Database.init_db()
