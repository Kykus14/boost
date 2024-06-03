extends RigidBody3D

#audio
@onready var explosion_audio: AudioStreamPlayer = $explosion_audio
@onready var success_audio: AudioStreamPlayer = $success_audio
@onready var rocket_audio: AudioStreamPlayer3D = $rocket_audio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_r: GPUParticles3D = $BoosterParticlesR
@onready var booster_particles_l: GPUParticles3D = $BoosterParticlesL

## How much vertical force to apply when moving.
@export_range(750.0, 3000.0) var thrust: float = 1000.0
@export var torque: float = 100.0
var is_transitioning: bool = false

# Movement
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque * delta))
		booster_particles_r.emitting = true
	else:
		booster_particles_r.emitting = false
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque * delta))
		booster_particles_l.emitting = true
	else:
		booster_particles_l.emitting = false	
		
# Collisions
func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Crash" in body.get_groups():
			crash_sequence()
		
func crash_sequence() -> void:
	print("OJ")
	explosion_audio.play()
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
func complete_level(next_level_file: String) -> void:
	print("YOU WIN")
	success_audio.play()
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
	)
