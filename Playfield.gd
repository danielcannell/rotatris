extends Node2D


signal score_changed


# All blocks currently in play
var blocks: Array

# Time since the last 1 square move
var time := 0.0

# Number of moves since the last gravity change
var gravity_counter := 0

# Current gravity vector
var gravity: Array = [0, 1]

# TODO: Should spawn when falling tetronimo lands
var time_until_spawn := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
    self.blocks = []
    var boundary = Boundary.new()
    add_child(boundary)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    self.time += delta

    if self.time > Globals.TIME_TO_MOVE_1_SQUARE:
        self.time = fmod(self.time, Globals.TIME_TO_MOVE_1_SQUARE)
        update_block_positions()

        self.gravity_counter += 1
        if self.gravity_counter >= Globals.MOVES_PER_GRAVITY_CHANGE:
            self.gravity_counter = 0
            self.rotate_gravity()

    self.time_until_spawn -= delta
    if self.time_until_spawn < 0.0:
        spawn_random_block()

        self.time_until_spawn = 5.0


# Update the grid coordinates of all blocks
func update_block_positions():
    var grid := {}
    var done := false

    for block in self.blocks:
        block.fill_grid(grid)
        block.moved = false

    while not done:
        done = true

        for block in self.blocks:
            if not block.moved and block.can_move(grid, self.gravity):
                block.move(grid, self.gravity)
                block.moved = true
                done = false


func rotate_gravity():
    self.gravity = [self.gravity[1], -self.gravity[0]]


func spawn_random_block():
    var block: Node2D = Block.new()
    block.random()
    block.coord = [-(Globals.GRID_HALF_WIDTH + 2) * gravity[0], -(Globals.GRID_HALF_WIDTH + 2) * gravity[1]]
    add_child(block)
    self.blocks.append(block)
    self.emit_signal("score_changed", self.blocks.size())
