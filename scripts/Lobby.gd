extends Node

const MAX_PLAYERS_PER_LOBBY = 2

var lobbies_dict = {}
var players_dict = {}

var delta_count = 0

func _ready():
	pass


func _process(delta):
	delta_count += delta
	if delta_count > 1:
		print("players_dict: " + str(players_dict))
		print("lobbies_dict: " + str(lobbies_dict))
		delta_count = 0


func get_player_lobby(player_id):
	var current_player = players_dict[player_id]
	var lobby_id = current_player.get_lobby_id()
	if lobby_id != 0:
		return [lobby_id, get_lobby_players_username(lobbies_dict[lobby_id])]
	else:
		return [0, []]


func get_raw_player_lobby(player_id):
	var current_player = players_dict[player_id]
	var lobby_id = current_player.get_lobby_id()
	if lobby_id != 0:
		return [lobby_id, get_lobby_players_id(lobby_id)]
	else:
		return [0, []]


func get_other_lobbies(player_id):
	var current_player = players_dict[player_id]
	var lobby_id = current_player.get_lobby_id()
	if lobby_id != 0:
		return transform_lobbies_to_send(lobby_id)
	else:
		return lobbies_dict.keys()


func delete_player_from_current_lobby(player_id) -> int:
	var deleted_player = players_dict[player_id]
	var current_lobby_id = deleted_player.get_lobby_id()
	if current_lobby_id != 0:
		var lobby = lobbies_dict[current_lobby_id]
		lobby.erase(deleted_player)
		deleted_player.set_lobby_id(0)
		var deleted = attempt_to_delete_lobby(lobby, current_lobby_id)
		if deleted:
			return 0
	return current_lobby_id


func create_player(player_id):
	var newPlayer = load("res://scenes/Player.tscn").instance()
	newPlayer.set_name(str(player_id))     
	newPlayer.set_id(player_id)
	players_dict[player_id] = newPlayer


func delete_player(player_id):
	delete_player_from_current_lobby(player_id)
	players_dict.erase(player_id)


func create_lobby(player_id):
	if !lobbies_dict.has(player_id):
		lobbies_dict[player_id] = []
		add_player_to_lobby(player_id, player_id)


func attempt_to_delete_lobby(lobby, lobby_id) -> bool:
	if lobby.size() == 0:
		lobbies_dict.erase(lobby_id)
		return true
	return false


func add_player_to_lobby(player_id, lobby_id):
	var player = players_dict[player_id]
	player.set_lobby_id(lobby_id) 
	lobbies_dict[lobby_id].append(player)


func is_lobby_full(lobby_id) -> bool:
	return lobbies_dict[lobby_id].size() == MAX_PLAYERS_PER_LOBBY


func get_lobby_players_id(lobby_id):
	var lobby = lobbies_dict[lobby_id]
	var players_to_send = []
	for player in lobby:
		players_to_send.append(player.get_id())
	return players_to_send


func get_lobby_players_username(lobby):
	var players_to_send = []
	for player in lobby:
		players_to_send.append(player.get_username())
	return players_to_send


func transform_lobbies_to_send(player_lobby_id):
	var lobbies_to_send = []
	for lobby_id in lobbies_dict.keys():
		if lobby_id != player_lobby_id:
			lobbies_to_send.append(lobby_id)
	return lobbies_to_send

func player_logedin(player_id, username):
	var current_player = players_dict.get(player_id)
	if current_player != null:
		current_player.set_username(username)
