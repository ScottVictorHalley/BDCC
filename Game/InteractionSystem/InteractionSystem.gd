extends Reference
class_name InteractionSystem

var pawns:Dictionary = {}
var pawnsByLoc:Dictionary = {}
var interactions:Array = []

var globalTasks:Dictionary = {}

# Unsaved
var interactionsDisabled:bool = false
var pawnDistribution = {
		CharacterType.Inmate: 3,
		CharacterType.Guard: 2,
		CharacterType.Nurse: 1,
		CharacterType.Engineer: 1,
	}

func getMaxPawnCount() -> int:
	return 20

func TEST_DELETE_ME():
	spawnPawn("pc")
	spawnPawn(RNG.pick(GM.main.dynamicCharacters))
	spawnPawn(RNG.pick(GM.main.dynamicCharacters))

func _init():
	for taskID in GlobalRegistry.getGlobalTasks():
		var newTask = GlobalRegistry.createGlobalTask(taskID)
		globalTasks[newTask.id] = newTask

func processTime(_howMuch:int):
#	var toUpdate:Array = getInteractionsThatNeedToProcessed()
#	while(toUpdate.size() > 0):
#		for interact in toUpdate:
#			pass
#
#		toUpdate = getInteractionsThatNeedToProcessed()
	#var currentTime:int = GM.main.getTime()
	for pawnID in pawns:
		var pawn:CharacterPawn = pawns[pawnID]
		pawn.checkAloneInteraction()

	#print(pawns)
	var maxProcesses:int = 50
	
	var interaction:PawnInteractionBase = getClosestInteraction()
	while(interaction != null && _howMuch > 0):
		var interactionBusySecs:int = interaction.busyActionSeconds
		if(_howMuch < interactionBusySecs):
			break
		
		if(interactionBusySecs > 0):
			processBusyAllInteractions(interactionBusySecs)
			_howMuch -= interactionBusySecs
		interaction.doCurrentAction()
		
		if(!interaction.getCurrentPawn().isPlayer()):
			decideNextAction(interaction)
		
		maxProcesses -= 1
		if(maxProcesses <= 0):
			print("[Interaction System] HIT THE MAX PROCESS LIMIT")
			break
		interaction = getClosestInteraction()
		
	processBusyAllInteractions(_howMuch)
	
	checkAddNewPawns()
	#for theinteraction in interactions:
	#	theinteraction.isNew = false
	#print(pawnsByLoc)
	#print(interactions)
	pass

func decideNextAction(interaction, _context:Dictionary = {}):
	if(interaction == null):
		assert(false, "Interation is null!")
		return
	if(interaction.wasDeleted):
		return
	var actions = interaction.getActionsFinal()
	
	if(actions == null || !(actions is Array) || actions.size() <= 0):
		Log.printerr("No actions found for interaction: "+str(interaction.id))
		return
	
	var maxScore:float = 0.0
	for action in actions:
		if(maxScore > action["score"]):
			maxScore = action["score"]
	
	var minScore:float = maxScore * 0.1 # Filtering out unlikely actions
	var possibleActions := []
	for action in actions:
		if(action["score"] >= minScore):
			possibleActions.append([action, action["score"]])
	
	if(possibleActions.size() <= 0):
		Log.printerr("No possible actions found for interaction: "+str(interaction.id))
		interaction.setPickedAction(RNG.pick(actions), _context)
		return
	
	var selectedAction = RNG.pickWeightedPairs(possibleActions)#actions[0]
	interaction.setPickedAction(selectedAction, _context)

func processBusyAllInteractions(howManySeconds:int):
	if(howManySeconds <= 0):
		return
	for pawnID in pawns:
		var pawn = pawns[pawnID]
		pawn.processTime(howManySeconds)
	for interaction in interactions:
		interaction.busyActionSeconds -= howManySeconds
		interaction.processTime(howManySeconds)

func getClosestInteraction() -> PawnInteractionBase:
	var result = null
	for interaction in interactions:
		if(interaction == null):# || interaction.isNew):
			continue
		if(result == null || interaction.busyActionSeconds < result.busyActionSeconds):
			if(!interaction.isBeingSpied() && !interaction.isWaitingForScene()):
				result = interaction
	return result

func spawnPawn(charID):
	if(charID == null):
		return
	var character:BaseCharacter = GlobalRegistry.getCharacter(charID)
	if(character == null):
		return
	var newPawn: CharacterPawn = CharacterPawn.new()
	newPawn.charID = charID
	
	if(pawns.has(charID)):
		deletePawn(charID)
	pawns[charID] = newPawn
	
	if(charID == "pc"):
		newPawn.setLocation(GM.pc.getLocation())
	else:
		var newLoc:String = "main_punishment_spot"
		var charType = character.getCharacterType()
		
		if(charType == CharacterType.Inmate):
			var inmateType = character.getInmateType()
			
			if(inmateType == InmateType.SexDeviant):
				newLoc = GM.world.getSafeFromPCRandomRoom(["main_stairs1", "main_stairs2", "cellblock_lilac_nearcell"], GM.pc.getLocation())
			elif(inmateType == InmateType.HighSec):
				newLoc = GM.world.getSafeFromPCRandomRoom(["main_stairs1", "main_stairs2", "cellblock_red_nearcell"], GM.pc.getLocation())
			else:
				newLoc = GM.world.getSafeFromPCRandomRoom(["main_stairs1", "main_stairs2", "cellblock_orange_nearcell"], GM.pc.getLocation())
		elif(charType == CharacterType.Guard):
			newLoc = GM.world.getSafeFromPCRandomRoom(["hall_elevator", "main_greenhouses"], GM.pc.getLocation())
		elif(charType == CharacterType.Nurse):
			newLoc = "med_elevator"
		elif(charType == CharacterType.Engineer):
			newLoc = "mining_elevator"
		
		newPawn.setLocation(newLoc)
	
	var loc = newPawn.getLocation()
	if(!pawnsByLoc.has(loc)):
		pawnsByLoc[loc] = {}
	pawnsByLoc[loc][charID] = true
	
	newPawn.onSpawn()
	return newPawn

func deletePawn(charID):
	if(charID == null):
		return
	
	if(!pawns.has(charID)):
		return
	stopInteractionsForPawnID(charID)
	
	var pawn = pawns[charID]
	pawn.isDeleted = true
	var loc = pawn.getLocation()
	var _ok = pawns.erase(charID)
	if(pawnsByLoc.has(loc)):
		var _ok2 = pawnsByLoc[loc].erase(charID)

func onPawnMoved(charID, oldLoc:String, newLoc:String):
	if(charID == null):
		return
	if(oldLoc == newLoc):
		return
	var pawn = getPawn(charID)
	if(pawn == null):
		return
	if(pawnsByLoc.has(oldLoc)):
		var _ok2 = pawnsByLoc[oldLoc].erase(charID)
		if(pawnsByLoc[oldLoc].empty()):
			var _ok3 = pawnsByLoc.erase(oldLoc)
	if(!pawnsByLoc.has(newLoc)):
		pawnsByLoc[newLoc] = {}
	pawnsByLoc[newLoc][charID] = true
	
	if(areInteractionsDisabled()):
		return
	
	var allNewPawns:Array = getPawnsAt(newLoc)
	for otherpawn in allNewPawns:
		if(otherpawn.charID == pawn.charID):
			continue
		
		if(otherpawn.onMeetWith(pawn, true)):
			break
		if(pawn.onMeetWith(otherpawn, false)):
			break

func getPawns() -> Dictionary:
	return pawns

func hasPawn(charID:String) -> bool:
	return pawns.has(charID)

func getPawn(charID:String) -> CharacterPawn:
	if(!pawns.has(charID)):
		return null
	return pawns[charID]

func getPawnsAt(loc:String) -> Array:
	if(!pawnsByLoc.has(loc)):
		return []
	var result := []
	
	for pawnID in pawnsByLoc[loc]:
		result.append(getPawn(pawnID))
	return result

func getPawnsNear(loc:String, maxDepth:int, maxDist:float=-1.0) -> Array:
	var result:Array = []
	var allRooms:Array
	if(maxDist >= 0.0):
		allRooms = GM.world.getConnectedRoomsNearLimitDistance(loc, maxDepth, maxDist)
	else:
		allRooms = GM.world.getConnectedRoomsNear(loc, maxDepth)
	
	for roomID in allRooms:
		result.append_array(getPawnsAt(roomID))
	return result

func getPawnIDsAt(loc:String) -> Array:
	if(!pawnsByLoc.has(loc)):
		return []
	var result := []
	
	for pawnID in pawnsByLoc[loc]:
		result.append(pawnID)
	return result

func getPawnIDsNear(loc:String, maxDepth:int, maxDist:float=-1.0) -> Array:
	var result:Array = []
	var allRooms:Array
	if(maxDist >= 0.0):
		allRooms = GM.world.getConnectedRoomsNearLimitDistance(loc, maxDepth, maxDist)
	else:
		allRooms = GM.world.getConnectedRoomsNear(loc, maxDepth)
	
	for roomID in allRooms:
		result.append_array(getPawnIDsAt(roomID))
	return result

func hasPawnsAt(loc:String) -> bool:
	if(!pawnsByLoc.has(loc)):
		return false
	if(pawnsByLoc[loc].size() > 0):
		return true
	return false

func hasPawnsAtIgnorePC(loc:String) -> bool:
	if(!pawnsByLoc.has(loc)):
		return false
	for pawnID in pawnsByLoc[loc]:
		if(pawnID != "pc"):
			return true
	return false

func getInteractionsAt(loc:String) -> Array:
	var result := []
	
	for interaction in interactions:
		if(interaction.getLocation() == loc):
			result.append(interaction)
	
	return result

func getInteractionsThatNeedToProcessed() -> Array:
	return []

# slow
func rebuildPawnsByLoc():
	pawnsByLoc.clear()
	
	for pawnID in pawns:
		var pawn = pawns[pawnID]
		var loc = pawn.getLocation()
		if(!pawnsByLoc.has(loc)):
			pawnsByLoc[loc] = {}
		pawnsByLoc[loc][pawnID] = true

func clearAll():
	for charID in pawns.keys():
		deletePawn(charID)
	pawns.clear()
	interactions.clear()

func beforeNewDay():
#	for charID in pawns.keys():
#		if(charID == "pc"):
#			continue
#		deletePawn(charID)
	#pawns.clear()
	#interactions.clear()
	for interaction in interactions.duplicate():
		if(interaction.isPlayerInvolved()):
			continue
		
		var involvedPawns = interaction.getInvolvedPawnIDs()
		stopInteraction(interaction)
		for thePawnID in involvedPawns:
			deletePawn(thePawnID)

func afterNewDay():
	spawnMorningWave()

func startInteraction(interactionID:String, involvedPawns:Dictionary, args:Dictionary = {}):
	var interaction = GlobalRegistry.createInteraction(interactionID)
	assert(interaction != null)
	interactions.append(interaction)
	
	if(!involvedPawns.empty()):
		var firstPawn = getPawn(involvedPawns[involvedPawns.keys()[0]])
		if(firstPawn != null):
			interaction.setLocation(firstPawn.getLocation())
	
	for pawnRole in involvedPawns:
		#var pawn = getPawn(involvedPawns[pawnRole])
		stopInteractionsForPawnID(involvedPawns[pawnRole])
		
	for pawnRole in involvedPawns:
		var pawn = getPawn(involvedPawns[pawnRole])
		pawn.setInteraction(interaction)
	
	#interaction.isNew = waitUntilNextProcess
	interaction.start(involvedPawns, args)

func stopInteraction(interaction:PawnInteractionBase):
	interactions.erase(interaction)
	interaction.wasDeleted = true
	
	for pawnRole in interaction.involvedPawns:
		var pawn = getPawn(interaction.involvedPawns[pawnRole])
		if(pawn != null):
			pawn.setInteraction(null)

func stopInteractionsForPawnID(charID:String):
	for interaction in interactions.duplicate():
		for pawnRole in interaction.involvedPawns:
			if(interaction.involvedPawns[pawnRole] == charID):
				stopInteraction(interaction)
				break

func stopInteractionsForPawn(pawn):
	stopInteractionsForPawnID(pawn.charID)

func checkOnMeetInteractions(pawn1, pawn2, pawn2Moved:bool):
	for interacitonID in GlobalRegistry.getInteractions():
		var interaction:PawnInteractionBase = GlobalRegistry.getInteractionRef(interacitonID)
		
		var shouldRunData = interaction.shouldRunOnMeet(pawn1, pawn2, pawn2Moved)
		
		if(shouldRunData[0]):
			startInteraction(interaction.id, shouldRunData[1], shouldRunData[2] if shouldRunData.size() > 2 else {})
			return true
	return false

func getGlobalTasks() -> Dictionary:
	return globalTasks

func getGlobalTask(id:String) -> GlobalTask:
	if(!globalTasks.has(id)):
		return null
	return globalTasks[id]

func areInteractionsDisabled() -> bool:
	return interactionsDisabled

func getPawnCount() -> int:
	return pawns.size()

func getPawnDistribution() -> Dictionary:
	return pawnDistribution

func trySpawnPawn():
	var randomCharType = RNG.pickWeightedDict(pawnDistribution)
	
	var pool := ""
	if(randomCharType == CharacterType.Inmate):
		pool = CharacterPool.Inmates
	if(randomCharType == CharacterType.Guard):
		pool = CharacterPool.Guards
	if(randomCharType == CharacterType.Nurse):
		pool = CharacterPool.Nurses
	if(randomCharType == CharacterType.Engineer):
		pool = CharacterPool.Engineers
		
	if(pool == ""):
		return false
	
	var possibleCharIds:Array = GM.main.getDynamicCharacterIDsFromPool(pool)
	if(possibleCharIds.size() <= 0):
		return false
	
	var chanceMeetOld = NpcFinder.chanceToMeetOldNPC(pool)
	
	var tryCount:int = 10
	if(RNG.chance(chanceMeetOld)):
		tryCount = 0
	while(tryCount > 0):
		tryCount -= 1
		
		var randomCharID = RNG.pick(possibleCharIds)
		
		if(hasPawn(randomCharID)):
			continue
		var character = GlobalRegistry.getCharacter(randomCharID)
		if(character.shouldBeExcludedFromEncounters()):
			continue
		
		spawnPawn(randomCharID)
		return true
	
	if(GM.main.getEncounterSettings().doesPreferKnownEncounters()):
		return false
	# Generating a new npc
	var genID:String = ""
	var generator = null
	
	if(pool == CharacterType.Inmate):
		generator = InmateGenerator.new()
	elif(pool == CharacterType.Guard):
		generator = GuardGenerator.new()
	elif(pool == CharacterType.Nurse):
		generator = NurseGenerator.new()
	elif(pool == CharacterType.Engineer):
		generator = EngineerGenerator.new()
	
	if(generator != null):
		genID = NpcFinder.generateNpcForPool(pool, generator)
		
	if(genID != ""):
		spawnPawn(genID)
		return true
	
	return false
	
func processAllPawnsNoInteractions(howManySeconds:int):
	interactionsDisabled = true
	processTime(howManySeconds)
	interactionsDisabled = false

func spawnMorningWave():
	var howManyToSpawnF:float = getMaxPawnCount()
	howManyToSpawnF *= RNG.randf_range(0.7, 0.9)
	var howManyToSpawn:int = int(howManyToSpawnF)
	
	for _i in range(howManyToSpawn):
		trySpawnPawn()
	
	#print("THERE ARE NOW "+str(getPawnCount())+" PAWNS")
	processAllPawnsNoInteractions(60*RNG.randi_range(150,170))

func checkAddNewPawns():
	if(GM.main.getTime() >= 19*60*60): # No new pawns in the evening
		return
	
	var maxPawns:int = getMaxPawnCount()
	var curPawns:int = getPawnCount()
	
	if(curPawns >= maxPawns || maxPawns <= 0):
		return
	
	var fullNess:float = float(curPawns) / float(maxPawns)
	
	var chanceToAddNew:float = (1.0 - fullNess) * 10.0
	
	if(!RNG.chance(chanceToAddNew)):
		return
	
	trySpawnPawn()

func updatePCLocation():
	if(!pawns.has("pc")):
		spawnPawn("pc")
	
	var pawn:CharacterPawn = getPawn("pc")
	if(pawn == null):
		return
	
	var latestPCLoc:String = GM.pc.getLocation()
	pawn.setLocation(latestPCLoc)
