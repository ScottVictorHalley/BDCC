extends Control

onready var versionLabel = $HBoxContainer/MainVBox/ScrollContainer/VBoxContainer/VersionLabel
onready var MainVBox = $HBoxContainer/MainVBox
onready var LoadGameTab = $HBoxContainer/LoadGameScreen
onready var optionsGameTab = $HBoxContainer/OptionsScreen
onready var creditsGameTab = $HBoxContainer/CreditsScreen
onready var resumeButton = $HBoxContainer/MainVBox/GridContainer/ResumeButton
onready var http_request = $HTTPRequest
onready var gutHubReleaseLabel = $HBoxContainer/Panel/MarginContainer/VBoxContainer/GithubReleaseLabel
onready var gitHubReleaseButton = $HBoxContainer/Panel/MarginContainer/VBoxContainer/GithubReleasesButton
onready var devToolsScreen = $HBoxContainer/DevToolsScreen
onready var devSubScreen = $HBoxContainer/DevToolsScreen/DevScreen

export(Resource) var donationInfo

# Called when the node enters the scene tree for the first time.
func _ready():
	versionLabel.text = "Version: "+GlobalRegistry.getGameVersionString()

	if(donationInfo != null):
		$HBoxContainer/Panel2/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer3/DonationsLabel.bbcode_text = donationInfo.richText

	checkCanResume()
	if(OPTIONS.shouldFetchGithubRelease()):
		getNewRelease()
	else:
		gutHubReleaseLabel.text = "Latest github release: DISABLED"
		gutHubReleaseLabel.visible = false
		gitHubReleaseButton.visible = false


func _on_NewGameButton_pressed():
	var _ok = get_tree().change_scene("res://Game/MainScene.tscn")

func hideAllMenus():
	MainVBox.visible = false
	LoadGameTab.visible = false
	optionsGameTab.visible = false
	creditsGameTab.visible = false
	devToolsScreen.visible = false

func switchToMainMenu():
	hideAllMenus()
	MainVBox.visible = true
	
	checkCanResume()

func _on_LoadGameButton_pressed():
	hideAllMenus()
	LoadGameTab.visible = true
	

func checkCanResume():
	if(SAVE.canResumeGame()):
		resumeButton.disabled = false
	else:
		resumeButton.disabled = true

func _on_ResumeButton_pressed():
	SAVE.switchToGameAndResumeLatestSave()


func _on_OptionsButton_pressed():
	hideAllMenus()
	optionsGameTab.visible = true


func _on_CreditsButton_pressed():
	hideAllMenus()
	creditsGameTab.visible = true


func _on_GithubButton_pressed():
	var _ok = OS.shell_open("https://github.com/Alexofp/BDCC")

func getNewRelease():
	var error = http_request.request("https://api.github.com/repos/Alexofp/BDCC/releases")
	if error != OK:
		printerr("[MainMenu] An error occurred in the HTTP request.")
		gutHubReleaseLabel.text = "Latest github release: Error"

func _on_HTTPRequest_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("[MainMenu] Couldn't get the latest release from github")
		gutHubReleaseLabel.text = "Latest github release: Error"
		return
	
	var jsonResult = JSON.parse(body.get_string_from_utf8())
	if(jsonResult.error != OK):
		printerr("[MainMenu] Couldn't parse json data from github.")
		gutHubReleaseLabel.text = "Latest github release: Error"
		return
	
	var releasesData = jsonResult.result

	if(!(releasesData is Array)):
		printerr("[MainMenu] Bad data from github")
		gutHubReleaseLabel.text = "Latest github release: Error"
		return
		
	for release in releasesData:
		var requiredFields = ["published_at", "name", "tag_name"]
		for req in requiredFields:
			if(!release.has(req)):
				continue
		
		var time = Util.ISO8601DateToDatetime(release["published_at"])
		
		gutHubReleaseLabel.text = "Latest github release: "+release["tag_name"]
		if(time != null):
			gutHubReleaseLabel.text += "\n" + Util.datetimeToRFC113(time)
		
		gutHubReleaseLabel.text += "\n\nYour current version: "+GlobalRegistry.getGameVersionString()
		return
	gutHubReleaseLabel.text = "Latest github release: Nothing found"

func _on_GithubReleasesButton_pressed():
	var _ok = OS.shell_open("https://github.com/Alexofp/BDCC/releases")


func _on_DevClose_pressed():
	hideAllMenus()
	MainVBox.visible = true


func _on_DevToolsButton_pressed():
	hideAllMenus()
	devToolsScreen.visible = true


func _on_DevSceneConverter_pressed():
	Util.delete_children(devSubScreen)
	
	var scene = load("res://Util/SceneConverter.tscn")
	devSubScreen.add_child(scene.instance())


func _on_DevLikesGenerator_pressed():
	Util.delete_children(devSubScreen)
	
	var scene = load("res://UI/LikesGenerator/NpcLikesGenerator.tscn")
	devSubScreen.add_child(scene.instance())


func _on_DiscordButton_pressed():
	var _ok = OS.shell_open("https://discord.gg/7UGYBvQrc3")
	
func _on_ChangelogButton_pressed():
	var _ok = OS.shell_open("https://github.com/Alexofp/BDCC/blob/main/CHANGELOG.md")
