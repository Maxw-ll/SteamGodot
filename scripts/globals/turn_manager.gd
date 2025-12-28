extends Node

enum {
	WAITING_ACTION,
	RESOLVING_ACTION
}


func _ready() -> void:
	pass

func start_first_turn():
	var peerd_ids_shuffled = GameState.players_in_lobby.keys()
	#Sortear a ordem de jogo
	peerd_ids_shuffled.shuffle()
	GameState.players_peer_order = peerd_ids_shuffled.duplicate()
	GameState.turn_player_updated.emit()

func _set_current_player_peer():
	GameState.number_players = GameState.players_peer_order.size()
	GameState.current_player_peer = GameState.players_peer_order[GameState.current_turn_index % GameState.number_players]

func next_turn():
	GameState.current_turn_index += 1
	_set_current_player_peer()
	GameState.turn_player_updated.emit()

func set_new_turn_players_order(order: Array) -> void:
	GameState.players_peer_order = order.duplicate()
	GameState.number_players = order.size()
	_set_current_player_peer()
	GameState.player_has_been_updated.emit()
