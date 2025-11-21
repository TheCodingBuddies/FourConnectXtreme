extends CharacterBody2D
class_name Bomb
@onready var animation: AnimatedSprite2D = $Sprite2D
@onready var bomb_explode = $bomb_explode
@onready var bomb_falling = $bomb_falling
@onready var bomb_dropped = $bomb_dropped

var boom_in: int = 4
var boom_in_round: int = -1
var final_destination_row: int
var final_destination_col: int
var moving: bool = true
var drop_speed: int = 800

signal detonate(row, col)
signal dropped()

func _ready():
	GameManager.setState(GameManager.GameState.ITEM_FALLING)
	bomb_falling.play()

func _set_drop_speed() -> float:
	return drop_speed * GameManager.speed
		
func _physics_process(delta: float) -> void:
	velocity.y = _set_drop_speed()
	_set_texture()
	if moving:
		var collision := move_and_collide(velocity * delta,false,0.0,false)
		if collision:
			position.y -= collision.get_depth()
			moving = false
			fade_out_drop(bomb_falling, 0.3) # Fadet in 2 Sekunden aus
			dropped.emit()
			bomb_dropped.play(0.03)
	

func _set_texture():
	if boom_in == 3:
		animation.play("start")
	if boom_in == 2:
		animation.play("mid")
	elif boom_in == 1:
		animation.play("end")
	else:
		pass 

func set_boom_info(current_turn):
	boom_in_round = current_turn + boom_in

func tick() -> bool:
	boom_in -= 1
	if boom_in <= 0:
		_detonate()
		return true
	return false
		
func set_final_destination(row: int, col: int):
	final_destination_row = row
	final_destination_col = col

func _detonate():
	detonate.emit(final_destination_row, final_destination_col)
	animation.play("explosion")
	bomb_explode.play()

func _on_sprite_2d_animation_finished() -> void:
	self.queue_free()
	
func fade_out_drop(player: AudioStreamPlayer, duration: float = 1.0):
	var tween := get_tree().create_tween()
	tween.tween_property(player, "volume_db", -40, duration)
	tween.finished.connect(func():
		if is_instance_valid(player):
			player.stop()
			player.volume_db = -4
	)
