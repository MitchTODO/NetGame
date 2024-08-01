extends Node2D

var players
@onready var playerCount = $RichTextLabel

@export var players_container: Node2D
@export var players_scene: PackedScene

var peer = ENetMultiplayerPeer.new()

var port = 5454
var max_peers = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Custom Server")
	
	peer.create_server(port, max_peers)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# can use "/root/ServerCustom" or self.get_path()
	multiplayer.multiplayer_peer = peer
	var id = multiplayer.get_unique_id()
	spawn_player(id)

func _on_peer_connected(peer_id):
	#players = peer_id
	print("Custom Server _on_peer_connected, peer_id: {0}".format([peer_id]))
	#await get_tree().create_timer(1).timeout
	spawn_player(peer_id)
	
func spawn_player(id):
	var player_scene = preload("res://Player.tscn")
	# create player instance
	var player_instance = player_scene.instantiate()
	player_instance.name = str(id)
	player_instance.set_multiplayer_authority(id)
	
	$Players.add_child(player_instance)
	print("Spawn Player ", str(id))

func _on_peer_disconnected(peer_id):
	print("Custom Server _on_peer_disconnected, peer_id: {0}".format([peer_id]))
	for child in $Players.get_children():
		if child.name == str(peer_id):
			child.queue_free()
		
	
@rpc()
func rpc_server_custom():
	var peer_id = multiplayer.get_remote_sender_id() # even custom uses default "multiplayer" calls
	print("rpc_server_custom, peer_id: {0}".format([peer_id]))
	rpc_server_custom_response(peer_id)

@rpc("any_peer")
func call_me():
	print("Called")

@rpc 
func rpc_server_custom_response(peer_id, test_var1 : String = "party like it's", test_var2 : int = 1999):
	print("rpc_server_custom_response to peer_id : {0}".format([peer_id]))
	rpc_server_custom_response.rpc_id(peer_id, test_var1, test_var2)
	
