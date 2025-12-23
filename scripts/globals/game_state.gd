extends Node

signal player_has_been_updated
#signal order_players_has_been_updated

#Player
var is_host: bool = false
var lobby_id: int
var lobby_name: String
var peer_id: int
var room_code: String
var room_code_length = 6
var players_in_lobby: Dictionary

#Turno
var players_peer_order = []
var state = Turn.WAITING_PLAYERS
var current_turn_index: int = 0


func _physics_process(_delta: float) -> void:
    #Console.log(str(GameState.players_in_lobby))
    pass

##################### FUNÇÕES PLAYERS UPDATE #####################

func add_player_in_lobby(this_peer_id, this_steam_id, this_steam_name, this_ready):
    players_in_lobby[this_peer_id] = {"steam_id": this_steam_id, "steam_name": this_steam_name, "ready": this_ready}
    player_has_been_updated.emit()

func updated_players_from_network(this_players_in_lobby):
    self.players_in_lobby = this_players_in_lobby
    player_has_been_updated.emit()

func set_player_ready_state(this_peer_id: int, this_state: bool):
    players_in_lobby[this_peer_id]["ready"] = this_state
    player_has_been_updated.emit()

func set_player_peer_id_disconnected(this_peer_id: int):
    players_in_lobby.erase(this_peer_id)
    players_peer_order.erase(this_peer_id)
    player_has_been_updated.emit()

func reset_players_ready_state():
    for this_peer_id in players_in_lobby.keys():
        if this_peer_id == 1:
            players_in_lobby[this_peer_id]["ready"] = true
        else:
            players_in_lobby[this_peer_id]["ready"] = false


##################### FUNÇÕES TURNS UPDATES #####################

func set_new_turn_players_order(order: Array) -> void:
    players_peer_order = order.duplicate()
    player_has_been_updated.emit()