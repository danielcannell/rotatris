extends Node2D


var Block: PackedScene = preload("res://Block.tscn")
var blocks: Array


# Called when the node enters the scene tree for the first time.
func _ready():
    self.blocks = []

    for x in range(3):
        var block: Node2D = Block.instance(x)
        add_child(block)
        self.blocks.append(block)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
