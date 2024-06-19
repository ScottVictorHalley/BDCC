extends "res://Game/Datapacks/UI/PackVarUIs/PackVarUIBase.gd"

var isEditing = false

func _ready():
	setIsEditing(false)

func setIsEditing(newEdit):
	isEditing = newEdit
	
	if(newEdit):
		$LineEdit.visible = true
		$Label.visible = false
		$Button.text = "Save"
	else:
		$LineEdit.visible = false
		$Label.visible = true
		$Button.text = "Edit"

func setVarText(_text):
	$LineEdit.text = _text
	$Label.text = _text

func setData(_dataLine:Dictionary):
	if(_dataLine.has("value")):
		setVarText(_dataLine["value"])

func _on_Button_pressed():
	if(isEditing):
		var newValue = $LineEdit.text
		setVarText(newValue)
		
		triggerChange(newValue)
		
		setIsEditing(false)
	else:
		setIsEditing(true)
