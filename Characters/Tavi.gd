extends Character

func _init():
	id = "tavi"
	
	npcLevel = 5
	npcBasePain = 90
	npcBaseLust = 150
	
	npcLustInterests = {
		InterestTopic.Gags: Interest.KindaLikes,
		InterestTopic.Blindfolds: Interest.Hates,
		InterestTopic.BDSMRestraints: Interest.ReallyLikes,
		InterestTopic.FeminineBody: Interest.Likes,
		InterestTopic.AndroBody: Interest.ReallyDislikes,
		InterestTopic.MasculineBody: Interest.Likes,
		InterestTopic.ThickBody: Interest.KindaLikes,
		InterestTopic.AverageMassBody: Interest.Likes,
		InterestTopic.SlimBody: Interest.KindaLikes,
		InterestTopic.ThickButt: Interest.Dislikes,
		InterestTopic.AverageButt: Interest.KindaLikes,
		InterestTopic.SlimButt: Interest.Likes,
		InterestTopic.BigBreasts: Interest.Hates,
		InterestTopic.LactatingBreasts: Interest.Hates,
		InterestTopic.StuffedPussy: Interest.Likes,
		InterestTopic.StuffedAss: Interest.Likes,
		InterestTopic.StuffedPussyOrAss: Interest.KindaLikes,
		InterestTopic.StuffedThroat: Interest.Dislikes,
		InterestTopic.CoveredInCum: Interest.ReallyLikes,
		InterestTopic.CoveredInLotsOfCum: Interest.ReallyDislikes,
		InterestTopic.FullyNaked: Interest.Likes,
		InterestTopic.ExposedPanties: Interest.ReallyLikes,
		InterestTopic.ExposedBra: Interest.ReallyLikes,
		InterestTopic.LooseAnus: Interest.Hates,
		InterestTopic.LoosePussy: Interest.Hates,
		InterestTopic.TightAnus: Interest.Likes,
		InterestTopic.TightPussy: Interest.Likes,
		InterestTopic.HasVaginaAndCock: Interest.Dislikes,
		InterestTopic.BigCock: Interest.ReallyDislikes,
		InterestTopic.AverageCock: Interest.Dislikes,
		InterestTopic.SmallCock: Interest.SlightlyDislikes,
		InterestTopic.Pregnant: Interest.Hates,
	}
	
func interestVerbalReaction(interest):
	if(interest == InterestTopic.Pregnant):
		return "Why did you bend over for someone? You know what happens to prison babies?"
	if(interest == InterestTopic.Blindfolds):
		return "How can I fight you if you can't see me"
	if(interest == InterestTopic.BigBreasts):
		return "Stop showing off your udders and fight"
	if(interest == InterestTopic.LooseAnus):
		return "That ass looks ruined, gross"
	if(interest == InterestTopic.LoosePussy):
		return "You fuck without giving your pussy any rest, huh?"
	if(interest == InterestTopic.BigCock):
		return "That cock is not going anywhere near me"
	if(interest == InterestTopic.HasVaginaAndCock):
		return "So what happens when you cum inside yourself?"
	if(interest == InterestTopic.StuffedThroat):
		return "Don't breathe at me, whore"
	if(interest == InterestTopic.CoveredInCum):
		return "Hah, you're such a messy slut"
	if(interest == InterestTopic.LactatingBreasts):
		return "Go milk your tits, you're leaking"
	
func _getName():
	return "Tavi"

func getGender():
	return Gender.Female
	
func getSmallDescription() -> String:
	return "Red block inmate. A very tall feline with a unique purple and green fur pattern and red/green eyes"

func getSpecies():
	return ["feline"]

func _getAttacks():
	return ["biteattack", "kickToBallsAttack", "slapTitsAttack", "stretchingAttack", "lickWounds", "shoveattack", "trygetupattack"]

func getFightIntro(_battleName):
	return getName() + " gets into the combat stance and prepares for a fight. "+formatSay("Are you afraid of a little kitty cat~?")

func getThickness() -> int:
	return 80

func getFemininity() -> int:
	return 90

func createBodyparts():
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("felinehead"))
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("tavihair"))
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("felineears"))
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("anthrobody"))
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("anthroarms"))
	var breasts = GlobalRegistry.createBodypart("humanbreasts")
	breasts.size = 4
	giveBodypartUnlessSame(breasts)
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("vagina"))
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("anus"))
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("felinetail"))
	giveBodypartUnlessSame(GlobalRegistry.createBodypart("digilegs"))

func getLootTable(_battleName):
	return InmateLoot.new()

func createEquipment():
	getInventory().equipItem(GlobalRegistry.createItemNoID("inmatecollar"))
	getInventory().equipItem(GlobalRegistry.createItemNoID("inmateuniformHighsec"))