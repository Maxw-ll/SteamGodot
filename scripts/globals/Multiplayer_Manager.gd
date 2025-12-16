extends Node


#
var is_host: bool = false
var lobby_id: int
var lobby_name: String
var peer_id: int
var room_code: String
var room_code_length = 6
var join_room_code: String
var players_in_lobby: Array

signal lobby_createdd(lobby_code: String)
signal lobby_joinedd
signal lobby_founded

##################### INICIALIZAÇÃO #####################
func _ready() -> void:
	randomize()
	Network.connect("steam_on", Callable(self, "_on_steam_connect"))


#Chamado após o acesso à Steam funcionar
func _on_steam_connect() -> void:
	Steam.connect("lobby_created", Callable(self, "_on_lobby_created"))
	Steam.connect("lobby_joined", Callable(self, "_on_lobby_joined"))
	Steam.connect("lobby_chat_update", Callable(self, "_on_data_update"))

	lobby_founded.connect(join_lobby_founded)
	Steam.lobby_match_list.connect(show_lobby_list)
	
	_open_lobby_list()

##################### LOBBY INFORMATIONS #####################
func _open_lobby_list() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func search_room_code_in_lobby_list(lobbies) -> void:

	for lb in lobbies:
		var this_room_code: String = Steam.getLobbyData(lb, "room_code")
		if this_room_code != "":
			if this_room_code == join_room_code:
				lobby_id = lb
				await get_tree().create_timer(0.5).timeout
				emit_signal("lobby_founded")
				Console.log("SALA ENCONTRADA!")
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

	lobby_id = this_lobby_id
	#Mudar o nome do Lobby
	Steam.setLobbyData(lobby_id, "name", "Sabryna my Love, my Life")
	code_room_generator(room_code_length)
	Steam.setLobbyData(lobby_id, "room_code", room_code)
	lobby_name = Steam.getLobbyData(lobby_id, "name")
	Console.log("Lobby Nome e ID: " + lobby_name + " " + str(lobby_id))

	#Criando o servidor [HOST]
	var peer: MultiplayerPeer = SteamMultiplayerPeer.new()
	peer.host_with_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer
	peer_id = multiplayer.get_unique_id()
	is_host = true

	
	#Emitir sinal Lobby criado!
	emit_signal("lobby_createdd", room_code)

#Sinal Entrou no Lobby
func _on_lobby_joined(this_lobby_id, _permissions, _locked, _response) -> void:
	Console.log(Network.steam_name + " entrou no Lobby")
	
	#Se for o HOST não cria mais peer para ele
	if is_host:
		Console.log(str(Steam.getNumLobbyMembers(lobby_id)))
		return
	else:
		lobby_id = this_lobby_id
		
	
	#Criando Peer Cliente e se concetando ao Host pelo Lobby
	var peer: MultiplayerPeer = SteamMultiplayerPeer.new()
	peer.connect_to_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer
	peer_id = multiplayer.get_unique_id()

	if is_host:
		players_in_lobby.append({"steam_id": Steam.getSteamID(), "name": Steam.getPersonaName()})

	emit_signal("lobby_joinedd")

#Sinal Lobby Update (Quando Alguém entra ou sai do Lobby)
func _on_data_update(_this_lobby_id: int, _changed_id: int, _making_change_id: int, _chat_state: int) -> void:
	Console.log("Players in Lobby : ")

	for i in range(Steam.getNumLobbyMembers(lobby_id)):
		var player_name: String = Steam.getFriendPersonaName(Steam.getLobbyMemberByIndex(lobby_id, i))
		Console.log(" - Player SteamID: " + player_name)
		var players_exist: bool = false
		var count_index: int = 0
		for p in players_in_lobby:
			if p["name"] == player_name:
				players_exist = true
				break
			count_index += 1

		if not players_exist:
			players_in_lobby.append({"steam_id": _changed_id, "nome": Steam.getFriendPersonaName(_changed_id)})
		else:
			players_in_lobby.pop_at(count_index)
		

	Console.log(str(players_in_lobby))
	rpc("update_player_container", players_in_lobby)


##################### FUNCTIONS  #####################
	
#Create Lobby
func create_lobby(max_players := 6) -> void:
	Console.log("[Criando Lobby...]")
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, max_players)

#Join Lobby
func join_lobby(this_lobby_room_code) -> void:

	Steam.lobby_match_list.connect(search_room_code_in_lobby_list)
	Steam.lobby_match_list.disconnect(show_lobby_list)

	Console.log(join_room_code)
	join_room_code = this_lobby_room_code
	Console.log(join_room_code)

	_open_lobby_list()
	#Vamos ter que procurar pelo lobby que tenha o mesmo código enviado!

func join_lobby_founded() -> void:
	Console.log("[Entrando no Lobby...]")
	Console.log("Entrando no Lobby ID: " + str(lobby_id))
	Steam.joinLobby(lobby_id)



#Verify Friends -> Imprimir a Lista de Amigos
func verifiy_friends() -> void:
	Console.log("[color=green] " + str(Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)) + " amigos encontrados!")
	var my_name: String = Steam.getPersonaName()
	Console.log("My name is " + my_name)
	Console.log("Amigos:")
	
	for i in range(0, Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)):
		var steam_id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var friend_name: String = Steam.getFriendPersonaName(steam_id)
		Console.log(friend_name)

#Gerador Aleatório para os Códigos das Salas
func code_room_generator(length_code: int) -> void:

	var this_room_code: String = ""

	var chars: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	for i in range(length_code):
		var index_random: int = randi()%36
		this_room_code += chars[index_random]
	
	room_code = this_room_code