extends Control

@onready var text_edit: TextEdit = $TextEdit
@onready var button: Button = $Button
@onready var text_chat: TextEdit = $TextEdit2

var my_name: String

func _ready() -> void:
	my_name = Steam.getPersonaName()
	

func _on_button_pressed() -> void:
	
	var text = text_edit.text

	if text == "":
		return

	text_edit.text = ""
	
	var final_message = "%s: %s\n" % [my_name, text]

	receive_message.rpc(final_message)
	
	receive_message(final_message)

@rpc("any_peer")
func receive_message(msg: String):
	text_chat.text += msg
	Console.log("RECEBIDO: "+ msg)
