extends MultiplayerSpawner

@export var player_scene: PackedScene

func _ready() -> void:
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

func _on_peer_connected(id) -> void:
	spawn(id)

func _spawn_player(peer_id) -> CharacterBody2D:
	var p = player_scene.instantiate()
	p.name = "%s" % peer_id
	p.set_multiplayer_authority(peer_id)
	return p
