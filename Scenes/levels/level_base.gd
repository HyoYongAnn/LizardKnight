extends Node2D

func _ready():
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	set_camera_limits()
	spawn_items()
	
	$Player.life_changed.connect($CanvasLayer/HUD.update_life)
	score_changed.connect($CanvasLayer/HUD.update_score)


func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.tile_set.tile_size
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x
	
signal score_changed

var item_scene = load("res://Scenes/item.tscn")
var door_scene = load("res://Scenes/door.tscn")

var score = 0: set = set_score

func spawn_items():
	var item_cells = $Items.get_used_cells(0)
	for cell in item_cells:
		var data = $Items.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		if type == "door":
			var door = door_scene.instantiate()
			add_child(door)
			door.position = $Items.map_to_local(cell)
			door.body_entered.connect(_on_door_entered)
		else:
			var item = item_scene.instantiate()
			add_child(item)
			item.init(type, $Items.map_to_local(cell))
			item.picked_up.connect(self._on_item_picked_up)

func _on_item_picked_up():
	score += 1

func set_score(value):
	score = value
	score_changed.emit(score)


func _on_player_died():
	GameState.restart()
	
func _on_door_entered(body):
	GameState.next_level()
