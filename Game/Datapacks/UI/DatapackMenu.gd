extends Control
onready var datapack_item_list = $DatapackViewer/VBoxContainer/HBoxContainer/DatapackItemList
onready var datapack_desc_label = $DatapackViewer/VBoxContainer/HBoxContainer/VBoxContainer/DatapackDescLabel
onready var new_pack_confirmation_dialog = $DatapackViewer/NewPackConfirmationDialog

signal onClosePressed

var datapacksList = []

func _ready():
	#updateDatapackList()
	reloadAndUpdatePacks()

func _on_CloseButton_pressed():
	emit_signal("onClosePressed")

func updateDatapackList():
	datapack_item_list.clear()
	datapacksList.clear()
	
	var allDatapacks = GlobalRegistry.getDatapacks()
	for packID in allDatapacks:
		var datapack:Datapack = allDatapacks[packID]
		
		datapacksList.append(datapack)
		datapack_item_list.add_item(datapack.id+"= "+datapack.name+" (By "+datapack.author+")")

func updateDatapackDesc(theDatapack:Datapack):
	var finalText = ""
	finalText += theDatapack.name
	finalText += "\nAuthor: "+theDatapack.author
	finalText += "\n\n"+theDatapack.description
	finalText += "\n\n"+theDatapack.getContainsString()
	
	datapack_desc_label.bbcode_text = finalText


func _on_NewPackConfirmationDialog_confirmed():
	var newPackID:String = $DatapackViewer/NewPackConfirmationDialog/VBoxContainer/NewPackIDLineEdit.text
	
	print(newPackID)
	if(newPackID == ""):
		showAlert("Empty ID is not allowed")
		return
	#showAlert(newPackID)
	
	var newDatapack:Datapack = Datapack.new()
	newDatapack.id = newPackID
	startEditingDatapack(newDatapack)

func startEditingDatapack(datapack:Datapack):
	var datapackEditorScreen = preload("res://Game/Datapacks/UI/DatapackEditor.tscn").instance()
	pushMenu(datapackEditorScreen)
	
	datapackEditorScreen.setDatapack(datapack)
	datapackEditorScreen.connect("onSaveButtonPressed", self, "onSaveDatapackPressed")
	datapackEditorScreen.connect("onCancelButtonPressed", self, "onCancelDatapackPressed")

func onSaveDatapackPressed(_menu, datapack:Datapack):
	popMenu()
	
	var _ok = datapack.saveToDisk()
	if(!_ok):
		showAlert("Error while saving a datapack. Sorry")
	reloadAndUpdatePacks()

func onCancelDatapackPressed(_menu, _datapack:Datapack):
	popMenu()
	reloadAndUpdatePacks()


func _on_NewDatapackButton_pressed():
	new_pack_confirmation_dialog.visible = true
	$DatapackViewer/NewPackConfirmationDialog/VBoxContainer/NewPackIDLineEdit.text = ""

func showAlert(theText:String):
	if($AlertDialog.visible):
		$AlertDialog/AlertLabel.text += "\n"+theText
	else:
		$AlertDialog/AlertLabel.text = theText
	$AlertDialog.visible = true


func reloadAndUpdatePacks():
	GlobalRegistry.reloadPacks()
	updateDatapackList()

func _on_UpdateButton_pressed():
	reloadAndUpdatePacks()


var menuStack = []

func pushMenu(newMenu:Control):
	$DatapackViewer.visible = false
	for menu in menuStack:
		menu.visible = false
	
	menuStack.append(newMenu)
	add_child(newMenu)
	
func popMenu():
	if(!menuStack.empty()):
		menuStack.back().queue_free()
		menuStack.pop_back()
		
		if(menuStack.empty()):
			$DatapackViewer.visible = true
		else:
			menuStack.back().visible = true
	else:
		$DatapackViewer.visible = true


func _on_EditDatapackButton_pressed():
	var selectedIDs = $DatapackViewer/VBoxContainer/HBoxContainer/DatapackItemList.get_selected_items()
	if(selectedIDs.size() > 0):
		startEditingDatapack(datapacksList[selectedIDs[0]])

var datapackToDelete:Datapack
func _on_DeleteDatapackButton_pressed():
	var selectedIDs = $DatapackViewer/VBoxContainer/HBoxContainer/DatapackItemList.get_selected_items()
	if(selectedIDs.size() > 0):
		datapackToDelete = datapacksList[selectedIDs[0]]
	
		$ConfirmDeleteDatapack.visible = true
		$ConfirmDeleteDatapack/Label2.text = "Are you sure you want to delete the '"+str(datapackToDelete.name)+"' datapack? (id="+str(datapackToDelete.id)+")"


func _on_ConfirmDeleteDatapack_confirmed():
	if(datapackToDelete != null):
		if(GlobalRegistry.deleteDatapack(datapackToDelete.id)):
			reloadAndUpdatePacks()
		else:
			showAlert("Failed to delete the datapack. Sorry")
		datapackToDelete = null


func _on_DatapackItemList_item_selected(index):
	if(index >= 0 && index < datapacksList.size()):
		var datapack:Datapack = datapacksList[index]
		
		updateDatapackDesc(datapack)
