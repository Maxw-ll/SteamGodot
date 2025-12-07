extends Node

var app_id: String = "480"
signal lobby_createee(id)

var lol_id: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_steam()

	Steam.connect("lobby_created", Callable(self, "_on_lobby_created"))
	Steam.connect("lobby_joined", Callable(self, "_on_lobby_joined"))
	Steam.connect("lobby_chat_update", Callable(self, "_on_data_update"))
	#Steam.connect("lobby_chat_update", Callable(self, "_on_lobby_chat_message"))
	
func _on_lobby_chat_message(_lobby_id, _user, message, _type):
	Console.log("Mensagem recebida do JOIN: " + message)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Steam.run_callbacks()


func _on_lobby_joined(lobby_id, permissions, locked, response):
	lol_id = lobby_id
	Console.log("[JOIN] Entrou no lobby? LobbyID=" + str(lobby_id))
	Console.log("[JOIN] Response code = " + str(response))
	Console.log("[JOIN] Permissions = " + str(permissions))
	Console.log("[JOIN] Locked = " + str(locked))
	var nm = Steam.getLobbyData(lobby_id, "name")
	Console.log("Entrei no LOBBY de "+ str(nm))
	
	
	
func send_message(mdg: String):
	Console.log("Mensagem foi ennviada!")
	Steam.sendLobbyChatMsg(lol_id, mdg)
	
func _on_data_update(lobby_id, _member_id):
	Console.log("[HOST] lobby_data_update disparou!")
	Console.log("Player in Lobby: " + str(Steam.getNumLobbyMembers(lobby_id)))
	
	for i in range(Steam.getNumLobbyMembers(lobby_id)):
		var player = Steam.getLobbyMemberByIndex(lobby_id, i)
		Console.log(" - Player SteamID" + str(player))

	
	
func initialize_steam():
	OS.set_environment("SteamAppId", app_id)
	OS.set_environment("SteamAppGame", app_id)
	
	var initialize_response: Dictionary = Steam.steamInitEx()
	var msg: String
	
	if initialize_response["status"] == 0:
		msg = "Steam is Running"
		Console.log("[color=green] %s" % msg)
	
	if !Steam.isSubscribed(): 
		get_tree().quit()
		
	if initialize_response["status"] > 0:
		msg = " Failed to Initialized Steam"
		Console.log("[color=red] %s" %msg)

func create_lobby(max_players := 4):
	Console.log("Criando Lobby...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, max_players)


func enter_lobby(id):
	Steam.joinLobby(id)

func _on_lobby_created(success, lobby_id):
	if not success:
		Console.log("[color=red] Erro ao criar o Lobby!")
		return
	lol_id = lobby_id
	emit_signal("lobby_createee", str(lobby_id))
	Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName(), "SABYS's LOBBY"))
	#Steam.setLobbyJoinable(lobby_id, true)
	Console.log("Lobby ID real: " + str(lobby_id))
		
func verifiy_friends():
	Console.log("[color=green] " + str(Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)) + " amigos encontrados!")
	var my_name: String = Steam.getPersonaName()
	Console.log("My name is " + my_name)
	Console.log("Amigos:")
	
	for i in range(0, Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)):
		var steam_id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var friend_name: String = Steam.getFriendPersonaName(steam_id)
		Console.log(friend_name)

		
	
		
