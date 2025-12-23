extends Node

signal lobby_createdd(lobby_code: String)
signal lobby_joinedd

##################### INICIALIZAÇÃO #####################
func _ready() -> void:
	randomize()

	Steam.connect("lobby_created", Callable(self, "_on_lobby_created"))
	Steam.connect("lobby_joined", Callable(self, "_on_lobby_joined"))
	#Steam.connect("lobby_chat_update", Callable(self, "_on_data_update"))

	Steam.lobby_match_list.connect(show_lobby_list)
	
	_open_lobby_list()


##################### LOBBY INFORMATIONS #####################
func _open_lobby_list() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("game", "10", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


func search_room_code_in_lobby_list(lobbies) -> void:

	for lib in lobbies:
		var this_room_code: String = Steam.getLobbyData(lib, "room_code")
		if this_room_code != "":
			if this_room_code == GameState.room_code:
				GameState.lobby_id = lib
				#await get_tree().create_timer(0.5).timeout
				Console.log("SALA ENCONTRADA!")
				Console.log("[Entrando no Lobby...]")
				Console.log("Entrando no Lobby ID: " + str(GameState.lobby_id))
				Steam.joinLobby(GameState.lobby_id)
				return
		
	Console.log("SALA NÃO ENCONTRADA!")


func show_lobby_list(lobbies) -> void:

	for lb in lobbies:
		var this_lobby_name: String = Steam.getLobbyData(lb, "name")
		var this_room_code: String = Steam.getLobbyData(lb, "room_code")
		var numMembers: int = Steam.getNumLobbyMembers(lb)
		
		Console.log(str(lb) + " " + this_room_code +" { "+this_lobby_name+" } " + ": " + str(numMembers) +" membros")


##################### SINAIS LOBBY #####################

#Sinal Criação do Lobby
func _on_lobby_created(success, this_lobby_id) -> void:
	if not success:
		Console.log("[color=red] Erro ao criar o Lobby!")
		return

	GameState.lobby_id = this_lobby_id
	#Mudar o nome do Lobby
	Steam.setLobbyData(GameState.lobby_id, "name", "Sabryna my Love, my Life")
	Steam.setLobbyData(GameState.lobby_id, "game", "10")
	GameState.room_code = code_room_generator()
	
	Steam.setLobbyData(GameState.lobby_id, "room_code", GameState.room_code)
	GameState.lobby_name = Steam.getLobbyData(GameState.lobby_id, "name")
	Console.log("Lobby Nome e ID: " + GameState.lobby_name + " " + str(GameState.lobby_id))

	#Criando o servidor [HOST]
	var peer: MultiplayerPeer = SteamMultiplayerPeer.new()
	peer.host_with_lobby(GameState.lobby_id)
	multiplayer.multiplayer_peer = peer
	GameState.peer_id = multiplayer.get_unique_id()
	GameState.is_host = true

	GameState.add_player_in_lobby(multiplayer.get_unique_id(), PlayerData.get_steam_id(), PlayerData.get_steam_name(), true)
	#Emitir sinal Lobby criado!
	emit_signal("lobby_createdd", GameState.room_code)

#Sinal Entrou no Lobby
func _on_lobby_joined(this_lobby_id, _permissions, _locked, _response) -> void:
	Console.log(PlayerData.get_steam_name() + " entrou no Lobby")
	
	#Se for o HOST não cria mais peer para ele
	if GameState.is_host:
		Console.log(str(Steam.getNumLobbyMembers(GameState.lobby_id)))
		return
	else:
		GameState.lobby_id = this_lobby_id
		GameState.lobby_name = Steam.getLobbyData(GameState.lobby_id, "name")
		
	#Criando Peer Cliente e se concetando ao Host pelo Lobby
	var peer: MultiplayerPeer = SteamMultiplayerPeer.new()
	peer.connect_to_lobby(GameState.lobby_id)
	multiplayer.multiplayer_peer = peer
	GameState.peer_id = multiplayer.get_unique_id()

	emit_signal("lobby_joinedd")

#Sinal Lobby Update (Quando Alguém entra ou sai do Lobby) 
#WARNING: ESSA FUNÇÃO NÃO É MAIS USADA!


##################### FUNCTIONS #####################
	
#Create Lobby
func create_lobby(max_players := 6) -> void:
	Console.log("[Criando Lobby...]")
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, max_players)

#Join Lobby
func join_lobby(this_join_room_code) -> void:

	Steam.lobby_match_list.connect(search_room_code_in_lobby_list)
	Steam.lobby_match_list.disconnect(show_lobby_list)

	Console.log(GameState.room_code)
	GameState.room_code = this_join_room_code
	Console.log(GameState.room_code)

	_open_lobby_list()
	#Vamos ter que procurar pelo lobby que tenha o mesmo código enviado!

#Verify Friends -> Imprimir a Lista de Amigos
func verifiy_friends() -> void:
	Console.log("[color=green] " + str(Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)) + " amigos encontrados!")
	Console.log("My name is " + PlayerData.get_steam_name())
	Console.log("Amigos:")
	
	for i in range(0, Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)):
		var steam_id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var friend_name: String = Steam.getFriendPersonaName(steam_id)
		Console.log(friend_name)

#Gerador Aleatório para os Códigos das Salas
func code_room_generator(length_code: int = 6) -> String:

	var this_room_code: String = ""

	var chars: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	for i in range(length_code):
		var index_random: int = randi()%36
		this_room_code += chars[index_random]
	
	return this_room_code
