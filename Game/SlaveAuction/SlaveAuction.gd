extends Reference
class_name SlaveAuction

var charID:String = ""

var roundNumber:int = 0
var totalBidTimes:int = 0
var currentBid:int = 0
var lastBidderIndex:int = -1
var state:String = "start" # act react start ended
var canPresent:bool = true
var bidLastChances:int = 0

var actionText:String = ""
var extraActionTexts:Array = []

var slaveTraits:Dictionary = {}
var usedTraits:Dictionary = {}

var slaveReactionType = AuctionSlaveReaction.Confused

var bidders:Array = []
var shouldEnd:bool = false

func setCharID(newCharID:String):
	charID = newCharID
	slaveReactionType = calculateSlaveReactionType()

func getChar() -> BaseCharacter:
	return GlobalRegistry.getCharacter(charID)

func getCharacter() -> BaseCharacter:
	return GlobalRegistry.getCharacter(charID)

func start():
	calculateSlaveTraits()
	generateBidders()

func calculateSlaveTraits():
	slaveTraits.clear()
	
	var theChar:BaseCharacter = getChar()
	
	for traitID in GlobalRegistry.getAuctionTraits():
		var trait:AuctionTrait = GlobalRegistry.getAuctionTrait(traitID)
		
		var score:float = trait.calculateScore(traitID, theChar)
		slaveTraits[traitID] = score

func generateBidders():
	bidders.clear()
	for _i in range(3):
		var newBidder:AuctionBidder = AuctionBidder.new()
		newBidder.name = "Bidder "+str(_i + 1)
		newBidder.bidderID = "bidder"+str(_i + 1)
		newBidder.index = _i
		newBidder.setAuction(self)
		
		for traitID in GlobalRegistry.getAuctionTraits():
			var trait:AuctionTrait = GlobalRegistry.getAuctionTrait(traitID)
			if(RNG.chance(trait.getBidderChance(traitID))):
				if(RNG.chance(70)):
					newBidder.likes[traitID] = AuctionBidder.TRAIT_UNDISCOVERED
				else:
					newBidder.dislikes[traitID] = AuctionBidder.TRAIT_UNDISCOVERED
		
		bidders.append(newBidder)

func getText() -> String:
	if(state == "ended"):
		return actionText
	if(state == "react"):
		return actionText
	
	var theTexts:Array = []
	var bettingBeginsRound:int = getSoftEndRound()
	theTexts.append("ROUND = "+str(roundNumber)+((". SOFT END = "+str(bettingBeginsRound)) if roundNumber < bettingBeginsRound else ". SOFT END REACHED. AUCTION WILL END IF LESS THAN 2 BIDS."))
	theTexts.append("STATE = "+str(state))
	
	var slavesTraitsTexts:Array = []
	for traitID in slaveTraits:
		var score:float = slaveTraits[traitID]
		var trait:AuctionTrait = GlobalRegistry.getAuctionTrait(traitID)
		
		#theTexts.append(trait.getName(traitID)+": "+str(score))
		if(score > 0.0):
			var theName:String = trait.getName(traitID)
			if(usedTraits.has(traitID)):
				theName = "[color=#FF63E7]"+theName+"[/color]"
			
			slavesTraitsTexts.append(theName+" ("+str(score)+")")
	theTexts.append("{slave.name}'s traits: "+Util.join(slavesTraitsTexts, ", "))
	
	theTexts.append("")
	theTexts.append(getBidderInfo())
	theTexts.append("")
	theTexts.append("How do you want to present your slave?")
	
	return Util.join(theTexts, "\n")

func getActions() -> Array:
	var result:Array = []
	
	if(state == "react"):
		result.append(GlobalRegistry.getAuctionAction("Continue"))
	elif(state == "ended"):
		result.append(GlobalRegistry.getAuctionAction("Continue"))
	elif(state == "start"):
		for actionID in GlobalRegistry.getAuctionActions():
			var theAction:AuctionAction = GlobalRegistry.getAuctionAction(actionID)
			if(theAction == null || theAction.getActionType() != AuctionActionType.Intro):
				continue
			result.append(theAction)
	else:
		for actionID in GlobalRegistry.getAuctionActions():
			var theAction:AuctionAction = GlobalRegistry.getAuctionAction(actionID)
			if(theAction == null || theAction.id == "Continue"):
				continue
			result.append(theAction)
	
	return result

func getState() -> String:
	return state

func getRoundNumber() -> int:
	return roundNumber

func onNewRound():
	state = "act"
	roundNumber += 1
	
	for bidder in bidders:
		bidder.onNewRound()

func canDoAction(_auctionAction:AuctionAction) -> Array:
	if(_auctionAction.getActionType() == AuctionActionType.Continue):
		return [true]
	
	var traitsToCheck:Dictionary = _auctionAction.getTraits()
	if(!traitsToCheck.empty()):
		for traitID in traitsToCheck:
			if(usedTraits.has(traitID)):
				return [false, "You already showed this trait"]
				#return [true, "You already showed this trait"]
	
	return [true]

func doAction(_auctionAction:AuctionAction):
	for bidder in bidders:
		bidder.clearDiscovered()
	extraActionTexts = []
	
	if(state == "ended"):
		shouldEnd = true
		return
	
	if(state == "react"):
		if(canPresent):
			onNewRound()
		
		if(!canPresent):
			bidLastChances += 1
			if(bidLastChances == 1):
				saynnPresenter(str(currentBid)+" credits. Going once.")
			elif(bidLastChances == 2):
				saynnPresenter(str(currentBid)+" credits. Going twice. C'mon, it's your last chance to bid!")
			elif(bidLastChances == 3):
				state = "ended"
				
				saynnPresenter("SOLD!")
				actionText = Util.join(extraActionTexts, "")
				return
			
			doRoundOfBiddingWithChecks()
			actionText = Util.join(extraActionTexts, "")
			state = "react"
			#if(!canPresent):
			#	state = "react"
			#else:
			#	state = "act"
		return
	
	state = "react"
	
	var theResult:Dictionary = _auctionAction.onActFinal(getChar(), self, slaveTraits)
	if(!theResult.has("text")):
		theResult["text"] = "NO ACTION TEXT PROVIDED, FIX ME"
	
	saynn(theResult["text"])
	#actionText = theResult["text"]
	
	if(!theResult.has("traits")):
		theResult["traits"] = _auctionAction.getTraits()
	if(!theResult.has("desire")):
		theResult["desire"] = _auctionAction.getPassiveDesireGain()
	if(!theResult.has("instantDesire")):
		theResult["instantDesire"] = _auctionAction.getPassiveInstantDesireGain()
	if(!theResult.has("slaveReaction")):
		theResult["slaveReaction"] = _auctionAction.getSlaveReaction(getChar(), getSlaveReactionType())
	
	#var extraTexts:Array = []
	saynn(theResult["slaveReaction"])
	
	var traits:Dictionary = theResult["traits"]
	if(!traits.empty()):
		for traitID in traits:
			usedTraits[traitID] = true
		
	var didPositiveReact:bool = false
	var didNegativeReact:bool = false
	for bidderA in getBiddersRandomOrder():
		var bidder:AuctionBidder = bidderA
		var reactResult:Dictionary = bidder.onAction(self, _auctionAction, theResult)
		
		if(reactResult["hitAnyLikes"] && reactResult["desireDelta"] > 0.0 && !didPositiveReact):
			didPositiveReact = true
			bidder.say(_auctionAction.getPositiveReaction(getChar()))
		if(reactResult["hitAnyDislikes"] && reactResult["desireDelta"] < 0.0 && !didNegativeReact):
			didNegativeReact = true
			bidder.say(_auctionAction.getNegativeReaction(getChar()))
	if(!didPositiveReact && !didNegativeReact && _auctionAction.getActionType() != AuctionActionType.Intro):
		RNG.pick(bidders).say(RNG.pick([
			"Your slave is kinda boring.",
		]))
		
	for bidderA in getBiddersRandomOrder():
		var bidder:AuctionBidder = bidderA
		
		for traitID in traits:
			var _ok = bidder.hitTrait(self, traitID)
		#var _ok2 = bidder.discoverRandomTrait(self)
	
	var hadAnyLearns:bool = false
	for bidderA in bidders:
		var bidder:AuctionBidder = bidderA
		
		if(bidder.discoveredLikes.empty() && bidder.discoveredDislikes.empty()):
			continue
		
		var disTexts:Array = []
		var disLikesTexts:Array = []
		var disDisLikesTexts:Array = []
		
		for traitID in bidder.discoveredLikes:
			var traitObj:AuctionTrait = GlobalRegistry.getAuctionTrait(traitID)
			if(traitObj == null):
				continue
			disLikesTexts.append("[color=#"+bidder.getTraitColor(traitID).to_html(false)+"]"+traitObj.getName(traitID)+"[/color]")
		for traitID in bidder.discoveredDislikes:
			var traitObj:AuctionTrait = GlobalRegistry.getAuctionTrait(traitID)
			if(traitObj == null):
				continue
			disDisLikesTexts.append("[color=#"+bidder.getTraitColor(traitID).to_html(false)+"]"+traitObj.getName(traitID)+"[/color]")
		
		if(disLikesTexts.size() > 0):
			disTexts.append("prefers slaves with "+Util.humanReadableList(disLikesTexts)+" trait"+("s" if disLikesTexts.size() > 1 else ""))
		if(disDisLikesTexts.size() > 0):
			disTexts.append("dislikes slaves with "+Util.humanReadableList(disDisLikesTexts)+" trait"+("s" if disDisLikesTexts.size() > 1 else ""))

		sayn("[i]You learned that "+bidder.name+" "+Util.join(disTexts, " and ")+".[/i]")
		hadAnyLearns = true
	if(hadAnyLearns):
		sayn("")

	if(roundNumber == getSoftEndRound()):
		saynnPresenter("We’re wrapping now, folks! Get your bids in while you can!")

	doRoundOfBiddingWithChecks()
		
	#if(!biddingTexts.empty()):
	#	extraTexts.append("")
	#	extraTexts.append_array(biddingTexts)
	
	#if(!extraTexts.empty()):
	#	actionText += "\n\n"+Util.join(extraTexts, "\n")
		
	actionText = Util.join(extraActionTexts, "")

func saynn(theText:String):
	extraActionTexts.append(theText+"\n\n")

func sayn(theText:String):
	extraActionTexts.append(theText+"\n")

func doRoundOfBiddingWithChecks():
	var bidAmount:int = doRoundOfBidding()
	if(roundNumber >= getSoftEndRound()):
		if(bidAmount >= 2):
			print("YAY. BID AMOUNT: "+str(bidAmount))
			saynn("Since you got at least 2 new bids, you can present your slave more!")
			canPresent = true
			bidLastChances = 0
		else:
			canPresent = false
			saynn("Since you got less than 2 new bids after the soft end, you can’t present your slave anymore.")
	else:
		if(roundNumber == 0):
			saynn("The auction has started! Learn as many bidders preferences as possible before the soft end.")
		else:
			saynn("Since it’s round "+str(roundNumber)+" and the soft end hasn’t happened yet, you can present your slave more.")
		canPresent = true
		bidLastChances = 0

func doRoundOfBidding() -> int:
	var resultBidAmount:int = 0
	
	var biddingRoundAmount:int = 1#3
	
	var biddersCopy:Array = []
	for bidder in bidders:
		if(lastBidderIndex != bidder.index):
			biddersCopy.append(bidder)
	biddersCopy.shuffle()
	for bidder in bidders:
		if(lastBidderIndex == bidder.index): # Current bidder is always last so they can bid back
			biddersCopy.append(bidder)
	
	
	for _i in range(biddingRoundAmount):
		for bidderA in biddersCopy:
			var bidder:AuctionBidder = bidderA
			if(lastBidderIndex == bidder.index):
				continue
			
			var chanceToBid:float = bidder.calculateChanceToBid()
			
			if(RNG.chance(chanceToBid / (_i+1))):
				currentBid += 10
				totalBidTimes += 1
				bidder.currentBid = currentBid
				lastBidderIndex = bidder.index
				bidder.onBid(totalBidTimes)
				
				sayn(bidder.name+" placed a "+str(currentBid)+" credits bid.")
				resultBidAmount += 1
				bidLastChances = 0
	
	return resultBidAmount

func getBidderInfo() -> String:
	var resultAr:Array = []
	
	for bidder in bidders:
		resultAr.append(Util.join(bidder.getBidderInfo(), "\n"))
	
	return Util.join(resultAr, "\n\n")

func getSoftEndRound() -> int:
	return 3

func getTotalBidTimes() -> int:
	return totalBidTimes

func getBiddersRandomOrder() -> Array:
	var result:Array = []
	result.append_array(bidders)
	result.shuffle()
	return result

func getPresenterID() -> String:
	return "mirri"

func saynnPresenter(theText:String):
	saynn("[say=presenter]"+theText+"[/say]")

func unlockRandomTraitEachBidder():
	for bidder in bidders:
		bidder.discoverRandomTrait(self)

func unlockRandomTraitOfTypeEachBidder(_traitType):
	for bidder in bidders:
		bidder.discoverRandomTraitOfType(self, _traitType)

func unlockPercentageOfTraitsRandomBidder(howMuch:float):
	var theBidder:AuctionBidder = RNG.pick(bidders)
	
	var unlockedPerc:float = theBidder.getPercentageOfDiscoveredTraits()
	while(unlockedPerc < howMuch):
		var _ok = theBidder.discoverRandomTrait(self)
		
		unlockedPerc = theBidder.getPercentageOfDiscoveredTraits()

func calculateSlaveReactionType():
	var theCharacter:BaseCharacter = getCharacter()
	var thePersonality:Personality = theCharacter.getPersonality()
	var npcSlavery:NpcSlave
	var obedience:float = 0.0
	var trust:float = 0.0
	var love:float = 0.0
	var spoiling:float = 0.0
	var isMindBroken:bool = false
	if(theCharacter.isSlaveToPlayer()):
		npcSlavery = theCharacter.getNpcSlavery()
		obedience = npcSlavery.getObedience()
		isMindBroken = npcSlavery.isMindBroken()
		love = npcSlavery.getLove()
		trust = npcSlavery.getTrust()
		spoiling = npcSlavery.getSpoiling()
	
	if(isMindBroken):
		return AuctionSlaveReaction.MindBroken
	
	var reactionScores:Dictionary = {}
	reactionScores[AuctionSlaveReaction.Obedient] = obedience + thePersonality.getStat(PersonalityStat.Subby) * 0.5
	reactionScores[AuctionSlaveReaction.Confused] = love*0.5 + trust*0.5 - thePersonality.getStat(PersonalityStat.Mean) * 0.5 + thePersonality.getStat(PersonalityStat.Naive) * 0.5 + thePersonality.getStat(PersonalityStat.Brat) * 0.2
	reactionScores[AuctionSlaveReaction.Shy] = obedience*0.5 + love*0.5 - thePersonality.getStat(PersonalityStat.Mean) * 0.5 + thePersonality.getStat(PersonalityStat.Subby) * 0.5 + thePersonality.getStat(PersonalityStat.Coward) * 0.5
	reactionScores[AuctionSlaveReaction.Desperate] = trust*0.5 + spoiling - thePersonality.getStat(PersonalityStat.Naive) * 0.5 - thePersonality.getStat(PersonalityStat.Subby) * 0.5 + thePersonality.getStat(PersonalityStat.Impatient) * 0.5
	reactionScores[AuctionSlaveReaction.Angry] = trust + love*0.5 + thePersonality.getStat(PersonalityStat.Mean) - thePersonality.getStat(PersonalityStat.Subby) * 0.5 - thePersonality.getStat(PersonalityStat.Impatient) * 0.2 - thePersonality.getStat(PersonalityStat.Coward) * 0.3
	
	var maxScoreReaction = AuctionSlaveReaction.Confused
	var maxScoreScore:float = -9999.9
	
	for theReaction in reactionScores:
		if(reactionScores[theReaction] > maxScoreScore):
			maxScoreScore = reactionScores[theReaction]
			maxScoreReaction = theReaction
	
	
	return maxScoreReaction

func getSlaveReactionType():
	return slaveReactionType

func hasEnded() -> bool:
	return shouldEnd

func increaseBiddersDesire(howMuch:float):
	for bidder in bidders:
		bidder.desire += howMuch
