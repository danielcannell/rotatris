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
    Colors.PURPLE: Color(0.5, 0, 0.5)
}
