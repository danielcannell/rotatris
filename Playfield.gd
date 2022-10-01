extends Node2D


signal score_changed


# All blocks currently in play, by ID
var blocks: Dictionary

# Time since the last 1 square move
var time := 0.0

# Number of moves since the last gravity change
var gravity_counter := 0

# Current gravity vector
var gravity: Array = [0, 1]

# The block current controlled by user input
var controlled_block : Block = null

var boundary: Boundary


# Called when the node enters the scene tree for the first time.
func _ready():
    self.blocks = {}
    boundary = Boundary.new()
    add_child(boundary)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    self.time += delta

    if self.time > Globals.TIME_TO_MOVE_1_SQUARE:
        self.time = fmod(self.time, Globals.TIME_TO_MOVE_1_SQUARE)
        var grid = update_block_positions()
        clear_full_lines(grid)
        self.gravity_counter += 1

    update_camera(delta)

    if self.controlled_block == null:
        # We do this here for now so that we don't rotate while the falling
        # block is outside the grid
        if self.gravity_counter >= Globals.MOVES_PER_GRAVITY_CHANGE:
            self.gravity_counter = 0
            self.rotate_gravity()

        spawn_random_block()

    process_inputs()


func process_inputs():
    if self.controlled_block == null:
        return

    var move := 0
    var rotate := 0

    if Input.is_action_just_pressed("move_left"):
        move -= 1
    if Input.is_action_just_pressed("move_right"):
        move += 1
    if Input.is_action_just_pressed("rotate_cw"):
        rotate += 1
    if Input.is_action_just_pressed("rotate_ccw"):
        rotate -= 1

    if move or rotate:
        var grid := {}
        for block in self.blocks.values():
            block.fill_grid(grid)

        if move:
            var step := [move * +self.gravity[1], move * -self.gravity[0]]

            if self.controlled_block.can_move(grid, step):
                self.controlled_block.move(grid, step, false)

        if rotate:
            self.controlled_block.try_rotate(grid, rotate, gravity)


# Update the grid coordinates of all blocks
func update_block_positions() -> Dictionary:
    var grid := {}
    var done := false

    for block in self.blocks.values():
        block.fill_grid(grid)
        block.moved = false

    while not done:
        done = true

        for block in self.blocks.values():
            var step := self.gravity

            if not block.moved and block.can_move(grid, step):
                block.move(grid, step)
                block.moved = true
                done = false

        # When the controlled block lands it becomes uncontrolled
        if self.controlled_block != null and not self.controlled_block.moved:
            self.controlled_block = null

    return grid


func _split_blocks(grid: Dictionary, to_split: Array, line: Array):
    for id in to_split:
        var block = self.blocks[id]
        assert(block.squares.size() > 0)
        block.erase_grid(grid)
        var new_blocks := split_block(block, line)
        self.blocks.erase(id)
        self.remove_child(block)
        for x in new_blocks:
            x.fill_grid(grid)
            self.blocks[x.id] = x
            self.add_child(x)


func clear_full_lines(grid: Dictionary):
    if self.gravity[0] != 0:
        # for each column
        for col in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
            var full := true
            var blocks_in_row := []
            var line := []
            for row in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
                line.append([col, row])
                var id = grid.get([col, row], Globals.INVALID_BLOCK_ID)
                if id == Globals.INVALID_BLOCK_ID or blocks[id].moved:
                    full = false
                    break
                if not blocks_in_row.has(id):
                    blocks_in_row.append(id)

            # if column is full
            if full:
                _split_blocks(grid, blocks_in_row, line)
                for block in self.blocks.values():
                    assert(block.squares.size() > 0)

    else:
        # for each row
        for row in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
            var full := true
            var blocks_in_row := []
            var line := []
            for col in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
                line.append([col, row])
                var id = grid.get([col, row], Globals.INVALID_BLOCK_ID)
                if id == Globals.INVALID_BLOCK_ID or blocks[id].moved:
                    full = false
                    break
                if not blocks_in_row.has(id):
                    blocks_in_row.append(id)

            # if row is full
            if full:
                _split_blocks(grid, blocks_in_row, line)
                for block in self.blocks.values():
                    assert(block.squares.size() > 0)


func rotate_gravity():
    self.gravity = [self.gravity[1], -self.gravity[0]]


func spawn_random_block():
    var block: Node2D = Block.new()
    block.random()
    block.coord = [-(Globals.GRID_HALF_WIDTH + 10) * gravity[0], -(Globals.GRID_HALF_WIDTH + 10) * gravity[1]] # TODO: This should be in the block class
    block.update_position()
    add_child(block)
    self.blocks[block.id] = block
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
            var adj = [square[0] + block.coord[0], square[1] + block.coord[1]]
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
        assert(new_block_squares.size() > 0)
        new_block.coord = block.coord
        new_block.color = block.color
        new_block.id = Globals.allocate_block_id()
        new_block.moved = block.moved
        new_block.update_position()
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
