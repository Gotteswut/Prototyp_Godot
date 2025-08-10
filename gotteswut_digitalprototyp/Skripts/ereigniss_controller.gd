extends Node2D 

#stroage for all card inforamation 
var events ={}
#var's
var video_player
var text_container 
var last_frame_texture
var img_path
var font_path = "res://Font/Chelsea_Market/ChelseaMarket-Regular.ttf"
var pressedButton

func _ready():
	load_and_init()
	randomize()
	incoming_signal()#nur zum schnellen testen drin aktuell 
	var start_event = get_node("..")
	start_event.connect("character_moved_add_card_event", Callable(self, "incoming_signal"))

#load JSON 
func load_and_init():
	#read JSON
	var file = FileAccess.open("res://JSON/sumpf.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		events = JSON.parse_string(content)
		
	#fill var's
	video_player = get_node("Container/VideoStreamPlayer")
	text_container = get_node("VBoxContainer")
	last_frame_texture = get_node("Container/Last_Frame_IMG")
	
	var viewport_size = get_viewport_rect().size
	text_container.position = viewport_size / 2 - text_container.size / 2
func incoming_signal():
	get_node("../").input_enabled = false
	#get card
	var card_number = randi()%events.size()+1
	var selected_card = events["1"]#events[str(card_number)]
	#setup last frame IMG
	img_path = "res://Assets/Card_animations" + selected_card.get("img_file")
	var texture = load(img_path) as Texture2D
	last_frame_texture.texture = texture
	last_frame_texture.visible = false
	#start building card
	if(selected_card["type"]=="fixed"): 
		fixed_event(selected_card)
	elif(selected_card["type"]=="choice"): 
		choise_event(selected_card)

#fixed event 
func fixed_event(selected_card):
	build_label(text_container, 32, font_path, "card_title", selected_card, "title")
	build_label(text_container, 16, font_path, "card_description", selected_card, "description")
	build_label(text_container, 16, font_path, "card_effect", selected_card, "effect")
	build_button(text_container, "confirm", "Bestätigen", 22, font_path, false)
	
	var confirm_button
	confirm_button = text_container.get_node("confirm")
	confirm_button.pressed.connect(func(): on_confirm_pressed(confirm_button))

	# Video starten
	var video_path = "res://Assets/Card_animations" + selected_card.get("animation_file")
	var video_stream = load(video_path)
	video_player.stream = video_stream
	video_player.play()
	video_player.finished.connect(func():
		on_video_finished(1)
	)
#choise event 
func choise_event(selected_card):
	build_label(text_container, 32, font_path, "label_title", selected_card, "title")
	build_label(text_container, 16, font_path, "card_description", selected_card, "description")
	
	var option_wrapper = build_HBox(text_container, "option_wrapper")
	var option_1 = build_VBox(option_wrapper, "option1")
	var option_2 = build_VBox(option_wrapper, "option2")
	
	build_label(option_1, 16, font_path, "yes", null, "Ja")
	build_label(option_2, 16, font_path, "no", null, "Nein")
	
	var option_1_innerHBox = build_HBox(option_1, "option1_innerHBox")
	var option_2_innerHBox = build_HBox(option_2, "option2_innerHBox")

	if selected_card["options"]["1"].has("random_outcomes"):
		var random_outcomes = selected_card["options"]["1"]["random_outcomes"]
		for number in random_outcomes.size(): 
			var text =  "option_1_inner_VBox_" + str(number)
			var outcome = build_VBox(option_1_innerHBox, text)

			var json_content = random_outcomes[number]["text"]
			text = "text_variante_1_" + str(number)
			build_label(outcome, 16, font_path, text, null, json_content)

			json_content = random_outcomes[number]["effects"]
			text = "effect__variante_1_" + str(number)
			build_label(outcome, 16, font_path, text, null, json_content)
	else: 
		var outcome = build_VBox(option_1_innerHBox, "option_1_inner_VBox")
		var json_content = selected_card["options"]["1"]["text"]
		build_label(outcome, 16, font_path,"text_1", null, json_content)
		json_content = selected_card["options"]["1"]["effects"]
		build_label(outcome, 16, font_path,"effect_1", null, json_content)
		
	

	if selected_card["options"]["2"].has("random_outcomes"):
		var random_outcomes = selected_card["options"]["2"]["random_outcomes"]
		for number in random_outcomes.size(): 
			var text =  "option_2_inner_VBox_" + str(number)
			var outcome = build_VBox(option_2_innerHBox, text)

			var json_content = random_outcomes[number]["text"]
			text = "text_variante_2_" + str(number)
			build_label(outcome, 16, font_path, text, null, json_content)

			json_content = random_outcomes[number]["effects"]
			text = "effect__variante_2_" + str(number)
			build_label(outcome, 16, font_path, text, null, json_content)
		
	else: 
		var outcome = build_VBox(option_2_innerHBox, "option_2_inner_VBox")
		var json_content = selected_card["options"]["2"]["text"]
		build_label(outcome, 16, font_path,"text_2", null, json_content)
		json_content = selected_card["options"]["2"]["effects"]
		build_label(outcome, 16, font_path,"effect_2", null, json_content)
	
	#Button 1
	build_button(option_1, "confirm1", "Bestätigen", 22, font_path, false)
	var confirm_button_option1
	confirm_button_option1 = option_1.get_node("confirm1")
	confirm_button_option1.pressed.connect(func(): on_confirm_pressed(confirm_button_option1))
	#Button 2
	build_button(option_2, "confirm2", "Bestätigen", 22, font_path, false)
	var confirm_button_option2
	confirm_button_option2 = option_2.get_node("confirm2")
	confirm_button_option2.pressed.connect(func(): on_confirm_pressed(confirm_button_option2))

	
	# video start
	var video_path = "res://Assets/Card_animations" + selected_card.get("animation_file")
	var video_stream = load(video_path)
	video_player.stream = video_stream
	video_player.play()
	video_player.finished.connect(func():
		on_video_finished(2)
	)

func on_video_finished(button_count):
	video_player.visible = false
	last_frame_texture.visible = true
	
	if button_count == 1: 
		var confirm_button = text_container.find_child("confirm", true, false)
		confirm_button.visible = true
		confirm_button.grab_focus()
	else: 
		var confirm_button_option1 = text_container.find_child("confirm1", true, false)
		confirm_button_option1.visible = true
		confirm_button_option1.grab_focus()
		var confirm_button_option2 = text_container.find_child("confirm2", true, false)
		confirm_button_option2.visible = true
		confirm_button_option2.grab_focus()

func on_confirm_pressed(thebutton):
	var button = thebutton
	last_frame_texture.visible = false
	video_player.visible = true
	
	# Eingabe in Skript 1 wieder aktivieren
	button.release_focus()
	get_node("../").input_enabled = true

	# Clean-up UI
	for child in text_container.get_children():
		text_container.remove_child(child)
		child.queue_free()

#build
func build_label(container,font_size, font_path, label_name, key_objket, key := "" ):
	var label = Label.new()
	label.name = label_name
	if key_objket == null:
		label.text = key
	else: 
		label.text = key_objket[key]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	#font and font size
	var font = load(font_path) as FontFile
	var theme = Theme.new()
	theme.set_font("font", "Label", font)
	theme.set_font_size("font_size", "Label", font_size)
	label.theme = theme

	container.add_child(label)
func build_button(container, button_name, text, font_size, font_path, visibility ): 
	var button = Button.new()
	button.name = button_name
	button.text = text
	
	#font and font size
	var font = load(font_path) as FontFile
	var theme = Theme.new()
	theme.set_font("font", "Label", font)
	theme.set_font_size("font_size", "Label", font_size)
	button.theme = theme
	
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	button.visible = visibility
	
	container.add_child(button)
func build_VBox(container, VBox_name): 
	var box = VBoxContainer.new()
	box.name = VBox_name
	
	container.add_child(box)
	return box
func build_HBox(container, HBox_name): 
	var box = HBoxContainer.new()
	box.name = HBox_name
	
	container.add_child(box)
	return box
