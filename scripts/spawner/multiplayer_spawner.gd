extends MultiplayerSpawner

@export var player_scene: PackedScene

func _ready() -> void:
	# Cena spawnável automática
	add_spawnable_scene(player_scene.resource_path)

	# Função customizada de spawn
	spawn_function = _spawn_player

	# HOST SPAWN FIRST PLAYER
	if GameState.is_host:
	# When a client connects
		load_to_lobby()

func load_to_lobby():
	for p in GameState.players_in_lobby:
		spawn(p)


func _spawn_player(peer_id) -> CharacterBody2D:
	
	var p = player_scene.instantiate()
	p.name = "%s" % peer_id
	p.set_multiplayer_authority(peer_id)
	return p
