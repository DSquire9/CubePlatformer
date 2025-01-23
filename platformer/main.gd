extends Node

@export var next_level = "res://level_1.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DeathScreen.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $DeathScreen.visible:
		get_tree().reload_current_scene()


func _on_player_hit() -> void:
	$DeathScreen.show()


func _on_player_clear() -> void:
	get_tree().change_scene_to_file(next_level)
