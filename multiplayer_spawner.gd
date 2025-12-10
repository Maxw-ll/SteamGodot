extends MultiplayerSpawner

@export var playerScene: PackedScene
var players = {}

func _ready():
	print("Spawner ready! Peer = ", multiplayer.multiplayer_peer)
	spawn_function = _spawn_player


func _spawn_player(peer_id):
	var p = playerScene.instantiate()
	p.name = str(peer_id)
	p.set_multiplayer_authority(peer_id)
	add_child(p)
	players[peer_id] = p
	return p
