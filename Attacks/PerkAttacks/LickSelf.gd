extends Attack

func _init():
	id = "lickSelfPerkAttack"
	category = Category.Special
	aiCategory = AICategory.Defensive
	
func getVisibleName():
	return "Lick self clean"
	
func getVisibleDesc():
	return "You clean all the cum off of yourself and gain 10 stamina for each layer that you swallowed"
	
func _doAttack(_attacker, _reciever):
	var staminaperlevel = 10

	var texts = [
		"{attacker.name} sticks {attacker.his} tongue out and starts cleaning {attacker.himself}. {reciever.name} raises {reciever.his} brow at the display"
	]
	var text = RNG.pick(texts)
	
	var cumEffect = _attacker.getEffect(StatusEffect.CoveredInCum)
	if(cumEffect == null):
		text += " Sadly there wasn't any cum to clean."
		return text
	
	var messiness = 1
	if(_attacker.isPlayer()):
		messiness = _attacker.getOutsideMessinessLevel()
		_attacker.clearBodyFluids()
	
	_attacker.addStamina(messiness * staminaperlevel)
	_attacker.removeEffect(StatusEffect.CoveredInCum)
	
	text += "\n\n{attacker.name} swallows everything and receives [color="+DamageType.getColorString(DamageType.Stamina)+"]"+str(messiness*staminaperlevel)+" stamina[/color]!"
	
	return text

func canBeDodgedByPlayer(_attacker, _reciever):
	return false

func getRequirements():
	return [["coveredincum"]]

