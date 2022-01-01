extends Panel


var effectName
var effectDesc

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func makeRed():
	self_modulate = Color(0.7, 0.1, 0.1)

func makeGreen():
	self_modulate = Color(0.1, 0.7, 0.1)

func setTexture(texture: String):
	$TextureRect.texture = load(texture)

func setNameAndDesc(newname: String, newdesc: String):
	effectName = newname
	effectDesc = newdesc
