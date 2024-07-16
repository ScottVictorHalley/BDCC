extends Reference
class_name CodeContex

signal onPrint(text)
signal onError(codeBlock, text)
signal onGenericError(text)

var curLine:int = -1
var errored = false
var returning = false

var vars = {}
var varsDefinition = {}
var flags = {}
var flagsDefinition = {}

func hasVar(theVar:String):
	if(!vars.has(theVar)):
		return false
	return true

func getVar(theVar:String, defaultValue = null):
	if(!vars.has(theVar)):
		if(varsDefinition.has(theVar)):
			return varsDefinition[theVar]["default"]
		return defaultValue
	return vars[theVar]

func setVar(theVar:String, newValue, _codeblock):
	if(varsDefinition.has(theVar)):
		var varType = varsDefinition[theVar]["type"]
		
		if(varType == DatapackSceneVarType.BOOL && !(newValue is bool)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a BOOLEAN variable "+str(theVar))
			return
		if(varType == DatapackSceneVarType.STRING && !(newValue is String)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a STRING variable "+str(theVar))
			return
		if(varType == DatapackSceneVarType.NUMBER && !(newValue is int) && !(newValue is float)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a NUMBER variable "+str(theVar))
			return
	vars[theVar] = newValue

func clearVars():
	vars = {}

func hasFlag(theVar:String, _codeblock = null):
	if(!flagsDefinition.has(theVar)):
		return false
	return true

func getFlag(theVar:String, defaultValue = null, _codeblock = null):
	if(!flags.has(theVar)):
		if(flagsDefinition.has(theVar)):
			return flagsDefinition[theVar]["default"]
		return defaultValue
	return flags[theVar]

func setFlag(theVar:String, newValue, _codeblock):
	if(flagsDefinition.has(theVar)):
		var varType = flagsDefinition[theVar]["type"]
		
		if(varType == DatapackSceneVarType.BOOL && !(newValue is bool)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a BOOLEAN flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.STRING && !(newValue is String)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a STRING flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.NUMBER && !(newValue is int) && !(newValue is float)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a NUMBER flag "+str(theVar))
			return
	flags[theVar] = newValue

func doPrint(text):
	emit_signal("onPrint", text)
	Log.print(str(text))

func doDebugPrint(text):
	doPrint(text)

func hadAnError() -> bool:
	return errored

func resetErrored():
	errored = false

func shouldReturn() -> bool:
	return returning

func shouldBreak() -> bool:
	return false

func shouldContinue() -> bool:
	return false

func throwError(_codeblock, _errorText):
	errored = true
	
	if(_codeblock == null):
		emit_signal("onGenericError", str(_errorText))
		Log.printerr("[CrotchScript Error] "+str(_errorText))
		return
	emit_signal("onError", _codeblock, str(_errorText))
	Log.printerr("[CrotchScript Error at line "+str(_codeblock.lineNum)+"] "+str(_errorText))

func execute(slotCalls):
	#clearVars()
	returning = false
	errored = false
	calcLineNums(slotCalls)
	slotCalls.execute(self)

func getValue(slotVar):
	var result = slotVar.getValue(self)
	
	return result

func calcLineNums(slotCalls):
	curLine = 0
	slotCalls.calcLineNums(self)

func say(text):
	if(text.length() > 80):
		text = text.substr(0, 78)+"..."
	doPrint(text)

func sayn(text):
	say(text)

func saynn(text):
	say(text)

func addButton(_nameText, _descText, _state, _codeSlot):
	doPrint("BUTTON ADDED: "+str(_nameText))

func addDisabledButton(_nameText, _descText):
	doPrint("DISABLED BUTTON ADDED: "+str(_nameText))

func addCharacter(charAlias, _variant):
	if(charAlias == "pc"):
		throwError(null, "Trying to add the player character (pc) into the scene. There is no need to do that")
		return
	doPrint("ADDED CHAR: "+str(charAlias))

func removeCharacter(charAlias):
	doPrint("REMOVED CHAR: "+str(charAlias))

func aimCameraAndSetLocName(newLoc):
	doPrint("AIMING CAMERA AT "+str(newLoc))

func playAnim(animID, _animData):
	doPrint("PLAYING ANIMATION: "+str(animID))

func doRunEvent():
	doPrint("EVENT WILL HAPPEN")
	setIsReturning()

func setIsReturning():
	returning = true

func markQuestAsVisible():
	pass

func markQuestAsCompleted():
	pass

func hasInterpolatorVar(varID):
	if(hasVar(varID) || hasFlag(varID)):
		return true
	return false

func getInterpolatorVar(varID):
	if(hasVar(varID)):
		return getVar(varID)
	if(hasFlag(varID)):
		return getFlag(varID)
	return null

func isNumber(val):
	if((val is float || val is int)):
		return true
	return false

func isString(val):
	if(val is String):
		return true
	return false

func getCharacterActualID(charID:String):
	return charID

func getCharacter(charID:String):
	var result = GlobalRegistry.getCharacter(getCharacterActualID(charID))
	if(result == null):
		throwError(null, "No character found: "+str(charID))
		return null
	return result

func isInGame():
	if(GM.main == null || !is_instance_valid(GM.main)):
		return false
	return true

func addPain(charID:String, amValue:int):
	if(!isInGame()):
		return
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return
	theChar.addPain(amValue)

func addLust(charID:String, amValue:int):
	if(!isInGame()):
		return
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return
	theChar.addLust(amValue)

func addStamina(charID:String, amValue:int):
	if(!isInGame()):
		return
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return
	theChar.addStamina(amValue)

func getPain(charID:String) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getPain()

func getLust(charID:String) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getLust()

func getStamina(charID:String) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getStamina()

func charMethod(charID:String, themethod:String, args:Array = [], defaultValue = null):
	if(!isInGame()):
		return defaultValue
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return defaultValue
	if(!theChar.has_method(themethod)):
		throwError(null, "No method found: "+str(themethod)+" for the character: "+str(charID))
		return defaultValue
	return theChar.callv(themethod, args)

func getStat(charID:String, statName) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getStat(statName)