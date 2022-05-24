extends Node


const PORT = 5008
const MAX_PLAYERS = 200


func init():
	var server = NetworkedMultiplayerENet.new()
	server.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(server)
	
	get_tree().connect("network_peer_connected",    self, "s_client_connected")
	get_tree().connect("network_peer_disconnected", self, "s_client_disconnected")


## Default signals ##


func s_client_connected(id):
	print('Client ' + str(id) + ' connected to Server')
	
	Lobby.create_player(id)


func s_client_disconnected(id):
	print('Client ' + str(id) + ' disconnected from Server')
	
	Lobby.delete_player(id)


## Remote Functions ##

remote func s_create_lobby():
	var current_player_id = get_tree().get_rpc_sender_id()
	Lobby.create_lobby(current_player_id)


remote func s_add_player_to_lobby(new_lobby_id):
	var current_player_id = get_tree().get_rpc_sender_id()
	Lobby.delete_player_from_current_lobby(current_player_id)
	Lobby.add_player_to_lobby(current_player_id, new_lobby_id)
	if Lobby.is_lobby_full(new_lobby_id):
		var players_to_notify = Lobby.get_lobby_players_id(new_lobby_id)
		for player_id in players_to_notify:
			rpc_id(player_id, "c_online_game_ready")


remote func s_get_my_lobby(requester):
	var current_player_id = get_tree().get_rpc_sender_id()
	var lobby_response = Lobby.get_player_lobby(current_player_id)
	rpc_id(current_player_id, "c_get_my_lobby", lobby_response, requester)


remote func s_refresh_lobbies(requester):
	var current_player_id = get_tree().get_rpc_sender_id()
	var lobbies_response = Lobby.get_other_lobbies(current_player_id)
	rpc_id(current_player_id, "c_refresh_lobbies", lobbies_response, requester)


remote func s_leave_current_lobby():
	var current_player_id = get_tree().get_rpc_sender_id()
	var old_lobby_id = Lobby.delete_player_from_current_lobby(current_player_id)
	if old_lobby_id != 0:
		var players_to_notify = Lobby.get_lobby_players_id(old_lobby_id)
		for player_id in players_to_notify:
			rpc_id(player_id, "c_online_game_not_ready")


remote func s_create_new_coop_stage():
	var current_player_id = get_tree().get_rpc_sender_id()
	var lobby_array = Lobby.get_raw_player_lobby(current_player_id)
	var game_id = CoOpStage.create_new_game(lobby_array[0], lobby_array[1])
	var initial_bubble_position = CoOpStage.get_random_bubble_location()
	var initial_player_positions = CoOpStage.get_random_player_location(game_id)
	for player_id in lobby_array[1]:
		var other_players = lobby_array[1].duplicate()
		other_players.erase(player_id)
		rpc_id(player_id, "c_start_coop_stage", game_id, player_id, initial_bubble_position, other_players, initial_player_positions)
	
	
remote func s_update_player_position_and_state(game_id, player_position, player_state):
	var current_player_id = get_tree().get_rpc_sender_id()
	var game_players = CoOpStage.get_current_game_players(game_id)
	for other_player_id in game_players:
		if other_player_id != current_player_id:
			rpc_id(other_player_id, "c_update_player_position_and_state", current_player_id, player_position, player_state)

remote func s_player_emit_shoot(game_id, bullet_index, bullet_position):
	var current_player_id = get_tree().get_rpc_sender_id()
	var game_players = CoOpStage.get_current_game_players(game_id)
	for other_player_id in game_players:
		if other_player_id != current_player_id:
			rpc_id(other_player_id, "c_player_emit_shoot", current_player_id, bullet_index, bullet_position)

remote func s_destroy_bullet(game_id, bullet_index):
	var current_player_id = get_tree().get_rpc_sender_id()
	var game_players = CoOpStage.get_current_game_players(game_id)
	for other_player_id in game_players:
		if other_player_id != current_player_id:
			rpc_id(other_player_id, "c_destroy_bullet", bullet_index)

remote func s_destroy_bubble(game_id, bubble_index, bubble_position):
	var current_player_id = get_tree().get_rpc_sender_id()
	var game_players = CoOpStage.get_current_game_players(game_id)
	for other_player_id in game_players:
		if other_player_id != current_player_id:
			rpc_id(other_player_id, "c_destroy_bubble", bubble_index, bubble_position)

remote func s_destroy_platform(game_id, platform_index):
	var current_player_id = get_tree().get_rpc_sender_id()
	var game_players = CoOpStage.get_current_game_players(game_id)
	for other_player_id in game_players:
		if other_player_id != current_player_id:
			rpc_id(other_player_id, "c_destroy_platform", platform_index)

remote func s_coop_game_finished(game_id):
	CoOpStage.delete_game(game_id)

remote func s_login(username, password):
	var current_player_id = get_tree().get_rpc_sender_id()
	var user_list = Database.execute_query_with_args(Database.SELECT_USER_BY_NAME_AND_PASSWORD, [username, password])
	var user = null
	if user_list.size() == 1:
		user = user_list[0]
		Lobby.player_logedin(current_player_id, username)
	rpc_id(current_player_id, "c_update_player_info", user)

remote func s_update_player_score(user_id, score):
	var current_player_id = get_tree().get_rpc_sender_id()
	Database.execute_query_with_args(Database.UPDATE_USER_SCORE_BY_ID, [score, user_id])
	var user_list = Database.execute_query_with_args(Database.SELECT_USER_BY_ID, [user_id])
	var user = null
	if user_list.size() == 1:
		user = user_list[0]
	rpc_id(current_player_id, "c_update_player_info", user)

remote func s_get_all_boosts(requester):
	var current_player_id = get_tree().get_rpc_sender_id()
	var boosts_list = Database.execute_query(Database.SELECT_ALL_BOOSTS)
	rpc_id(current_player_id, "c_get_all_boosts", boosts_list, requester)

remote func s_update_player_info(user_id):
	var current_player_id = get_tree().get_rpc_sender_id()
	var user_list = Database.execute_query_with_args(Database.SELECT_USER_BY_ID, [user_id])
	var user = null
	if user_list.size() == 1:
		user = user_list[0]
	rpc_id(current_player_id, "c_update_player_info", user)

remote func s_update_selected_boost(user_id, selected_boost):
	var current_player_id = get_tree().get_rpc_sender_id()
	Database.execute_query_with_args(Database.UPDATE_USER_SELECTED_BOOST, [selected_boost, user_id])
	var user_list = Database.execute_query_with_args(Database.SELECT_USER_BY_ID, [user_id])
	var user = null
	if user_list.size() == 1:
		user = user_list[0]
	rpc_id(current_player_id, "c_update_player_info", user)
