extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var line_edit: LineEdit = $LineEdit
@onready var lobby_label: LineEdit = $LineEdit2
@onready var join: Button = $join
@onready var host: Button = $host

##################### INICIALIZAÇÃO #####################
func _ready() -> void:
	Multiplayer.connect("lobby_created", Callable(self, "on_loby_finished_created"))
	Multiplayer.connect("lobby_joined", Callable(self, "on_lobby_finished_joined"))
	Console.connect("log_msg", Callable(self, "_on_log"))

##################### SINAIS DE CONEXÃO ##################### 

#Conceta à função de Imprimir no Console
func _on_log(msg: String) -> void:
	rich_text_label.append_text(msg + "\n")

#Iniciar criação do lobby clicar no Host
func _on_host_pressed() -> void:
	Multiplayer.create_lobby()
	kill_inputs()


#Iniciar entrada no lobby quando cliar no Join
func _on_join_pressed() -> void:
	lobby_label.text += line_edit.text
	lobby_label.visible = true
	Multiplayer.join_lobby(int(line_edit.text))
	kill_inputs()

#Qunando o Lobby foi criado!
func on_loby_finished_created(this_lobby_id) -> void:
	lobby_label.text += this_lobby_id
	lobby_label.visible = true
	load_scene()

#Quando entrar no Lobby carregar a cena
func on_lobby_finished_joined() -> void:
	load_scene()

#Carregar a Cena do Spawner
func load_scene() -> void:
	var scene: PackedScene = preload("res://scenes/spawner/spawner.tscn")
	var scene_instantiated = scene.instantiate()
	add_child(scene_instantiated)

#Retirar os Inputs
func kill_inputs() -> void:
	join.queue_free()
	host.queue_free()
	line_edit.queue_free()
