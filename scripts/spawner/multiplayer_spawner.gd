extends MultiplayerSpawner

@export var player_scene: PackedScene

func _ready() -> void:
	# Cena spawnável automática
	add_spawnable_scene(player_scene.resource_path)

	# Função customizada de spawn
	spawn_function = _spawn_player

	# HOST SPAWN FIRST PLAYER
	if Multiplayer.is_host:
		Console.log("HOST: spawning self " + str(multiplayer.get_unique_id()))
		spawn(multiplayer.get_unique_id())
	# When a client connects
		if multiplayer.get_peers().is_empty():
			multiplayer.peer_connected.connect(_on_peer_connected)
		else:
			load_to_lobby()

func load_to_lobby():
	for pid in multiplayer.get_peers():
			Console.log(str(multiplayer.get_peers()))
			spawn(pid)



func _on_peer_connected(id) -> void:
	spawn(id)

func _spawn_player(peer_id) -> CharacterBody2D:
	
	var p = player_scene.instantiate()
	p.name = "%s" % peer_id
	p.set_multiplayer_authority(peer_id)
	return p
