extends Control

@onready var multiplayer_steam_button = $VBoxContainer/WAN
@onready var multiplayer_local_button = $VBoxContainer/LAN 

@onready var menu_host_join_scene: PackedScene = preload("res://scenes/menu/menu.tscn")


#MENU INICIAL COM A ESCOLHA DO TIPO DE MULTIPLAYER
func _on_lan_pressed() -> void:
	Lobby.connected_with_local_network = true
	get_tree().change_scene_to_packed(menu_host_join_scene)

func _on_wan_pressed() -> void:
	Lobby.connected_with_global_network = true
	get_tree().change_scene_to_packed(menu_host_join_scene)

