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

enum ShapeColors {
    BLUE,
    GREEN,
    RED,
}


const INVALID_BLOCK_ID = 0
var block_id = 0


func allocate_block_id():
    self.block_id += 1
    return self.block_id
