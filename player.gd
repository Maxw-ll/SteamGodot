extends CharacterBody2D


var speed := 500

func  _ready() -> void:
    ready.emit()

func _physics_process(_delta):
    if not is_multiplayer_authority():
        return # Só controla o próprio player

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
