extends Attack

func _init():
	id = "PunchPCAttack"
	category = Category.Physical
	aiCategory = AICategory.Offensive
	
func getVisibleName():
	if(GM.pc.getSkillsHolder().hasPerk(Perk.TestPerk)):
		return "Scratch"
	return "Punch"
	
func getVisibleDesc():
	return "You do a combo of 2 punches, each one dealing "+scaledDmgRangeStr(DamageType.Physical, 5, 10)+" damage"
	
func _doAttack(_attacker, _reciever):
	var attackerName = _attacker.getName()
	var recieverName = _reciever.getName()
	
	if(checkMissed(_attacker, _reciever, DamageType.Physical)):
		return attackerName + " tries to punch " + recieverName + " but misses and fails completely"
	
	if(checkDodged(_attacker, _reciever, DamageType.Physical)):
		return attackerName + " tries to punch " + recieverName + " but " + recieverName + " dodges just in time"
	
	var damage = 0
	damage = doDamage(_attacker, _reciever, DamageType.Physical, RNG.randi_range(5,10))
	damage += doDamage(_attacker, _reciever, DamageType.Physical, RNG.randi_range(5,10))
	
	var texts = [
		attackerName + " manages to land a few strong punches on " + recieverName + ". ",
	]
	var text = RNG.pick(texts)
	
	if(RNG.chance(50)):
		if(_attacker.getSkillsHolder().hasPerk(Perk.TestPerk)):
			_reciever.addEffect(StatusEffect.Bleeding)
			text += "Sharp claws caused "+_reciever.himHer() + " to start [color=red]bleeding[/color]. "
		
	text += recieverDamageMessage(DamageType.Physical, damage)
	
	return text
	
func _canUse(_attacker, _reciever):
	return true

func getRequirements():
	return [["freearms"]]

func getAttackAnimation():
	return TheStage.Punch

func getExperience():
	return [[Skill.Combat, 10]]
