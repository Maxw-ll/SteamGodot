extends Control

@onready var text_edit: TextEdit = $TextEdit
@onready var button: Button = $Button


func _on_button_pressed() -> void:
	var text = text_edit.text
	Network.send_message(text)
	text_edit.clear()
