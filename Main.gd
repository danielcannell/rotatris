extends Node2D

var stime;

enum GameState {
    INTRO,
    PLAYING,
    GAME_OVER,
}

var state: int = GameState.INTRO


func _ready():
    var _dontcare := $Playfield.connect("score_changed", self, "on_score_changed")
    on_score_changed($Playfield.score)

    _dontcare = $Playfield.connect("cost_changed", self, "on_cost_changed")
    on_cost_changed($Playfield.cost)

    _dontcare = $Playfield.connect("game_over", self, "on_game_over")
    $Playfield.pause()
    update_ui()


func update_ui():
    if state == GameState.INTRO:
        # Hide the game and show the intro text
        $Playfield.visible = false
        $UI.visible = false
        $IntroUI.visible = true
    elif state == GameState.PLAYING:
        # Show the game
        $Playfield.visible = true
        $UI.visible = true
        $IntroUI.visible = false
    elif state == GameState.GAME_OVER:
        # TODO
        pass


func on_score_changed(value: int):
    $UI/ScoreLabel.text = "Score: " + str(value)

    shader_step_multi = (min(value, 200) / 200.0) * 2.0


func on_cost_changed(value: int):
    $UI/DroppedBlocksLabel.text = "Dropped Blocks: " + str(value) + " / " + str(Globals.MAX_DROPPED_BLOCKS)
    if value >= Globals.MAX_DROPPED_BLOCKS:
        on_game_over()


var shader_time = 0
var shader_step_multi_base = 0.001
var shader_step_multi = 0.0


func _process(delta):
    shader_time += delta * (shader_step_multi_base + shader_step_multi)
    $Background.material.set_shader_param("stime", shader_time)
    update_ui()

    if state != GameState.PLAYING:
        if Input.is_action_just_pressed("drop"):
            state = GameState.PLAYING
            $Playfield.start_game()


func on_game_over():
    print("GAME OVER")
