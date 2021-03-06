extends 'res://weapons/weapon.gd'

onready var main = get_node('/root/main/')
var plant_class = preload('res://plants/plant.tscn')
var mana_cost = 20.0
var first_neighbor

func _ready():
	MAX_TRAVEL_TIME = 0.25
	MAX_SPEED = 600.0
	._ready()

func travelEnded():
	var plant = plant_class.instance()
	# main.addNode(first_neighbor, plant)
	# main.addNode(plant, first_neighbor)
	plant.position = position
	get_node('/root/main/').add_child(plant)
	queue_free()

func _physics_process(delta):
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)

	if collision:
		travelEnded()
