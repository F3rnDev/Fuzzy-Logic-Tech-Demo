extends Control

func _on_rest_button_down():
	get_tree().reload_current_scene()


func _on_exit_button_down():
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
