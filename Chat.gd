extends Control

@onready var text_edit: TextEdit = $TextEdit
@onready var button: Button = $Button
@onready var text_char: TextEdit = $TextEdit2

var my_name: String

func _ready() -> void:
	my_name = Steam.getPersonaName()

func _physics_process(_delta: float) -> void:

	if Input.is_action_just_pressed("Enter"):
		_on_button_pressed()

func _on_button_pressed() -> void:
	var text = text_edit.text

	text_edit.text = ""
	if text == "" :
		return
	else:
		if text == "\n":
			return

		else:
			if text[text.length()-1] == "\n":
				text[text.length()-1] = ""


	var final_message = "%s: %s" % [my_name, text]

	send_message_p2p.rpc(final_message)


@rpc("any_peer", "call_local", "reliable")
func send_message_p2p(msg: String):

	text_char.text += msg + "\n"
