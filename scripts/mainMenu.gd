extends Control

func _on_exit_button_down():
	get_tree().quit()

func _on_demo_01_button_down():
	get_tree().change_scene_to_file("res://scenes/tech-demos/demo_1.tscn")

func _on_demo_02_button_down():
	get_tree().change_scene_to_file("res://scenes/tech-demos/demo_2.tscn")

func _on_demo_03_button_down():
	get_tree().change_scene_to_file("res://scenes/tech-demos/demo_3.tscn")
