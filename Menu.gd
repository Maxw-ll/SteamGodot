extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var line_edit: LineEdit = $LineEdit
@onready var lobby: LineEdit = $LineEdit2
@onready var join: Button = $join
@onready var host: Button = $host

var lobby_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.connect("lobby_createdd", Callable(self, "on_loby_finished_created"))
	Network.connect("lobby_joinedd", Callable(self, "on_lobby_finished_joined"))
	Console.connect("log_msg", Callable(self, "_on_log"))

	
	Network.verifiy_friends()

func _on_log(msg: String):
	rich_text_label.append_text(msg + "\n")

func _on_host_pressed() -> void:
	Network.create_lobby()


func on_loby_finished_created(id):
	join.queue_free()
	host.queue_free()
	line_edit.queue_free()
	lobby.text += id
	lobby_id = int(id)
	lobby.visible = true
	var snce = preload("res://sync.tscn")
	var k = snce.instantiate()
	add_child(k)
	

func on_lobby_finished_joined():
	var snce = preload("res://sync.tscn")
	var k = snce.instantiate()
	add_child(k)

	
func _on_join_pressed() -> void:
	lobby_id = int(line_edit.text)
	join.queue_free()
	host.queue_free()
	line_edit.queue_free()
	lobby.text += str(lobby_id)
	lobby.visible = true
	Network.enter_lobby(lobby_id)

	
