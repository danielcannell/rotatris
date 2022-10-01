extends Node2D


func _ready():
    $Playfield.connect("score_changed", self, "on_score_changed")


func on_score_changed(value: int):
    $UI/ScoreLabel.text = "Score: " + str(value)
