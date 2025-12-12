extends Node

var is_host: bool = false
var app_id: String = "480"
var lol_id: int
var my_id: int

signal lobby_createdd(id)
signal lobby_joinedd

#Inicialização
func _ready() -> void:
	initialize_steam()
	Steam.connect("lobby_created", Callable(self, "_on_lobby_created"))
	Steam.connect("lobby_joined", Callable(self, "_on_lobby_joined"))
	Steam.connect("lobby_chat_update", Callable(self, "_on_data_update"))
	Steam.connect("lobby_message", Callable(self, "_on_lobby_chat_message"))

	Steam.lobby_match_list.connect(show_lobby_list)
	

	_open_lobby_list()

#Process - Steam Run Callbacks
func _process(_delta: float) -> void:
	Steam.run_callbacks()


#Lobby Informations
func _open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func show_lobby_list(lobbies):

	for lb in lobbies:
		var lobby_name: String = Steam.getLobbyData(lb, "name")
		var numMembers = Steam.getNumLobbyMembers(lb)
		Console.log(str(lb) + " " + lobby_name +": " + str(numMembers))


### SINAIS LOBBYS ###

#Signal Lobby Message
func _on_lobby_chat_message(_lobby_id: int, _user: int, message: String, _chat_type: int):
	Console.log("Mensagem recebida de " + Steam.getFriendPersonaName(_user) + " : " + message)

#Signal Lobby Created
func _on_lobby_created(success, lobby_id):
	if not success:
		Console.log("[color=red] Erro ao criar o Lobby!")
		return
	lol_id = lobby_id
	Steam.setLobbyData(lobby_id, "name", "Sabryna meu Amor, minha Vida ❤️.")
	Console.log("Lobby ID real: " + str(lobby_id))
	var peer = SteamMultiplayerPeer.new()
	peer.host_with_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer
	emit_signal("lobby_createdd", str(lobby_id))
	Console.log(str(multiplayer.multiplayer_peer))

#Signal Lobby Joined
func _on_lobby_joined(lobby_id, permissions, locked, response):
	lol_id = lobby_id
	Console.log("[JOIN] Entrou no lobby? LobbyID=" + str(lobby_id))
	Console.log("[JOIN] Response code = " + str(response))
	Console.log("[JOIN] Permissions = " + str(permissions))
	Console.log("[JOIN] Locked = " + str(locked))
	var nm = Steam.getLobbyData(lobby_id, "name")
	Console.log("Entrei no LOBBY de "+ str(nm))
	
	if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
		Console.log("SOU O HOST")
		return
	
	var peer = SteamMultiplayerPeer.new()
	peer.connect_to_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer
	Console.log(str(multiplayer.multiplayer_peer))
	#var steam_id = Steam.getSteamID()
	var peer_id = multiplayer.get_unique_id()

	Steam.setLobbyMemberData(lobby_id, "peer_id", str(peer_id))

	emit_signal("lobby_joinedd")

#Signal Lobby Data Update
func _on_data_update(lobby_id: int, _changed_id: int, _making_change_id: int, _chat_state: int):
	Console.log("[HOST] lobby_data_update disparou!")
	Console.log("Player in Lobby : " + str(Steam.getNumLobbyMembers(lobby_id)))
	
	for i in range(Steam.getNumLobbyMembers(lobby_id)):
		var player = Steam.getFriendPersonaName(Steam.getLobbyMemberByIndex(lobby_id, i))
		Console.log(" - Player SteamID: " + player)


### END SIGNAL LOBBY ###

### FUNCTIONS TO WORK ###
#Init Steam
func initialize_steam():
	OS.set_environment("SteamAppId", app_id)
	OS.set_environment("SteamAppGame", app_id)
	
	var initialize_response: Dictionary = Steam.steamInitEx()
	var msg: String

	if initialize_response["status"] == 0:
		msg = "Steam is Running"
		my_id = Steam.getSteamID()
		Console.log("[color=green] %s" % msg)
	
	if !Steam.isSubscribed(): 
		get_tree().quit()
		
	if initialize_response["status"] > 0:
		msg = " Failed to Initialized Steam"
		Console.log("[color=red] %s" %msg)
	

#Send Message
func send_message(mdg: String):
	Console.log("Mensagem foi enviada!")
	Steam.sendLobbyChatMsg(lol_id, mdg)
	

#Create Lobby
func create_lobby(max_players := 4):
	Console.log("Criando Lobby...")
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, max_players)

#Join Lobby
func enter_lobby(id):
	Console.log("Solicitando entrada no Lobby")
	Steam.joinLobby(id)

#Verify Friends
func verifiy_friends():
	Console.log("[color=green] " + str(Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)) + " amigos encontrados!")
	var my_name: String = Steam.getPersonaName()
	Console.log("My name is " + my_name)
	Console.log("Amigos:")
	
	for i in range(0, Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)):
		var steam_id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var friend_name: String = Steam.getFriendPersonaName(steam_id)
		Console.log(friend_name)

### END FUNCTIONS TO WORK ###