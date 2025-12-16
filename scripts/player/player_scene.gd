extends Control


@onready var button_renda: Button = $VBoxContainer/acoes/renda
@onready var button_coup: Button = $VBoxContainer/acoes/coup
@onready var button_ajuda_externa: Button = $VBoxContainer/acoes/ajuda_externa
@onready var button_roubar: Button = $VBoxContainer/acoes/roubar
@onready var button_assassinar: Button = $VBoxContainer/acoes/assassinar
@onready var button_tributario: Button = $VBoxContainer/acoes/tributario
@onready var button_troca_troca: Button = $VBoxContainer/acoes/troca_troca

@onready var players_container: HBoxContainer = $VBoxContainer/players
@onready var scene_player_info: PackedScene = preload("res://scenes/player/player_info.tscn")

func _ready() -> void:
    
    button_renda.connect("pressed", Callable(self, "on_renda_pressed"))
    button_coup.connect("pressed", Callable(self, "on_coup_pressed"))
    button_ajuda_externa.connect("pressed", Callable(self, "on_ajuda_externa_pressed"))
    button_roubar.connect("pressed", Callable(self, "on_roubar_pressed"))
    button_assassinar.connect("pressed", Callable(self, "on_assassinar_pressed"))
    button_tributario.connect("pressed", Callable(self, "on_tributario_pressed"))
    button_troca_troca.connect("pressed", Callable(self, "on_troca_troca_pressed"))

    if Multiplayer.is_host:
        var data = {}
        update_player_container.rpc(data)


@rpc("any_peer")
func update_player_container(Players_Data: Dictionary):
    
    for player in players_container.get_children():
        player.queue_free()
    
    for kye in Players_Data.keys():
        var scene_instantiated = scene_player_info.instantiate()
        scene_instantiated.update_name(Players_Data["nome"])
        scene_instantiated.update_cards(2)
        scene_instantiated.update_moedas(2)
        players_container.add_child(scene_instantiated)
        

func on_renda_pressed() -> void:
    Console.log("Renda Pressed")
func on_coup_pressed() -> void:
    Console.log("Coup Pressed")
func on_ajuda_externa_pressed() -> void:
    Console.log("Ajuda externa Pressed")
func on_roubar_pressed() -> void:
    Console.log("Roubar Pressed")
func on_assassinar_pressed() -> void:
    Console.log("Assassinar Pressed")
func on_tributario_pressed() -> void:
    Console.log("Tributario Pressed")
func on_troca_troca_pressed() -> void:
    Console.log("Troca Troca Pressed")