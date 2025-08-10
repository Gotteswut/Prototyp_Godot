extends Node2D

#add signal for card event
signal character_moved_add_card_event
#input 
var input_enabled = true  


#T-shape
var hex_positions = {}
#[2]
#[3][1][0]
#[4]

# Nachbarn (Felder)
var neighbors = {
	0: [1],
	1: [2, 0, 4, 3],
	2: [1, 3],
	3: [2, 1, 4],
	4: [3, 1],
}
#var for iteration 
var neighbors_index = 0 

#char 
var character = {
	"id": 0,
	"pos": Vector2(), 
	"current_hex": 0, 
	"current_selceted_hex": 1000
}


func _ready():
	#init hex_positions
	hex_positions[0] = $Felder/Hexagon_ID0.position
	hex_positions[1] = $Felder/Hexagon_ID1.position
	hex_positions[2] = $Felder/Hexagon_ID2.position
	hex_positions[3] = $Felder/Hexagon_ID3.position
	hex_positions[4] = $Felder/Hexagon_ID4.position  
	
	#init character
	character.id="Player_1"
	character.pos= $Felder/Hexagon_ID0.position
	$Karakter/Character.position.x = character.pos.x
	var height = $Felder/Hexagon_ID0.texture.get_size().y
	$Karakter/Character.position.y = character.pos.y- (height/2)
	character.current_hex=0
	character.current_selected_hex = 1000

#user input
func _input(event):
	if not input_enabled:
		return 
		
	if Input.is_action_just_pressed("GoLeft"):
		cycle_neighbor(-1, character.current_hex)
	elif Input.is_action_just_pressed("GoRight"):
		cycle_neighbor(1, character.current_hex)
	elif Input.is_action_just_pressed("Confirm"):
		move_character_to_selected()



func cycle_neighbor(direction, current_hex):
	#correct the index depending on the array
	if neighbors_index >= neighbors[character.current_hex].size(): 
		neighbors_index = 0 
	else: 
		if neighbors_index + direction < 0: 
			neighbors_index = neighbors[character.current_hex].size()-1
		elif  neighbors_index + direction >= neighbors[character.current_hex].size(): 
			neighbors_index = 0 
		else: 
			neighbors_index = neighbors_index + direction
	
	#play animations for selceted hex
	var animation 
	if character.current_selected_hex == 1000: 
		character.current_selected_hex = neighbors[current_hex][neighbors_index]
		animation = get_node("Felder/Hexagon_ID" + str(character.current_selected_hex) + "/AnimationPlayer")
		animation.play("Selected_Hexagon")
		await(animation.animation_finished)
	else: 
		animation = get_node("Felder/Hexagon_ID" + str(character.current_selected_hex) + "/AnimationPlayer")
		animation.play("Selected_hexagon_revers")
		await(animation.animation_finished)
		character.last_selected_hex = character.current_selected_hex
		character.current_selected_hex = neighbors[current_hex][neighbors_index]
		animation = get_node("Felder/Hexagon_ID" + str(character.current_selected_hex) + "/AnimationPlayer")
		animation.play("Selected_Hexagon")
		await(animation.animation_finished)
  

func move_character_to_selected():
	if character.current_selected_hex == 1000:
		return 
	
	#revers aniamation 
	var animation = get_node("Felder/Hexagon_ID" + str(character.current_selected_hex) + "/AnimationPlayer")
	animation.play("Selected_hexagon_revers")
	await animation.animation_finished
	
	# fade out coulde 
	var cloud_node = get_node("Felder/Hexagon_ID" + str(character.current_selected_hex) + "/Cloud")
	if cloud_node.visible:
		var cloud_anim = cloud_node.get_node("AnimationPlayer")
		cloud_anim.play("fade_out_child")
		await cloud_anim.animation_finished
		cloud_node.visible = false

	#Goal position 
	character.current_hex = character.current_selected_hex
	character.pos = hex_positions[character.current_hex]
	var height = $Karakter/Character.texture.get_size().y
	var target_pos = character.pos - Vector2(0, height / 2)

	#mocement with tween 
	var tween := create_tween()
	tween.tween_property($Karakter/Character, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	#send signal 
	emit_signal("character_moved_add_card_event")
