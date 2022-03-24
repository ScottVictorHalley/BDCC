extends Reference
class_name ItemBase

var id = "baditem"
var uniqueID = null
var amount = 1
var currentInventory = null
var restraintData: RestraintData = null

func _init():
	if(uniqueID == null):
		uniqueID = "item"+str(GlobalRegistry.generateUniqueID())
	if(isRestraint()):
		generateRestraintData()
		if(restraintData != null):
			restraintData.item = self

func getVisibleName():
	return "Bad item"

func getStackName():
	if(amount > 1):
		return ""+str(amount)+"x"+getVisibleName()
	else:
		return getVisibleName()

func getA():
	return "a"

func getAStackName():
	if(amount > 1):
		return ""+str(amount)+"x"+getVisibleName()
	else:
		return (getA() + " " + getVisibleName()).trim_prefix(" ")

func getDescription():
	return "No description provided, please let the developer know"
	
func getVisisbleDescription():
	var text = getDescription()
	if(hasTag(ItemTag.Illegal)):
		text += "\n[color=red]This item is illegal![/color]"
	
	var buffs = getBuffs()
	if(buffs.size() > 0):
		for buff in buffs:
			text += "\n" + "[color=#"+buff.getBuffColor().to_html(false)+"]" + buff.getVisibleDescription() + "[/color]"
	return text

func getCombatDescription():
	return getVisisbleDescription()

func getUniqueID():
	assert(uniqueID != null)
	
	return uniqueID

func canCombine():
	return false
	
func tryCombine(_otherItem):
	amount += _otherItem.amount
	return true

func canUseInCombat():
	return false

func useInCombat(_attacker, _reciever):
	return ""

func destroyMe():
	assert(currentInventory != null)
	currentInventory.removeItem(self)

func removeXOrDestroy(remamount):
	amount -= remamount
	
	if(amount <= 0):
		destroyMe()

func setAmount(newamount):
	if(newamount > 1):
		assert(canCombine())
	amount = newamount

func getPossibleActions():
	return [
	]
	
func saveData():
	var data = {}
	
	data["amount"] = amount

	return data
	
func loadData(_data):
	amount = SAVE.loadVar(_data, "amount", 1)

func getClothingSlot():
	return null

func getTakeOffScene():
	return "TakeAnyItemOffScene"

func getPutOnScene():
	return "PutOnAnyItemScene"

func getBuffs():
	return []

func buff(buffid, args = []):
	var buff: BuffBase = GlobalRegistry.createBuff(buffid)
	buff.initBuff(args)
	return buff

func getPrice():
	return 0

func getSellPrice():
	return int(getPrice() / 2.0)

func getStackPrice():
	return int(getPrice() * amount)

func getStackSellPrice():
	return int(getSellPrice() * amount)

func canSell():
	return true

func getTakingOffStringLong(withS):
	if(withS):
		return "takes off your "+getVisibleName().to_lower()
	else:
		return "take off your "+getVisibleName().to_lower()

func getTakingOffVerb(withS):
	if(withS):
		return "takes off"
	else:
		return "take off"

func getPuttingOnStringLong(withS):
	if(withS):
		return "puts on your "+getVisibleName().to_lower()
	else:
		return "put on your "+getVisibleName().to_lower()

func getPuttingOnVerb(withS):
	if(withS):
		return "puts on"
	else:
		return "put on"

func coversBodyparts():
	return []

func coversBodypart(bodypartSlot):
	if(bodypartSlot in coversBodyparts()):
		return true
	return false

func getTags():
	return []

func hasTag(tag):
	if(getTags().has(tag)):
		return true
	return false

func isRestraint():
	return false

func generateRestraintData():
	restraintData = RestraintData.new()
	restraintData.setLevel(1)

func getRestraintData() -> RestraintData:
	return restraintData

func calculateBestRestraintLevel():
	if(GM.pc != null):
		return GM.pc.calculateBestRestraintLevel()
	else:
		return RNG.randi_range(1, 5)
