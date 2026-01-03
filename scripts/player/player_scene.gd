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
@onready var target_players_container: HBoxContainer = $VBoxContainer/players_target
@onready var label_card_1: Label = $VBoxContainer/cards/card_1
@onready var label_card_2: Label = $VBoxContainer/cards/card_2

signal request_target_player

var _action = null

func _ready() -> void:


	buttons_actions["back_to_the_lobby"].disabled = not GameState.is_host
	GameState.player_has_been_updated.connect(update_ui_players_in_game)
	GameState.turn_player_updated.connect(update_ui_actions_in_game)
	request_target_player.connect(update_ui_target_players_button)

	label_card_1.text = PlayerData.cards[0]
	label_card_2.text = PlayerData.cards[1]
	
	for action in buttons_actions:
		match action:
			"assassinar":
				buttons_actions[action].disabled = true
			"coup":
				buttons_actions[action].disabled = true

		buttons_actions[action].pressed.connect(Callable(self, "_on_action_pressed").bind(action))
	
	all_buttons_actions_container.visible = false
	
	if GameState.is_host:
		Console.log("Host entrou no Player Scene")
	else:
		Console.log("Client entrou no Player Scene")
	
	update_ui_players_in_game()
	update_ui_actions_in_game()
	init_ui_target_players_button()

func _physics_process(_delta: float) -> void:
	#Console.log(str(GameState.current_player_peer) + " " +  str(GameState.current_turn_index))
	pass

func update_ui_actions_in_game():
	if GameState.peer_id == GameState.current_player_peer:
		all_buttons_actions_container.visible = true
	else:
		all_buttons_actions_container.visible = false

	if GameState.players_in_lobby[GameState.peer_id]["number_coins"] >= 3:
		buttons_actions["assassinar"].disabled = false
	else:
		buttons_actions["assassinar"].disabled = true


	if GameState.players_in_lobby[GameState.peer_id]["number_coins"] >= 7:
		buttons_actions["coup"].disabled = false
	else:
		buttons_actions["coup"].disabled = true

		
	



func update_ui_target_players_button():
	target_players_container.visible = true
	all_buttons_actions_container.visible = false


func init_ui_target_players_button():

	for pid in GameState.players_in_lobby:
		if pid != GameState.peer_id:
			var button_player = Button.new()
			button_player.text = GameState.players_in_lobby[pid]["steam_name"]
			target_players_container.add_child(button_player)
			button_player.pressed.connect(Callable(self, "_on_target_player_pressed").bind(pid))
	
	target_players_container.visible = false
	

func update_ui_players_in_game():

	
			
	for player in players_container.get_children():
		player.queue_free()

	for peer_id in GameState.players_peer_order:
		var scene_instantiated = scene_player_info.instantiate()
		players_container.add_child(scene_instantiated)
		scene_instantiated.update_name(GameState.players_in_lobby[peer_id]["steam_name"])
		scene_instantiated.update_moedas(GameState.players_in_lobby[peer_id]["number_coins"])
	
	Console.log(str(GameState.players_peer_order))

func _on_target_player_pressed(target):

	Network.request_action(_action, target)
	target_players_container.visible = false
	_action = null

func  _on_action_pressed(action: String):
	Console.log(action)
	if action == "back_to_the_lobby":
		Network.request_back_to_the_lobby()
	else:
		if action == "renda":
			Network.request_action(action, 0)
		if action == "coup":
			_action = action
			request_target_player.emit()
