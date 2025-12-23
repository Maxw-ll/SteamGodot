extends Control

@onready var ready_button: Button = $HBoxContainer/ready
@onready var start_button: Button = $HBoxContainer/start
@onready var players_list: VBoxContainer = $VBoxContainer

var is_ready: bool = false

##################### INICIALIZAÇÃO #####################
func _ready() -> void:

	GameState.player_has_been_updated.connect(_refresh_players)

	start_button.visible = false
	start_button.disabled = true

	ready_button.visible = false
	ready_button.disabled = true

	if multiplayer.is_server():
		start_button.visible = true

	else:
		ready_button.disabled = false
		ready_button.visible = true
	
	_refresh_players()
	
##################### ESTILIZAÇÃO LABEL DOS NOMES #####################
func make_label_style(label: Label) -> void:

	var style = StyleBoxFlat.new()
	style.set_border_width_all(2)
	style.border_color = Color(1, 1, 1, 0.8)
	style.set_corner_radius_all(6)

	style.bg_color = Color(0.1, 0.1, 0.1, 0.4)

	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 4
	style.content_margin_bottom = 4

	label.add_theme_stylebox_override("normal", style)


##################### ATUALIZAÇÃO DO BOTÃO DE START #####################
func _process(_delta: float) -> void:
	var all_players_ready: bool = true

	if GameState.players_in_lobby.size() == 1:
		all_players_ready = false

	for this_peer_id in GameState.players_in_lobby.keys():
		if GameState.players_in_lobby[this_peer_id]["ready"] == false:
			all_players_ready = false
			break
	
	start_button.disabled = not all_players_ready
	


##################### READY #####################
func _on_ready_pressed() -> void:
	is_ready = true
	ready_button.disabled = true
	ready_button.text = "Pronto!"
	Network.request_upate_ready_state(multiplayer.get_unique_id(), is_ready)

##################### START GAME #####################
func _on_start_pressed() -> void:
	Console.log("Jogando Começando..")
	start_button.disabled = true
	Turn.start_first_turn()
	
##################### ATUALIZAÇÃO DOS PLAYERS #####################
func _refresh_players():
	for p in players_list.get_children():
		p.queue_free()

	for this_peer_id in GameState.players_in_lobby.keys():
		var label_p = Label.new()
		label_p.text = GameState.players_in_lobby[this_peer_id]["steam_name"]
		make_label_style(label_p)
		players_list.add_child(label_p)
		
##################### EVENTOS DE CONEXÃO #####################
