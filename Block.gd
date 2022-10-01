extends Node2D

const BLOCK_SIZE: int = 16

var shape: int
var squares: Array; # of (int, int)

func _init(_shape: int):
    self.shape = _shape
    self.squares = []

    if _shape == 0:
        self.squares = [[0,0], [0,1], [0,2], [0,3]]
    elif _shape == 1:
        self.squares = [[0,0], [0,1], [1,1], [2,1]]
    elif _shape == 2:
        self.squares = [[0,0], [0,1], [1,1], [1,0]]
    else:
        assert(false)


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

        var child := Sprite.new()
        child.position = Vector2(x, y) * BLOCK_SIZE
        # TODO child texture and color

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
