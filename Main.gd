extends Node2D

var stime;
const tm_base = 0.05;
const tm_mul = 0.1;
var current_Tm = 0;



func _ready():
    var _dontcare := $Playfield.connect("score_changed", self, "on_score_changed")
    on_score_changed($Playfield.score)


func on_score_changed(value: int):
    $UI/ScoreLabel.text = "Score: " + str(value)

    shader_step_multi = (min(value, 200) / 200.0) * 2.0

var shader_time = 0
var shader_step_multi_base = 0.001
var shader_step_multi = 0.0

func _process(delta):
    shader_time += delta * (shader_step_multi_base + shader_step_multi)
    $Background.material.set_shader_param("stime", shader_time)
