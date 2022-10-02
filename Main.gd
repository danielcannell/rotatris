extends Node2D


func _ready():
    var _dontcare := $Playfield.connect("score_changed", self, "on_score_changed")
    on_score_changed($Playfield.score)


func on_score_changed(value: int):
    $UI/ScoreLabel.text = "Score: " + str(value)
