extends Node2D


signal score_changed
signal cost_changed
signal game_over
signal countdown_changed


# Is the game in progress?
var game_running := false

# Small timer at the start to avoid double-pressed inputs from the menu
var intro_timer := 1.0

# Player score
var score := 0

# Number of lost squares
var cost := 0

# All blocks currently in play, by ID
var blocks: Dictionary

# Time since the last 1 square move
var time := 0.0

# Number of moves since the last gravity change
var rotate_countdown := Globals.ROTATE_INTERVAL

# Current gravity vector
var gravity: Array = [0, 1]

# The block current controlled by user input
var controlled_block : Block = null

# Some lines were just cleared - can't rotate until next update
var rotation_blocked := false

var boundary: Boundary


# Called when the node enters the scene tree for the first time.
func _ready():
    self.blocks = {}
    self.boundary = Boundary.new()
    self.boundary.set_gravity(self.gravity)
    add_child(self.boundary)


func pause():
    self.game_running = false


func start_game():
    self.game_running = true
    self.intro_timer = 1.0
    self.update_score(0)
    for id in self.blocks:
        var block = self.blocks[id]
        self.remove_child(block)
        block.queue_free()
    self.blocks.clear()
    self.time = 0.0
    self.rotate_countdown = Globals.ROTATE_INTERVAL
    self.controlled_block = null
    self.rotation = atan2(self.gravity[0], self.gravity[1])

    self.emit_signal("countdown_changed", int(self.rotate_countdown))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if not game_running:
        return

    self.intro_timer -= delta
    if self.intro_timer > 0:
        return

    self.time += delta

    var old_countdown := int(ceil(self.rotate_countdown))
    self.rotate_countdown -= delta
    var new_countdown := int(ceil(self.rotate_countdown))

    if old_countdown != new_countdown:
        self.emit_signal("countdown_changed", new_countdown)

    update_camera(delta)

    var grid := {}

    # Move all blocks downwards
    if self.time > Globals.TIME_TO_MOVE_1_SQUARE:
        self.time = fmod(self.time, Globals.TIME_TO_MOVE_1_SQUARE)
        var any_moves := update_block_positions(grid)
        var any_clears := clear_full_lines(grid)
        rotation_blocked = any_moves or any_clears

    if self.rotate_countdown <= 0:
        # Only rotate if no controlled block and no moves or clears just happened
        if self.controlled_block == null and not rotation_blocked:
            self.rotate_countdown = Globals.ROTATE_INTERVAL
            self.emit_signal("countdown_changed", int(self.rotate_countdown))
            self.rotate_gravity(grid)
    else:
        # Spawn new block immediately
        if self.controlled_block == null:
            spawn_random_block()

    process_inputs()
    delete_fallen_blocks()


func update_score(val: int):
    self.score = val
    self.emit_signal("score_changed", self.score)


func process_inputs():
    if self.controlled_block == null:
        return

    var move := 0
    var rotate := 0
    var drop := false

    if Input.is_action_just_pressed("move_left"):
        move -= 1
    if Input.is_action_just_pressed("move_right"):
        move += 1
    if Input.is_action_just_pressed("rotate_cw"):
        rotate += 1
    if Input.is_action_just_pressed("rotate_ccw"):
        rotate -= 1
    if Input.is_action_just_pressed("drop"):
        drop = true

    if move or rotate or drop:
        var grid := {}
        for block in self.blocks.values():
            block.fill_grid(grid)

        if move:
            var step := [move * +self.gravity[1], move * -self.gravity[0]]

            if self.controlled_block.can_move(grid, step, self.boundary):
                self.controlled_block.move(grid, step, false)

        if rotate:
            self.controlled_block.try_rotate(grid, rotate, self.gravity)

        if drop:
            var step := self.gravity
            while self.controlled_block.can_move(grid, step, self.boundary):
                self.controlled_block.move(grid, step, false)


# Update the grid coordinates of all blocks. Returns true if any moved.
func update_block_positions(grid: Dictionary) -> bool:
    grid.clear()
    var done := false
    var any_moved := false

    for block in self.blocks.values():
        block.fill_grid(grid)
        block.moved = false

    while not done:
        done = true

        for block in self.blocks.values():
            var step := self.gravity

            if not block.moved and block.can_move(grid, step, self.boundary):
                block.move(grid, step)
                block.moved = true
                any_moved = true
                done = false

        # When the controlled block lands it becomes uncontrolled
        if self.controlled_block != null and not self.controlled_block.moved:
            self.controlled_block = null

    return any_moved


func _split_blocks(grid: Dictionary, to_split: Array, line: Array):
    for id in to_split:
        var block = self.blocks[id]
        assert(block.squares.size() > 0)
        block.erase_grid(grid)
        var new_blocks := split_block(block, line)
        var found := self.blocks.erase(id)
        assert(found, "removed block did not exist")
        self.remove_child(block)
        block.queue_free()
        for x in new_blocks:
            x.fill_grid(grid)
            self.blocks[x.id] = x
            self.add_child(x)


# Clear any full lines and update the score. Returns true if any lines cleared.
func clear_full_lines(grid: Dictionary) -> bool:
    var lines_cleared := 0
    if self.gravity[0] != 0:
        # for each column
        for col in range(-Globals.GRID_WIDTH, Globals.GRID_WIDTH):
            var full := true
            var blocks_in_row := []
            var line := []
            for row in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
                line.append([col, row])
                var id = grid.get([col, row], Globals.INVALID_BLOCK_ID)
                if id == Globals.INVALID_BLOCK_ID or self.blocks[id].moved:
                    full = false
                    break
                if not blocks_in_row.has(id):
                    blocks_in_row.append(id)

            # if column is full
            if full:
                lines_cleared += 1
                _split_blocks(grid, blocks_in_row, line)
                for block in self.blocks.values():
                    assert(block.squares.size() > 0)

    else:
        # for each row
        for row in range(-Globals.GRID_WIDTH, Globals.GRID_WIDTH):
            var full := true
            var blocks_in_row := []
            var line := []
            for col in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
                line.append([col, row])
                var id = grid.get([col, row], Globals.INVALID_BLOCK_ID)
                if id == Globals.INVALID_BLOCK_ID or self.blocks[id].moved:
                    full = false
                    break
                if not blocks_in_row.has(id):
                    blocks_in_row.append(id)

            # if row is full
            if full:
                lines_cleared += 1
                _split_blocks(grid, blocks_in_row, line)
                for block in self.blocks.values():
                    assert(block.squares.size() > 0)

    if lines_cleared > 0:
        # 1 point for 1 line, 2 for 2 lines, 4 for 3 lines, 8 for 4 lines
        var new_score := self.score + int(pow(2, lines_cleared - 1))
        self.update_score(new_score)

    return lines_cleared > 0


func delete_fallen_blocks():
    var to_delete := []
    var extra_cost := 0

    for id in self.blocks:
        if self.blocks[id].fallen_off(self.gravity):
            to_delete.append(id)

    for id in to_delete:
        var block: Block = self.blocks[id]
        extra_cost += len(block.squares)
        var found := self.blocks.erase(id)
        assert(found, "deleted block was not found")
        self.remove_child(block)
        block.queue_free()

    if extra_cost > 0:
        self.cost += extra_cost
        self.emit_signal("cost_changed", cost)



func rotate_gravity(grid: Dictionary):
    self.gravity = [self.gravity[1], -self.gravity[0]]
    self.boundary.set_gravity(self.gravity)

    # Split any blocks along the new boundary line
    if self.gravity[0]:
        # slice at y min/max
        var row: int = -Globals.GRID_HALF_WIDTH * self.gravity[0]
        if row < 0:
            row -= 1
        var to_slice := []
        var line := []
        for col in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
            line.append([col, row])
            var id: int = grid.get([col, row], Globals.INVALID_BLOCK_ID)
            if id != Globals.INVALID_BLOCK_ID:
                if not to_slice.has(id):
                    to_slice.append(id)
        if to_slice.size() > 0:
            self._split_blocks(grid, to_slice, line)
    else:
        # slice at x min/max
        var col: int = Globals.GRID_HALF_WIDTH * self.gravity[1]
        if col < 0:
            col -= 1
        var to_slice := []
        var line := []
        for row in range(-Globals.GRID_HALF_WIDTH, Globals.GRID_HALF_WIDTH):
            line.append([col, row])
            var id: int = grid.get([col, row], Globals.INVALID_BLOCK_ID)
            if id != Globals.INVALID_BLOCK_ID:
                if not to_slice.has(id):
                    to_slice.append(id)
        if to_slice.size() > 0:
            self._split_blocks(grid, to_slice, line)


func spawn_random_block():
    var height := Globals.GRID_WIDTH + Globals.GRID_HALF_WIDTH - 2
    var block: Node2D = Block.new()
    block.random()
    block.coord = [-height * self.gravity[0], -height * self.gravity[1]] # TODO: This should be in the block class
    block.update_position()

    var grid := {}
    for b in self.blocks.values():
        b.fill_grid(grid)

    if block.collide(grid):
        self.emit_signal("game_over")
    else:
        add_child(block)
        self.blocks[block.id] = block
        self.controlled_block = block


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
