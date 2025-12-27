extends Node


func process_action(action: String):

	match action:
		"renda": 
			Network.request_update_player_coins(GameState.peer_id, 1)
