extends Node2D
onready var sprite = $Sprite

var _is_dissolving = false
var burn_duration = 1.0;
var _time = 0.0;


func _init():
    self.modulate = Globals.BACKGROUND_GREY


func set_color(color: int):
    self.modulate = Globals.ColorLookup[color]

func set_frame(frame: int):
    $Sprite.frame = frame


func dissolve():
    # var cidx = randi() % Globals.Colors.size()
    # self.modulate = Globals.ColorLookup[cidx]
    self.sprite.material = sprite.material.duplicate()
    sprite.material.set_shader_param("burn_size", randf());
    sprite.material.set_shader_param("rand", Vector2(randf(), randf()));
    _is_dissolving = true


func set_coord(pos: Array):
    self.position = Globals.BLOCK_SIZE * Vector2(pos[0], pos[1])


func _process(delta):
    if _is_dissolving:
        _time += delta;
        sprite.material.set_shader_param("burn_position", _time / burn_duration)
        if _time > burn_duration:
            _is_dissolving = false
            queue_free()
