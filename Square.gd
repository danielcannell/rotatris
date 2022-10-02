extends Node2D
onready var sprite = $Sprite

var _is_dissolving = false
var burn_duration = 4.0;
var _time = 0.0;


func _init():
    self.modulate = Globals.BACKGROUND_GREY


func set_color(color: int):
    self.modulate = Globals.ColorLookup[color]

func set_frame(frame: int):
    $Sprite.frame = frame


func dissolve():
    _is_dissolving = true


func _process(delta):
    if _is_dissolving:
        _time += delta;
        sprite.material.set_shader_param("burn_position", ((_time / burn_duration) * 2) - 1 )
        if _time > burn_duration:
            _is_dissolving = false
            queue_free()
