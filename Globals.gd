extends Node

enum DefaultShapes {
    I,
    J,
    L,
    O,
    Z,
    S,
    T,
}

enum Colors {
    CYAN,
    BLUE,
    GREEN,
    RED,
    YELLOW,
    ORANGE,
    PURPLE,
}

var ColorLookup = {
    Colors.CYAN: Color(0, 1, 1),
    Colors.BLUE: Color(0, 0, 1),
    Colors.GREEN: Color(0, 1, 0),
    Colors.RED: Color(1, 0, 0),
    Colors.YELLOW: Color(1, 1, 0),
    Colors.ORANGE: Color(1, 0.5, 0),
    Colors.PURPLE: Color(0.5, 0, 0.5),
}

const BACKGROUND_GREY := Color(0.2, 0.2, 0.2)


const TIME_TO_MOVE_1_SQUARE := 0.25
const MOVES_PER_GRAVITY_CHANGE := int(10 / TIME_TO_MOVE_1_SQUARE)
const GRID_HALF_WIDTH := 5
const GRID_WIDTH := GRID_HALF_WIDTH * 2
const CAMERA_ROTATION_RATE := 5
const MAX_DROPPED_BLOCKS := 20

const BLOCK_SIZE: int = 32
const INVALID_BLOCK_ID = 0
var block_id = 0


func allocate_block_id():
    self.block_id += 1
    return self.block_id
