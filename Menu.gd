extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var line_edit: LineEdit = $LineEdit
@onready var lobby: LineEdit = $LineEdit2
@onready var join: Button = $join
@onready var host: Button = $host

var lobby_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.connect("lobby_createee", Callable(self, "_on_lobby_create_mx"))
	Console.connect("log_msg", Callable(self, "_on_log"))
	
	Network.verifiy_friends()

func _on_log(msg: String):
	rich_text_label.append_text(msg + "\n")

func _on_host_pressed() -> void:
	Network.create_lobby()

func _on_lobby_create_mx(id):
	#Console.log("Entrou no Line Edit")
	join.queue_free()
	host.queue_free()
	line_edit.queue_free()
	lobby.text += id
	lobby_id = int(id)
	lobby.visible = true
	var scene = load("res://Chat.tscn")
	var instance = scene.instantiate()
	add_child(instance)


func _on_join_pressed() -> void:
	lobby_id = int(line_edit.text)
	join.queue_free()
	host.queue_free()
	line_edit.queue_free()
	lobby.text += str(lobby_id)
	lobby.visible = true
	Network.enter_lobby(lobby_id)
	var scene = load("res://Chat.tscn")
	var instance = scene.instantiate()
	add_child(instance)
