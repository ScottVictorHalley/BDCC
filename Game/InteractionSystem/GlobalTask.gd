extends Reference
class_name GlobalTask

var id:String = "error"
var uniqueID:String = ""
#var assigned # Dynamic?
var goalID:String = InteractionGoal.Patrol

func getMaxAssigned() -> int:
	return 1

func canDoTask(_pawn:CharacterPawn) -> bool:
	return true

func canDoTaskFinal(_pawn:CharacterPawn) -> bool:
	if(!_pawn.canBeInterrupted()):
		return false
	
	if(getAllAssignedPawns().size() >= getMaxAssigned()):
		return false
	
	return canDoTask(_pawn)
	
func isAssigned(_pawn:CharacterPawn) -> bool:
	return _pawn.isDoingTask(id)

func getAllAssignedPawns() -> Array:
	var result = []
	
	for pawnID in GM.main.IS.getPawns():
		var pawn:CharacterPawn = GM.main.IS.getPawn(pawnID)
		
		if(isAssigned(pawn)):
			result.append(pawn)
	
	return result

func getGoalID(_pawn:CharacterPawn):
	return goalID

func configureGoalFinal(_pawn:CharacterPawn, _goal):
	_goal.globalTask = id
	configureGoal(_pawn, _goal)

func configureGoal(_pawn:CharacterPawn, _goal):
	pass

func processTime(_howMuch:int):
	pass
