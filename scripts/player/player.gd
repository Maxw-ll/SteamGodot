extends CharacterBody2D

var Data: Dictionary = {
	"name": name,
	"color": Color(1, 1, 1, 1)
}

@onready var name_label: LineEdit = $LineEdit
@onready var sprite: Sprite2D = $Sprite2D
var speed := 500

##################### INICIALIZAÇÃO #####################
func _ready() -> void:
	Console.log(str(multiplayer.multiplayer_peer))
	randomize()
	#Atualizar nome
	name_label.text = self.name

	var pid = int(self.name)
	var r = float(pid % 255)/255
	var g = float(randi()%255)/255
	var b = float(randi()%255)/255

	#Atualizar cor
	sprite.modulate = Color(r, g, b, 1)

##################### MOVIMENTAÇÃO #####################
func _physics_process(_delta):
	if not is_multiplayer_authority():
		return

	var dir = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1

	velocity = dir.normalized() * speed
	move_and_slide()
