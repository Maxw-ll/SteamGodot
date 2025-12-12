extends MultiplayerSpawner

@export var player_scene: PackedScene

func _ready():
	# Cena spawnável automática
	add_spawnable_scene(player_scene.resource_path)

	# Função customizada de spawn
	spawn_function = _spawn_player

	# HOST SPAWN FIRST PLAYER
	if multiplayer.is_server():
		Console.log("HOST: spawning self " + str(multiplayer.get_unique_id()))
		spawn(multiplayer.get_unique_id())
	# When a client connects
		multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(id):
	Console.log("HOST: spawning new client " + str(id))
	spawn(id)

func _spawn_player(peer_id):
	var p = player_scene.instantiate()
	p.name = "%s" % peer_id
	p.set_multiplayer_authority(peer_id)
	return p

func _on_peer_disconnected(peer_id):
	print("Removendo player do peer ", peer_id)

	var player_node = get_node_or_null("Player_%s" % peer_id)
	if player_node:
		player_node.queue_free()
