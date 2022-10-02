extends Node2D

var stime;

enum GameState {
    INTRO,
    PLAYING,
    GAME_OVER,
}

var state: int = GameState.INTRO


func _ready():
    randomize()

    var _dontcare := $Playfield.connect("score_changed", self, "on_score_changed")
    on_score_changed($Playfield.score)

    _dontcare = $Playfield.connect("cost_changed", self, "on_cost_changed")
    on_cost_changed($Playfield.cost)

    _dontcare = $Playfield.connect("countdown_changed", self, "on_countdown_changed")
    on_countdown_changed(int(Globals.ROTATE_INTERVAL))

    _dontcare = $Playfield.connect("game_over", self, "on_game_over")
    $Playfield.pause()
    update_ui()


func update_ui():
    if state == GameState.INTRO:
        # Hide the game and show the intro text
        $Playfield.visible = false
        $UI.visible = false
        $IntroUI.visible = true
        $GameOverUI.visible = false
    elif state == GameState.PLAYING:
        # Show the game
        $Playfield.visible = true
        $UI.visible = true
        $IntroUI.visible = false
        $GameOverUI.visible = false
    elif state == GameState.GAME_OVER:
        # Show the game-over text
        $Playfield.visible = true
        $UI.visible = true
        $IntroUI.visible = false
        $GameOverUI.visible = true


func on_score_changed(value: int):
    $UI/ScoreLabel.text = "Score: " + str(value)

    shader_step_multi = (min(value, 200) / 200.0) * 2.0


func on_cost_changed(value: int):
    $UI/DroppedBlocksLabel.text = "Dropped Blocks: " + str(value) + " / " + str(Globals.MAX_DROPPED_BLOCKS)
    if value >= Globals.MAX_DROPPED_BLOCKS:
        on_game_over()


func on_countdown_changed(value: int):
    if value >= 0:
        $UI/CountdownLabel.text = str(value)
    else:
        $UI/CountdownLabel.text = "OVERTIME"

    if value <= 3:
        $UI/CountdownLabel.add_color_override("font_color", Color(1, 0, 0))
    else:
        $UI/CountdownLabel.add_color_override("font_color", Color(1, 1, 1))


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
    else:
        if Input.is_action_just_pressed("ui_cancel"):
            $Playfield.game_running = not $Playfield.game_running


func on_game_over():
    $Playfield.pause()
    state = GameState.GAME_OVER
