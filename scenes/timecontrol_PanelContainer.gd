extends PanelContainer

@onready var play_timecontrol_texture_button : TextureButton = find_child("play_timecontrol_TextureButton") #$MarginContainer2/VBoxContainer/time_control_buttons/play_timecontrol_TextureButton
@onready var pause_timecontrol_texture_button : TextureButton = find_child("pause_timecontrol_TextureButton") #$MarginContainer2/VBoxContainer/time_control_buttons/pause_timecontrol_TextureButton

var pressed_color := Color(0.99999982118607, 0.21450683474541, 0.47272181510925)


# I want to froward input and unhandled_input to nodes that may be inside the paused tree
# nodes inside a paused tree, even if they're set to Node.
var forward_input := false
@export var forwardees_array : Array[NodePath]
var forwardees_nodes : Array

func _ready():
	play_timecontrol_texture_button.set_modulate( pressed_color )

	for n in forwardees_array:
		forwardees_nodes.append( get_node( n ) )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if forward_input:
		for n in forwardees_nodes:
			n._unhandled_input( event )


func _input(event):
	if forward_input:
		for n in forwardees_nodes:
			n._input( event )


func _on_play_timecontrol_texture_button_pressed():
	print("play pressed %s"%play_timecontrol_texture_button.button_pressed)
	play_timecontrol_texture_button.set_modulate(pressed_color)
	pause_timecontrol_texture_button.set_pressed_no_signal(false)
	pause_timecontrol_texture_button.set_modulate( Color.WHITE )
	forward_input = false
	get_tree().paused = false


func _on_pause_timecontrol_texture_button_pressed():
	print("pause pressed %s"%pause_timecontrol_texture_button.button_pressed)
	play_timecontrol_texture_button.set_pressed_no_signal(false)
	play_timecontrol_texture_button.set_modulate( Color.WHITE )
	pause_timecontrol_texture_button.set_modulate( pressed_color )
	forward_input = true
	get_tree().paused = true

