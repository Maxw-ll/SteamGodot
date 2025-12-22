extends Node

enum {
    WAINTING_PLAYERS,
    TURN_START,
    WAINTING_ACTION,
    RESOLVING_ACTION,
    TURN_ENG
}

var players_peer_order = []
var state = WAINTING_PLAYERS
var current_turn_index: int = 0
var current_peer_id: int = -1


