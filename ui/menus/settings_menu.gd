extends CanvasLayer

# SettingsMenu (RAI-47) — Audio sliders, key rebinds, display options.
# Persists via user://settings.cfg.

const SETTINGS_PATH := "user://settings.cfg"
const REBINDABLE_ACTIONS: Array[String] = [
	"MOVE_UP", "MOVE_DOWN", "MOVE_LEFT", "MOVE_RIGHT",
	"INTERACT", "RUN", "MENU", "PAUSE",
]

@onready var _master_slider: HSlider = $Panel/AudioTab/MasterSlider
@onready var _music_slider: HSlider = $Panel/AudioTab/MusicSlider
@onready var _sfx_slider: HSlider = $Panel/AudioTab/SfxSlider
@onready var _master_value: Label = $Panel/AudioTab/MasterValue
@onready var _music_value: Label = $Panel/AudioTab/MusicValue
@onready var _sfx_value: Label = $Panel/AudioTab/SfxValue
@onready var _fullscreen_check: CheckButton = $Panel/DisplayTab/FullscreenCheck
@onready var _vsync_check: CheckButton = $Panel/DisplayTab/VsyncCheck
@onready var _rebind_list: VBoxContainer = $Panel/ControlsTab/RebindList
@onready var _audio_tab: Control = $Panel/AudioTab
@onready var _controls_tab: Control = $Panel/ControlsTab
@onready var _display_tab: Control = $Panel/DisplayTab
@onready var _close_btn: Button = $Panel/CloseButton
@onready var _tab_audio_btn: Button = $Panel/TabBar/AudioTabBtn
@onready var _tab_controls_btn: Button = $Panel/TabBar/ControlsTabBtn
@onready var _tab_display_btn: Button = $Panel/TabBar/DisplayTabBtn

var _awaiting_rebind: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_master_slider.value_changed.connect(_on_master_changed)
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_vsync_check.toggled.connect(_on_vsync_toggled)
	_close_btn.pressed.connect(close)
	_tab_audio_btn.pressed.connect(func(): _show_tab("audio"))
	_tab_controls_btn.pressed.connect(func(): _show_tab("controls"))
	_tab_display_btn.pressed.connect(func(): _show_tab("display"))
	_load_settings()
	_populate_rebind_list()
	_show_tab("audio")

func open() -> void:
	show()
	get_tree().paused = true

func close() -> void:
	_save_settings()
	hide()
	get_tree().paused = false

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func _show_tab(name: String) -> void:
	_audio_tab.visible = name == "audio"
	_controls_tab.visible = name == "controls"
	_display_tab.visible = name == "display"

# ---------- Audio ----------

func _on_master_changed(v: float) -> void:
	AudioManager.set_master_volume(v)
	_master_value.text = "%d%%" % int(v * 100)

func _on_music_changed(v: float) -> void:
	AudioManager.set_music_volume(v)
	_music_value.text = "%d%%" % int(v * 100)

func _on_sfx_changed(v: float) -> void:
	AudioManager.set_sfx_volume(v)
	_sfx_value.text = "%d%%" % int(v * 100)

# ---------- Display ----------

func _on_fullscreen_toggled(on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)

# ---------- Controls ----------

func _populate_rebind_list() -> void:
	for child in _rebind_list.get_children():
		child.queue_free()
	for action in REBINDABLE_ACTIONS:
		var row := HBoxContainer.new()
		var label := Label.new()
		label.text = action
		label.custom_minimum_size.x = 100
		row.add_child(label)
		var btn := Button.new()
		btn.text = _get_first_event_text(action)
		btn.custom_minimum_size.x = 100
		btn.pressed.connect(func(): _start_rebind(action, btn))
		row.add_child(btn)
		_rebind_list.add_child(row)

func _get_first_event_text(action: String) -> String:
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "(unbound)"
	var e = events[0]
	if e is InputEventKey:
		return OS.get_keycode_string(e.physical_keycode)
	return e.as_text()

func _start_rebind(action: String, btn: Button) -> void:
	_awaiting_rebind = action
	btn.text = "Press any key…"

func _input(event: InputEvent) -> void:
	if _awaiting_rebind == "":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var new_event := InputEventKey.new()
		new_event.physical_keycode = event.physical_keycode
		InputMap.action_erase_events(_awaiting_rebind)
		InputMap.action_add_event(_awaiting_rebind, new_event)
		_awaiting_rebind = ""
		_populate_rebind_list()
		get_viewport().set_input_as_handled()

# ---------- Persistence ----------

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		_master_slider.value = AudioManager.get_master_volume()
		_music_slider.value = AudioManager.get_music_volume()
		_sfx_slider.value = AudioManager.get_sfx_volume()
		return
	var master: float = cfg.get_value("audio", "master", 1.0)
	var music: float = cfg.get_value("audio", "music", 0.8)
	var sfx: float = cfg.get_value("audio", "sfx", 1.0)
	AudioManager.set_master_volume(master)
	AudioManager.set_music_volume(music)
	AudioManager.set_sfx_volume(sfx)
	_master_slider.value = master
	_music_slider.value = music
	_sfx_slider.value = sfx
	# Rebinds.
	for action in REBINDABLE_ACTIONS:
		var key: int = cfg.get_value("input", action, -1)
		if key > 0:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, ev)
	# Display.
	var fs: bool = cfg.get_value("display", "fullscreen", false)
	var vs: bool = cfg.get_value("display", "vsync", true)
	_fullscreen_check.set_pressed_no_signal(fs)
	_vsync_check.set_pressed_no_signal(vs)

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", AudioManager.get_master_volume())
	cfg.set_value("audio", "music", AudioManager.get_music_volume())
	cfg.set_value("audio", "sfx", AudioManager.get_sfx_volume())
	for action in REBINDABLE_ACTIONS:
		var events := InputMap.action_get_events(action)
		if events.is_empty():
			continue
		var e = events[0]
		if e is InputEventKey:
			cfg.set_value("input", action, e.physical_keycode)
	cfg.set_value("display", "fullscreen", _fullscreen_check.button_pressed)
	cfg.set_value("display", "vsync", _vsync_check.button_pressed)
	cfg.save(SETTINGS_PATH)
