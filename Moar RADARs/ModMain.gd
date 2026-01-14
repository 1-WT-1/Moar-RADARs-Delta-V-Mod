extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = 0
# Name of the mod, used for writing to the logs
const MOD_NAME = "Moar RADARs!"
const MOD_VERSION_MAJOR = 2
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = "indev"
# Path of the mod folder, automatically generated on runtime
var modPath:String = get_script().resource_path.get_base_dir() + "/"
# Required var for the replaceScene() func to work
var _savedObjects := []

func _init(modLoader = ModLoader):
	l("Initializing")
	updateTL("i18n/en.txt", "|")
	updateTL("i18n/ua.txt", "|")
	
	installScriptExtension("hud/LIDAR.gd")
	replaceScene("hud/components/LIDAR.tscn")
	replaceScene("enceladus/Tuning.tscn")
	l("Initialized")

func _ready():
	l("Readying")

	l("Ready")

# Helper script to load translations using csv format (updated by Hev)
func updateTL(path:String, delim:String = ",", useRelativePath:bool = true, fullLogging:bool = true):
	if useRelativePath:
		path = str(modPath + path)
	l("Adding translations from: %s" % path)
	var tlFile:File = File.new()
	var err = tlFile.open(path, File.READ)

	if err != OK:
		return

	var translations := []

	var translationCount = 0
	var csvLine := tlFile.get_line().split(delim)

	if fullLogging:
		l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)

	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)
		var size = csvLine.size()
		if size > 1:
			if size > 2:
				var i = 0
				while i < size:
					if csvLine[i].ends_with("\\") and i < size:
						csvLine[i] = csvLine[i] + delim + csvLine[i + 1]
						csvLine.remove(i + 1)
						size -= 1
					i += 1
			var translationID := csvLine[0]
			for i in range(1, size):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			if fullLogging:
				l("Added translation: %s" % csvLine)
			translationCount += 1

	tlFile.close()

	for translationObject in translations:
		TranslationServer.add_translation(translationObject)
	l("%s Translations Updated" % translationCount)



# Helper function to extend scripts
# Loads the script you pass, checks what script is extended, and overrides it
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)

	childScript.new()

	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path

	l("Installing script extension: %s <- %s" % [parentPath, childPath])

	childScript.take_over_path(parentPath)

# Helper function to replace scenes
# Can either be passed a single path, or two paths
# With a single path, it will replace the vanilla scene in the same relative position
func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)

	if oldPath.empty():
		oldPath = str("res://" + newPath)

	newPath = str(modPath + newPath)

	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)

func l(msg:String, title:String = MOD_NAME, version:String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])
