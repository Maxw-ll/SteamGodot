extends Node

#SCRIPT PROCESSADO UNICAMENTE NO HOST
func  handle_action_requested(sended_pid, action, target_pid):
	if not GameState.is_host:
		return
	

	if not Turn.is_current_player(sended_pid):
		return

	match action:
		"renda":
			_handle_renda(sended_pid)
		"coup":
			_handle_coup(sended_pid, target_pid)


func _handle_renda(peer_id):

	GameState.players_in_lobby[peer_id]["number_coins"] += 1

	Console.log(GameState.players_in_lobby[peer_id]["steam_name"] + " usou Renda (+ 1 Moeda)" )

	_end_action()


func _handle_coup(_sended_pid, _target_pid):

	pass
 
func _end_action():
	Network.broadcast_sync_game_state.rpc(GameState.players_in_lobby)
	Network.broadcast_next_turn_player.rpc()