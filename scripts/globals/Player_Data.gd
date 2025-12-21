extends Node

var steam_id: int
var steam_name: String 

func _ready() -> void:
    Console.log(str(steam_id) + " " + steam_name)

func get_steam_id() -> int:
    return steam_id

func get_steam_name() -> String:
    return steam_name

func set_steam_id(this_steam_id: int) -> void:
    self.steam_id = this_steam_id

func set_steam_name(this_steam_name: String) -> void:
    self.steam_name = this_steam_name

