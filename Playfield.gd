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

    update_camera(delta)

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
    block.coord = [-(Globals.GRID_HALF_WIDTH + 2) * gravity[0], -(Globals.GRID_HALF_WIDTH + 2) * gravity[1]] # TODO: This should be in the block class
    block.update_position()
    add_child(block)
    self.blocks.append(block)
    self.controlled_block = block
    self.emit_signal("score_changed", self.blocks.size())


# line is a list of all cells to delete
# returns array of remaining blocks (may be empty)
func split_block(block: Block, line: Array) -> Array:
    var res := []

    # Delete any cells on the cleared line
    for cell in line:
        var remove := -1
        for i in range(block.squares.size()):
            var square = block.squares[i]
            var adj = [square[0] + cell[0], square[1] + cell[1]]
            if adj[0] == cell[0] and adj[1] == cell[1]:
                remove = i
                break
        if remove != -1:
            block.squares.remove(remove)

    # Find connected regions in 'squares' to create the new blocks
    while block.squares.size() > 0:
        var new_block_squares := []
        new_block_squares.append(block.squares.pop_back())
        var i := 0
        while i < block.squares.size():
            var square = block.squares[i]
            for check in new_block_squares:
                if ((square[0] == check[0] and abs(square[1] - check[1]) == 1) or # adjacent y
                    (square[1] == check[1] and abs(square[0] - check[0]) == 1)): # adjacent x
                    # adjacent cell, add to list
                    new_block_squares.append(block.squares.pop_at(i))
                    i -= 1
                    break
            i += 1

        var new_block = Block.new()
        new_block.squares = new_block_squares
        new_block.coord = block.coord
        new_block.color = block.color
        new_block.id = Globals.allocate_block_id()
        new_block.moved = block.moved
        res.append(new_block)

    return res


func update_camera(delta: float):
    # Work out how much more we want to rotate the camera
    var target_angle := atan2(self.gravity[0], self.gravity[1])
    var current_angle := self.rotation
    var rot := target_angle - current_angle

    # Reduce to the minimum rotation
    while rot > PI:
        rot -= 2 * PI
    while rot <  -PI:
        rot += 2 * PI

    if abs(rot) < 1e-2:
        # Snap to the correct rotation
        self.rotation = target_angle
    else:
        # Rate limit and rotate
        rot = clamp(rot, -Globals.CAMERA_ROTATION_RATE * delta, Globals.CAMERA_ROTATION_RATE * delta)
        self.rotation = current_angle + rot
