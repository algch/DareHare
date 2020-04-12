extends 'res://weapons/weapon.gd'

# CREATE A BASE CLASS, INHERIT TO SOLO AND MULTIPLAYER MODES

onready var main = get_node('/root/mainArena/')
var plant_class = preload('res://plants/plant.tscn')
var mana_cost = 20.0
var first_neighbor

func getLocalPlayer():
	return get_node('/root/mainArena/' + str(get_tree().get_network_unique_id()))

func _ready():
	MAX_TRAVEL_TIME = 0.25
	MAX_SPEED = 600.0
	._ready()

func init(pos):
	position = pos

func abortSummon():
	print('colisionó, no se puede plantar')
	queue_free()

func healPlant(plant):
	plant.heal()
	plant.heal()

func handleCollision(collider):
	if collider.is_in_group('plants'):
		healPlant(collider)
	abortSummon()

func travelEnded():
	var player = getLocalPlayer()
	var plant = plant_class.instance()
	main.addNode(get_tree().get_network_unique_id(), first_neighbor, plant)
	main.addNode(get_tree().get_network_unique_id(), plant, first_neighbor)
	plant.position = position
	main.add_child(plant)
	player.mana -= mana_cost
	queue_free()

func _physics_process(delta):
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)

	if collision:
		handleCollision(collision.collider)
