extends "res://Game/Datapacks/UI/CrotchCode/CodeBlockBase.gd"

var strSlot := CrotchSlotVar.new()
var indSlot := CrotchSlotVar.new()
var lenSlot := CrotchSlotVar.new()

func getCategories():
	return ["Strings"]

func _init():
	strSlot.setRawType(CrotchVarType.STRING)
	indSlot.setRawType(CrotchVarType.NUMBER)
	indSlot.setRawValue(0)
	lenSlot.setRawType(CrotchVarType.NUMBER)
	lenSlot.setRawValue(-1)

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	var string1 = strSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return ""
	if(!isString(string1)):
		throwError(_contex, "First arg is not a string: "+str(string1))
		return ""
	var charindex = indSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return ""
	if(!isNumber(charindex)):
		throwError(_contex, "Second arg is not a number: "+str(charindex))
		return ""
	var sublen = lenSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return ""
	if(!isNumber(sublen)):
		throwError(_contex, "Third arg is not a number: "+str(sublen))
		return ""

	var strlen:int = string1.length()
	if(charindex < 0 || charindex >= strlen):
		throwError(_contex, "Index out of range: "+str(charindex))
		return ""
	return string1.substr(charindex, sublen)

func getTemplate():
	return [
		{
			type = "slot",
			id = "str",
			slot = strSlot,
			slotType = CrotchBlocks.VALUE,
			placeholder = "text",
		},
		{
			type = "label",
			text = "substr from",
		},
		{
			type = "slot",
			id = "ind",
			slot = indSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "len",
		},
		{
			type = "slot",
			id = "len",
			slot = lenSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "str"):
		return strSlot
	if(_id == "ind"):
		return indSlot
	if(_id == "len"):
		return lenSlot
