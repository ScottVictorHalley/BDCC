extends "res://Game/Datapacks/UI/CrotchCode/CodeBlockBase.gd"

var nameSlot := CrotchSlotVar.new()

func getCategories():
	return ["Event"]

func _init():
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")

func getType():
	return CrotchBlocks.CALL

func execute(_contex:CodeContex):
	if(!makeSureReactMode(_contex)):
		return
	var charName = nameSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(charName)):
		throwError(_contex, "Scene id must a string, got "+str(charName)+" instead")
		return
		
	_contex.runScene(charName)

func getTemplate():
	return [
		{
			type = "label",
			text = "Run Scene",
		},
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
			expand=true,
		},
	]

func getSlot(_id):
	if(_id == "name"):
		return nameSlot

func updateEditor(_editor):
	if(_editor != null && _editor.has_method("getAllSceneIDs")):
		nameSlot.setRawValue(_editor.getAllSceneIDs()[0] if _editor.getAllSceneIDs().size() > 0 else "")

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "name"):
		if(_editor != null && _editor.has_method("getAllSceneIDs")):
			_visSlot.setPossibleValues(_editor.getAllSceneIDs())
