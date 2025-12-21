extends Node

signal player_has_been_updated

var is_host: bool = false
var lobby_id: int
var lobby_name: String
var peer_id: int
var room_code: String
var room_code_length = 6
var players_in_lobby: Array


func updated_from_network(game_state):
    self.players_in_lobby = game_state
    player_has_been_updated.emit()

func set_player_ready_state(this_peer_id: int, this_state: bool):
    for p in self.players_in_lobby:
        if p["peer_id"] == this_peer_id:
            p["ready"] = this_state
    
    player_has_been_updated.emit()
            
func set_player_peer_id_connected(this_peer_id: int, this_steam_id: int):
    for p in self.players_in_lobby:
        if p["steam_id"] == this_steam_id:
            p["peer_id"] = this_peer_id

    player_has_been_updated.emit()

func set_player_peer_id_disconnected(this_peer_id: int):
    var count_index: int = 0
    for p in self.players_in_lobby:
        if p["peer_id"] == this_peer_id:
            GameState.players_in_lobby.remove_at(count_index)
        count_index += 1
    
    player_has_been_updated.emit()

func reset_players_ready_state():
    for p in players_in_lobby:
        if p["peer_id"] != 1:
            p["ready"] = false