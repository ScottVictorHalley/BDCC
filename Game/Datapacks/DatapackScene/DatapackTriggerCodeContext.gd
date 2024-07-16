extends CodeContex
class_name DatapackTriggerCodeContext

var event:EventBase
var datapackScene:DatapackScene
var datapackSceneTrigger:DatapackSceneTrigger
var datapack:Datapack

var storedErrors = []

var buttons = {}
var curButtonIndex = 0

var eventHappened:bool = false

func setDatapackScene(theScene):
	datapackScene = theScene

func setDatapack(theDatapack):
	datapack = theDatapack

func setEvent(theEvent):
	event = theEvent

func setSceneTrigger(theTrigger):
	datapackSceneTrigger = theTrigger

func getCharacterActualID(charID:String):
	if(datapackScene.chars.has(charID)):
		return datapackScene.chars[charID]["realid"]
	return charID

func say(text):
	event.say(processOutputString(text))

func sayn(text):
	event.sayn(processOutputString(text))

func saynn(text):
	event.saynn(processOutputString(text))

func hasFlag(theVar:String, _codeblock = null):
	if(GM.main == null):
		return .hasFlag(theVar, _codeblock)
	
	if(!datapack.flags.has(theVar)):
		return false
	return true

func getFlag(theVar:String, defaultValue = null, _codeblock = null):
	if(GM.main == null):
		return .getFlag(theVar, defaultValue, _codeblock)
	
	if(datapack.flags.has(theVar)):
		return GM.main.getDatapackFlag(datapack.id, theVar, defaultValue)
	
	return GM.main.getFlag(theVar, defaultValue)

func setFlag(theVar:String, newValue, _codeblock):
	if(GM.main == null):
		return .setFlag(theVar, newValue, _codeblock)
	
	if(datapack.flags.has(theVar)):
		var varType = datapack.flags[theVar]["type"]
		
		if(varType == DatapackSceneVarType.BOOL && !(newValue is bool)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a BOOLEAN flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.STRING && !(newValue is String)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a STRING flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.NUMBER && !(newValue is int) && !(newValue is float)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a NUMBER flag "+str(theVar))
			return
		GM.main.setDatapackFlag(datapack.id, theVar, newValue)
		return
	GM.main.setFlag(theVar, newValue)

func throwError(_codeBlock, _errorText):
	.throwError(_codeBlock, _errorText)
	
	if(_codeBlock == null):
		storedErrors.append("[CrotchScript Error] "+str(_errorText))
	else:
		storedErrors.append("[CrotchScript Error at line "+str(_codeBlock.lineNum)+", block: "+str(_codeBlock.id)+"] "+str(_errorText))

func react(_triggerID, _args):
	if(datapackSceneTrigger.executeType != DatapackSceneTrigger.TRIGGER_REACT):
		return
	eventHappened = false
	
	clearVars()
	var code = datapackSceneTrigger.getCode()
	execute(code)
	
	if(storedErrors.size() > 0):
		for errorText in storedErrors:
			event.addMessage("[color=red](Trigger for scene: "+str(datapack.id)+":"+str(datapackScene.id)+") "+errorText+"[/color]")
		storedErrors = []
	
	return eventHappened
	
func run(_triggerID, _args):
	if(datapackSceneTrigger.executeType != DatapackSceneTrigger.TRIGGER_RUN):
		return
	
	buttons.clear()
	clearVars()
	var code = datapackSceneTrigger.getCode()
	execute(code)
	
	if(storedErrors.size() > 0):
		saynn("[color=red](Trigger for scene: "+str(datapack.id)+":"+str(datapackScene.id)+") "+Util.join(storedErrors, "\n")+"[/color]")
		storedErrors = []

	#execute(code)
	

	
#func react(_id, _args):
#	if(buttons.has(_id)):
#		scene.setState(buttons[_id]["state"])
#		execute(buttons[_id]["code"])
#		return true
#	return false
	
#func saveData():
#	return {
#		"vars": vars,
#	}
#
#func loadData(_data):
#	vars = loadVar(_data, "vars", {})

#func getVar(theVar:String, defaultValue = null):
#	if(!vars.has(theVar)):
#		if(datapackScene.vars.has(theVar)):
#			return datapackScene.vars[theVar]["default"]
#	return .getVar(theVar, defaultValue)
#
#func hasVar(theVar:String):
#	return vars.has(theVar) || datapackScene.vars.has(theVar)

func loadVar(_data, thekey, defaultValue = null):
	if(_data.has(thekey)):
		return _data[thekey]
	return defaultValue

func addButton(_nameText, _descText, _state, _codeSlot):
	var newButtonID = "button"+str(curButtonIndex)
	
	buttons[newButtonID] = {
		name = _nameText,
		desc = _descText,
		code = _codeSlot,
		#state = _state,
	}
	
	event.addButton(_nameText, _descText, newButtonID)
	
	curButtonIndex += 1

func addDisabledButton(_nameText, _descText):
	event.addDisabledButton(_nameText, _descText)

func onButton(_method, _args):
	if(!buttons.has(_method)):
		Log.printerr("Was unable to find code for the "+str(_method)+" button")
		return
	
	eventHappened = false
	execute(buttons[_method]["code"])
	return eventHappened

# Replaces =charID: at the start of the lines with [say=charID] tags
func processSayStatements(text:String):
	var lines = text.split("\n", true)
	var result:Array = []
	for linea in lines:
		var line:String = linea
		
		if(line.begins_with("=")):
			var splitData = Util.splitOnFirst(line.substr(1), ": ")
			if(splitData.size() < 2):
				result.append(line)
			else:
				result.append("[say="+str(splitData[0]).strip_edges()+"]"+str(splitData[1]).strip_edges()+"[/say]")
		else:
			result.append(line)
	return Util.join(result, "\n")

var simpleStringInterpolator:SimpleStringInterpolator = SimpleStringInterpolator.new()

# Handles things like {{varName}} and {{"meow" if varName else "mow"}}
func processOutputVars(text:String):
	return simpleStringInterpolator.process(text, self)

func processOutputString(text:String):
	return processOutputVars(processSayStatements(text))

func doDebugPrint(text):
	doPrint(processOutputVars(text))

func doRunEvent():
	setIsReturning()
	eventHappened = true