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

# The block current controlled by user input
var controlled_block : Block = null


# Called when the node enters the scene tree for the first time.
func _ready():
    self.blocks = []


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
            var step := self.gravity

            if block == self.controlled_block:
                if Input.is_action_pressed("move_left"):
                    step = [step[0] - self.gravity[1], step[1] + self.gravity[0]]
                if Input.is_action_pressed("move_right"):
                    step = [step[0] + self.gravity[1], step[1] - self.gravity[0]]

            if not block.moved and block.can_move(grid, step):
                block.move(grid, step)
                block.moved = true
                done = false

        # When the controlled block lands it becomes uncontrolled
        if self.controlled_block != null and not self.controlled_block.moved:
            self.controlled_block = null


func rotate_gravity():
    self.gravity = [self.gravity[1], -self.gravity[0]]


func spawn_random_block():
    var block: Node2D = Block.new()
    block.random()
    block.coord = [-(Globals.GRID_HALF_WIDTH + 2) * gravity[0], -(Globals.GRID_HALF_WIDTH + 2) * gravity[1]]
    add_child(block)
    self.blocks.append(block)
    self.controlled_block = block
    self.emit_signal("score_changed", self.blocks.size())
