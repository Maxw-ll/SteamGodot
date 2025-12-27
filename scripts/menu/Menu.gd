extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var line_code: LineEdit = $LineEdit
@onready var lobby_label: LineEdit = $LineEdit2
@onready var join: Button = $HBoxContainer/join
@onready var host: Button = $HBoxContainer/host

#Somente UI do MENU

##################### INICIALIZAÇÃO #####################
func _ready() -> void:
	Lobby.connect("lobby_createdd", Callable(self, "on_loby_finished_created"))
	Lobby.connect("lobby_joinedd", Callable(self, "on_lobby_finished_joined"))
	Lobby.connect("host_created", Callable(self, "on_host_created"))
	Console.connect("log_msg", Callable(self, "_on_log"))

	if Lobby.connected_with_local_network:
		line_code.placeholder_text = "Insert You Name"

##################### SINAIS DE CONEXÃO ##################### 

#Conceta à função de Imprimir no Console
func _on_log(msg: String) -> void:
	self.rich_text_label.append_text(msg + "\n")

#Iniciar criação do lobby clicar no Host
func _on_host_pressed() -> void:
	if Lobby.connected_with_global_network:
		Lobby.create_lobby()
	else:
		PlayerData.set_steam_name(line_code.text)
		Lobby.create_local_lobby()
	

func on_host_created(status: bool):
	if Lobby.connected_with_local_network:
		GameState.player_has_been_updated.emit()
	if status == false:
		host.disabled = false


#Iniciar entrada no lobby quando cliar no Join
func _on_join_pressed() -> void:
	self.lobby_label.text += line_code.text
	self.lobby_label.visible = true
	if Lobby.connected_with_global_network:
		Lobby.join_lobby(self.line_code.text.strip_edges())
	else:
		PlayerData.set_steam_name(line_code.text)
		Lobby.connect_local_lobby()
	

#Qunando o Lobby foi criado!
func on_loby_finished_created() -> void:
	self.lobby_label.text += GameState.room_code
	self.lobby_label.visible = true
	kill_inputs()
	load_scene()

#Quando entrar no Lobby carregar a cena
func on_lobby_finished_joined() -> void:
	kill_inputs()
	load_scene()

#Carregar a Cena do Spawner
func load_scene() -> void:
	var scene: PackedScene = preload("res://scenes/lobby/lobby.tscn")
	var scene_instantiated = scene.instantiate()
	add_child(scene_instantiated)

#Retirar os Inputs
func kill_inputs() -> void:
	self.join.queue_free()
	self.host.queue_free()
	self.line_code.queue_free()
