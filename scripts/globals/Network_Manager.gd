extends Node


func _ready() -> void:
    multiplayer.connected_to_server.connect(_on_connected_to_the_server)
    multiplayer.connection_failed.connect(_on_connection_to_the_server_failed)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_connected_to_the_server():
    Console.log("Novo Cliente Conectado!")
    register_on_the_server.rpc_id(1, multiplayer.get_unique_id(), PlayerData.get_steam_id(), PlayerData.get_steam_name())

func _on_connection_to_the_server_failed():
    Console.log("ERRO ao se Conectar ao Servidor!")

func _on_peer_disconnected(this_peer_id: int):
    GameState.set_player_peer_id_disconnected(this_peer_id)

##################### FUNÇÕES ACESSIVEIS #####################
func request_upate_ready_state(peer_id: int, state: bool) -> void:
    rpc_update_ready_state.rpc_id(1, peer_id, state)

func request_start_game() -> void:
    rpc_start_game.rpc(GameState.players_peer_order)

func request_back_to_the_lobby():
    if multiplayer.is_server():
        broadcast_back_to_the_lobby.rpc()

##################### RPCS TO SERVER | CLIENTE -> SERVIDOR #####################
@rpc("any_peer", "reliable")
func register_on_the_server(this_peer_id: int, this_steam_id: int, this_steam_name: String):

    if not multiplayer.is_server():
        Console.log("Não sou o servidor no NetManager")
    
    GameState.add_player_in_lobby(this_peer_id, this_steam_id, this_steam_name, false)

    new_player_registered_broadcast.rpc(GameState.players_in_lobby, this_steam_name)

@rpc("any_peer", "call_local", "reliable")
func rpc_start_game(this_order_players):
    GameState.players_peer_order = this_order_players.duplicate()
    get_tree().change_scene_to_file("res://scenes/player/player_scene.tscn")


@rpc("any_peer", "reliable")
func rpc_update_ready_state(this_peer_id: int, this_state: bool) -> void:
    
    GameState.set_player_ready_state(this_peer_id, this_state)
    updated_ready_state_broadcast.rpc(this_peer_id, this_state)

##################### RPCS TO CLIENT | SERVIDOR -> CLIENTE #####################
    
@rpc("any_peer", "reliable") 
func new_player_registered_broadcast(this_players_in_lobby, this_steam_name):
    Console.log(this_steam_name + " entrou no Lobby.")
    GameState.updated_players_from_network(this_players_in_lobby)

@rpc("any_peer", "reliable")
func updated_ready_state_broadcast(this_peer_id: int, this_state: bool):
    GameState.set_player_ready_state(this_peer_id, this_state)

@rpc("any_peer", "call_local", "reliable")
func broadcast_back_to_the_lobby():
    GameState.reset_players_ready_state()
    get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")

    