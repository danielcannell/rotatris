extends Node2D


func _init():
    self.modulate = Globals.BACKGROUND_GREY


func set_color(color: int):
    self.modulate = Globals.ColorLookup[color]
