class_name Block
extends Node2D

const BLOCK_SIZE: int = 32

var squares: Array; # of (int, int)
var color: int


# shape is Globals.DefaultShapes
func from_shape(shape: int):
    self.color = randi() % Globals.ShapeColors.size()

    if shape == Globals.DefaultShapes.I:
        self.squares = [[0,0], [0,1], [0,2], [0,3]]
    elif shape == Globals.DefaultShapes.J:
        self.squares = [[0,0], [0,1], [1,1], [2,1]]
    elif shape == Globals.DefaultShapes.L:
        self.squares = [[0,0], [0,1], [1,0], [2,0]]
    elif shape == Globals.DefaultShapes.O:
        self.squares = [[0,0], [0,1], [1,1], [1,0]]
    elif shape == Globals.DefaultShapes.Z:
        self.squares = [[0,0], [0,1], [1,1], [1,2]]
    elif shape == Globals.DefaultShapes.S:
        self.squares = [[1,0], [1,1], [0,1], [0,2]]
    elif shape == Globals.DefaultShapes.T:
        self.squares = [[0,0], [1,0], [1,1], [2,0]]
    else:
        assert(false)


func random():
    self.from_shape(randi() % Globals.DefaultShapes.size())


func _ready():
    update_shape()


func update_shape():
    for x in get_children():
        if x is Sprite:
            remove_child(x)
            x.queue_free()

    for pos in self.squares:
        var x: int = pos[0]
        var y: int = pos[1]

        var child := AnimatedSprite.new()
        child.position = Vector2(x, y) * BLOCK_SIZE
        child.frames = load("res://Art/blocks.tres")
        child.animation = "default"
        child.frame = self.color % child.frames.get_frame_count(child.animation)
        add_child(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
