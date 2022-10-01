extends Node2D


var blocks: Array


# Called when the node enters the scene tree for the first time.
func _ready():
    self.blocks = []

    for x in range(3):
        var block: Node2D = Block.new(x)
        block.position = Vector2(50 + x * 100, 50)
        add_child(block)
        self.blocks.append(block)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
