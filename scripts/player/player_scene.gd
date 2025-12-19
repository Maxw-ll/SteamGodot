extends Control


@onready var buttons_actions: Dictionary = {
"renda":  $VBoxContainer/acoes/renda,
"coup": $VBoxContainer/acoes/coup,
"ajuda_externa": $VBoxContainer/acoes/ajuda_externa,
"roubar": $VBoxContainer/acoes/roubar,
"assassinar": $VBoxContainer/acoes/assassinar,
"tributario":  $VBoxContainer/acoes/tributario,
"troca_troca": $VBoxContainer/acoes/troca_troca
}

@onready var players_container: HBoxContainer = $VBoxContainer/players
@onready var scene_player_info: PackedScene = preload("res://scenes/player/player_info.tscn")


func _ready() -> void:
	
	for action in buttons_actions:
		buttons_actions[action].pressed.connect(Callable(self, "_on_action_pressed").bind(action))
	

	if Multiplayer.is_host:
		Console.log("Host entrou no player")
		update_player_container.rpc(Multiplayer.players_in_lobby)



@rpc("any_peer", "call_local")
func update_player_container(Players_Data: Array):

	Console.log(str(Multiplayer.players_in_lobby))
	
	for player in players_container.get_children():
		player.queue_free()
	
	for kye in Players_Data:
		var scene_instantiated = scene_player_info.instantiate()
		players_container.add_child(scene_instantiated)
		scene_instantiated.update_name(kye["name"])
		scene_instantiated.update_cards(2)
		scene_instantiated.update_moedas(2)
	
	Multiplayer.players_in_lobby = Players_Data
	Console.log(str(Multiplayer.players_in_lobby))
		

func  _on_action_pressed(action: String):
	Console.log(action)
	if action == "renda" and multiplayer.is_server():
		back_to_the_lobby.rpc()


@rpc("any_peer", "call_local", "reliable")
func back_to_the_lobby():
	
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")

