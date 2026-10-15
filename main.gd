extends Control
# Your fork's own game scene (fork.scene). With "base": "none" nothing of Pax Universe's world runs:
# this scene is the whole game. It still has the platform: the AI (Pax.ask_ai), saves in the fork's profile
# (Pax.platform.data_dir()), translations, the F8 console, F9 reports, the MCP bridge for agents.

const SAVE := "progress.json"

var story: Label
var turns := 0


func _ready() -> void:
	turns = int(_load().get("turns", 0))
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 10)
	add_child(box)
	story = Label.new()
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.size_flags_vertical = Control.SIZE_EXPAND_FILL
	story.text = "Turn %d. Press «Next» and the AI continues the story." % turns
	box.add_child(story)
	var next := Button.new()
	next.text = "Next"
	next.pressed.connect(_next)
	box.add_child(next)
	var back := Button.new()
	back.text = "Back to the launcher"
	back.pressed.connect(func(): get_tree().change_scene_to_file(str(Pax.platform.fork_launcher())))
	box.add_child(back)


func _next() -> void:
	turns += 1
	_save({"turns": turns})
	var asked: bool = Pax.ask_ai("story", "Continue a short sci-fi story, turn %d, two sentences." % turns, {},
		func(answer: Dictionary): story.text = "Turn %d.\n%s" % [turns, str(answer.get("text", answer))])
	if not asked:
		story.text = "Turn %d. The AI is not set up: open AI settings in the launcher." % turns


func _path() -> String:
	return str(Pax.platform.data_dir()) + SAVE


func _load() -> Dictionary:
	var d = JSON.parse_string(FileAccess.get_file_as_string(_path())) if FileAccess.file_exists(_path()) else null
	return d if d is Dictionary else {}


func _save(d: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(str(Pax.platform.data_dir()))
	var f := FileAccess.open(_path(), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d))
