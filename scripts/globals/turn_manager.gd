extends Node

enum {
    WAITING_PLAYERS,
    TURN_START,
    WAITING_ACTION,
    RESOLVING_ACTION,
    TURN_END
}


func _ready() -> void:
    pass

func start_first_turn():
    var peerd_ids_shuffled = GameState.players_in_lobby.keys()
    peerd_ids_shuffled.shuffle()
    GameState.set_new_turn_players_order(peerd_ids_shuffled)
    Network.request_start_game()




