extends Control


@onready var buttons_actions: Dictionary = {
"renda":  $VBoxContainer/acoes/renda,
"coup": $VBoxContainer/acoes/coup,
"ajuda_externa": $VBoxContainer/acoes/ajuda_externa,
"roubar": $VBoxContainer/acoes/roubar,
"assassinar": $VBoxContainer/acoes/assassinar,
"tributario":  $VBoxContainer/acoes/tributario,
"troca_troca": $VBoxContainer/acoes/troca_troca,
"back_to_the_lobby": $back_lobby
}

@onready var players_container: HBoxContainer = $VBoxContainer/players
@onready var scene_player_info: PackedScene = preload("res://scenes/player/player_info.tscn")
@onready var all_buttons_actions_container: HBoxContainer = $VBoxContainer/acoes


func _ready() -> void:
	
	buttons_actions["back_to_the_lobby"].disabled = not GameState.is_host
	GameState.player_has_been_updated.connect(update_ui_players_in_game)
	GameState.turn_player_updated.connect(update_ui_actions_in_game)
	
	for action in buttons_actions:
		buttons_actions[action].pressed.connect(Callable(self, "_on_action_pressed").bind(action))
	
	all_buttons_actions_container.visible = false
	
	if GameState.is_host:
		Console.log("Host entrou no Player Scene")
	else:
		Console.log("Client entrou no Player Scene")
	
	update_ui_players_in_game()
	update_ui_actions_in_game()

func _physics_process(_delta: float) -> void:
	#Console.log(str(GameState.current_player_peer) + " " +  str(GameState.current_turn_index))
	pass


func update_ui_actions_in_game():
	if GameState.peer_id == GameState.current_player_peer:
		all_buttons_actions_container.visible = true
	else:
		all_buttons_actions_container.visible = false
	


func update_ui_players_in_game():
		
	for player in players_container.get_children():
		player.queue_free()

	for peer_id in GameState.players_peer_order:
		var scene_instantiated = scene_player_info.instantiate()
		players_container.add_child(scene_instantiated)
		scene_instantiated.update_name(GameState.players_in_lobby[peer_id]["steam_name"])
		scene_instantiated.update_cards(GameState.players_in_lobby[peer_id]["number_cards"])
		scene_instantiated.update_moedas(GameState.players_in_lobby[peer_id]["number_coins"])
	
	Console.log(str(GameState.players_peer_order))


func  _on_action_pressed(action: String):
	Console.log(action)
	if action == "back_to_the_lobby":
		Network.request_back_to_the_lobby()
	else:
		Action.process_action(action)
