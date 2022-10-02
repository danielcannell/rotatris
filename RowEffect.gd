extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var up : Particles2D= $up;
onready var down :Particles2D= $down;


# Called when the node enters the scene tree for the first time.
func _ready():
    up.emitting = false
    down.one_shot = true
    up.one_shot = true
    down.emitting = false



func _run():
    up.emitting = true
    down.emitting = true
    yield(get_tree().create_timer(2.0), "timeout")
    queue_free()


func run():
    call_deferred("_run")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
