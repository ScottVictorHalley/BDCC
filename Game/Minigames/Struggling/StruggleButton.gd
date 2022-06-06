extends Sprite

var progress = 0.0
var waitTime = 5.0
onready var _animation_player := $AnimationPlayer
var hit = false

signal onHit(score)

func _ready():
	_animation_player.play("show")

func setup(timeBeforeFull: float):
	waitTime = timeBeforeFull
	
func _process(delta: float):
	if(waitTime <= 0.0 || hit):
		return
	progress += delta / waitTime
	
	$Panel.rect_scale.x = 1.0 - progress / 2.0
	$Panel.rect_scale.y = 1.0 - progress / 2.0
	
	if(progress >= 1.1):
		gotHit(true)
	
func gotHit(_tooLate = false):
	if(hit):
		return
	_animation_player.play("kill")
	hit = true
	
	if(_tooLate):
		emit_signal("onHit", 0.0)
		#print("TOO LATE")
	else:
		var score = getScore()
		
		emit_signal("onHit", score)

func getScore():
	var closeness = abs(progress - 1.0)
	var checkZone = 0.4
	var deadZone = 0.05
	
	if(closeness > checkZone):
		return 0.0
	
	if(closeness <= deadZone):
		return 1.0
	
	var correctedCloseness = closeness - deadZone
	var sc = correctedCloseness / (checkZone - deadZone)
	return 1.0 - sc


func _on_HitBox_gui_input(event):
	if event.is_action_pressed("touch"):
		get_tree().set_input_as_handled()
		gotHit()
