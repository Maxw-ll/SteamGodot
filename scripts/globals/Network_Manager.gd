extends Node

var app_id: String = "480"
var steam_id: int
var steam_name: String

signal steam_on

func _ready() -> void:
    var response: bool = conection_steam_initialize()
    if response:
        steam_name = Steam.getPersonaName()
        steam_id = Steam.getSteamID()

        emit_signal("steam_on")

#Conexão com a Steam
func conection_steam_initialize() -> bool:

    OS.set_environment("SteamAppId", app_id)
    OS.set_environment("SteamGameId", app_id)

    var response_to_connect: Dictionary = Steam.steamInitEx()

    if response_to_connect["status"] == 0:
        Console.log("[STEAM CONECTADA]")
        return true

    elif response_to_connect["status"] > 0:
        Console.log("[color=red] [NÃO FOI POSSÍVEL SE CONECTAR À STEAM]")
    
    return false

func _process(_delta: float) -> void:
    Steam.run_callbacks()


