extends Node

var current_games = {}
var rng = RandomNumberGenerator.new()


func create_new_game(lobby_id, lobby_players):
	current_games[lobby_id] = lobby_players
	return lobby_id


func get_current_game_players(game_id):
	#return transform_players_in_game(current_games[game_id])
	return current_games[game_id]


func transform_players_in_game(lobby):
	var players_to_send = []
	for player in lobby:
		players_to_send.append(player.id)
	return players_to_send


func get_random_bubble_location():
	rng.randomize()
	return Vector2(rng.randi_range(210, 1710), 290)


func get_random_player_location(game_id):
	rng.randomize()
	var player_positions = {}
	var game_players = current_games[game_id]
	for i in range(game_players.size()):
		var even = bool(i % 2)
		player_positions[game_players[i]] = Vector2(860 if even else 1060, 829)
	return player_positions


func delete_game(game_id):
	if current_games.has(game_id):
		current_games.erase(game_id)
