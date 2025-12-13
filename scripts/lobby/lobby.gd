extends Control

@onready var ready_button: Button = $HBoxContainer/ready
@onready var start_button: Button = $HBoxContainer/start
@onready var players_list: VBoxContainer = $VBoxContainer

var is_ready: bool = false
var players_ready: Dictionary = {}

##################### INICIALIZAÇÃO #####################
func _ready() -> void:
	start_button.visible = false
	start_button.disabled = true

	ready_button.visible = false
	ready_button.disabled = true

	if multiplayer.is_server():
		start_button.visible = true
		_refresh_players()

	else:
		ready_button.disabled = false
		ready_button.visible = true
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	

	

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

	if Array(multiplayer.get_peers()).is_empty():
		all_players_ready = false

	for pid in multiplayer.get_peers():
		if not players_ready.get(pid, false):
			all_players_ready = false
			break
	
	start_button.disabled = !all_players_ready


##################### READY #####################
func _on_ready_pressed() -> void:
	is_ready = true
	ready_button.disabled = true
	ready_button.text = "Pronto!"
	rpc_update_ready_state.rpc(multiplayer.get_unique_id(), is_ready)

##################### START GAME #####################
func _on_start_pressed() -> void:
	Console.log("Jogando Começando..")
	start_button.disabled = true
	rpc_start_match.rpc()


##################### RPCs #####################
@rpc("any_peer", "reliable")
func rpc_update_ready_state(peer_id: int, state: bool) -> void:
	players_ready[peer_id] = state

	_refresh_players()
	Console.log(" Jogador %s está Pronto")

@rpc("any_peer", "call_local", "reliable")
func rpc_start_match() -> void:
	if multiplayer.is_server():
		await  get_tree().create_timer(0.1).timeout

	get_tree().change_scene_to_file("res://scenes/spawner/spawner.tscn")

##################### ATUALIZAÇÃO DOS PLAYERS #####################
func _refresh_players():
	for p in players_list.get_children():
		p.queue_free()
	
	var all_players = [multiplayer.get_unique_id()]
	all_players += Array(multiplayer.get_peers())

	for pid in all_players:
		var label_p = Label.new()
		label_p.text = str(pid)
		make_label_style(label_p)
		players_list.add_child(label_p)

##################### EVENTOS DE CONEXÃO #####################
func _on_peer_connected(id):
	players_ready[id] = false
	_refresh_players()


func _on_peer_disconnected(id):
	players_ready.erase(id)
	_refresh_players()
