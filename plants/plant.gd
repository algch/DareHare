extends StaticBody2D

onready var main = get_node('/root/main/')
onready var projectile_class = preload('res://weapons/projectile/projectile.tscn')
onready var player = get_node('/root/main/player')
var targets = {}
var WEAPON_RADIUS = 57
onready var attack_timer = get_node('attack_timer')
enum STATE {
	attacking,
	idle,
}
var current_state = STATE.idle
var DEFAULT_POWER = 0.5
var health = 3.0
var default_font = DynamicFont.new()
var parent_plant = null
var child_plants = {}

func addPlantChild(plant):
	child_plants[plant.get_instance_id()] = plant

func removePlantChild(plant):
	child_plants.erase(plant.get_instance_id())

func _on_score_timer_timeout():
	main.score += 1
	$score_timer.start()

func receiveDamage(damage):
	health -= damage

func destroy():
	if player.current_plant == self:
		if parent_plant:
			player.setCurrentPlant(parent_plant)
		else:
			main.gameOver()
	if parent_plant:
		parent_plant.removePlantChild(self)
	queue_free()

func healthLoop():
	if health <= 0:
		destroy()

func handleWeaponCollision(weapon):
	health -= weapon.damage
	weapon.queue_free()
	
func attack(power):
	var target = targets[targets.keys()[randi() % targets.size()]]
	if target.is_queued_for_deletion():
		targets.erase(target.get_instance_id())
		return

	var projectile = projectile_class.instance()
	var direction = (target.position - position).normalized()
	var offset = direction * WEAPON_RADIUS

	projectile.position = position + offset
	projectile.direction = direction

	projectile.power = power

	get_node('/root/main/').add_child(projectile)

func _on_Area2D_body_entered(body):
	if body.is_in_group('enemies'):
		targets[body.get_instance_id()] = body
		if current_state != STATE.attacking:
			attack_timer.start()
			current_state = STATE.attacking

func _on_Area2D_body_exited(body):
	if body.is_in_group('enemies'):
		targets.erase(body.get_instance_id())
		if targets.empty():
			attack_timer.stop()
			current_state = STATE.idle

func _on_attack_timer_timeout():
	attack(0.5)
	attack_timer.start()

func _on_teleport_released():
	if player.current_plant == self:
		return
	player.setCurrentPlant(self)

func _ready():
	default_font.font_data = load('res://fonts/default-font.ttf')
	default_font.size = 22

func _physics_process(delta):
	healthLoop()
