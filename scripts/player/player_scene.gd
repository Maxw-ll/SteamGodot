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


func _ready() -> void:
	
	buttons_actions["back_to_the_lobby"].disabled = not GameState.is_host
	GameState.player_has_been_updated.connect(update_ui_players_in_game)
	
	for action in buttons_actions:
		buttons_actions[action].pressed.connect(Callable(self, "_on_action_pressed").bind(action))
	

	if GameState.is_host:
		Console.log("Host entrou no Player Scene")
	else:
		Console.log("Client entrou no Player Scene")
	
	update_ui_players_in_game()


func update_ui_players_in_game():
	for player in players_container.get_children():
		player.queue_free()
	
	for peer_id in GameState.players_peer_order:
		var scene_instantiated = scene_player_info.instantiate()
		players_container.add_child(scene_instantiated)
		scene_instantiated.update_name(GameState.players_in_lobby[peer_id]["steam_name"])
		scene_instantiated.update_cards(2)
		scene_instantiated.update_moedas(2) 
	
	Console.log(str(GameState.players_peer_order))


func  _on_action_pressed(action: String):
	Console.log(action)
	if action == "back_to_the_lobby":
		Network.request_back_to_the_lobby()
