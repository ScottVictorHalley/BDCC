extends ItemBase

func _init():
	id = "plainBra"

func getVisibleName():
	return "Bra"
	
func getDescription():
	var text = "Generic bra made out of a cheap but stretchy material."

	return text

func getClothingSlot():
	return InventorySlot.UnderwearTop

func getBuffs():
	return [
		]

func getTakingOffStringLong(withS):
	if(withS):
		return "unbuttons your bra and takes it off"
	else:
		return "unbutton your bra and take it off"

func getPuttingOnStringLong(withS):
	if(withS):
		return "puts on the bra"
	else:
		return "put on the bra"

func coversBodyparts():
	return [BodypartSlot.Breasts]

func getPrice():
	return 1

func getTags():
	return [
		ItemTag.SoldByUnderwearVendomat,
		]
