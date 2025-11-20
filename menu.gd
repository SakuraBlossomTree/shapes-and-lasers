extends Camera2D

@export var bus_name: String = "AudioReactive"
@export var kick_min_hz: float = 20.0
@export var kick_max_hz: float = 40.0

@export var sensitivity: float = 6.0
@export var min_zoom_factor: float = 1.0
@export var max_zoom_factor: float = 1.2

@export var smooth_speed: float = 4.0

var analyzer_instance = null
var original_zoom := Vector2.ONE

func _ready():
	original_zoom = zoom

	var bus_idx = AudioServer.get_bus_index(bus_name)
	print("Bus index:", bus_idx)

	if bus_idx == -1:
		push_warning("Bus not found: %s" % bus_name)
		return

	var effect_idx = 0
	analyzer_instance = AudioServer.get_bus_effect_instance(bus_idx, effect_idx)

	if analyzer_instance == null:
		push_warning("No AudioEffectSpectrumAnalyzer found on bus '%s'" % bus_name)
	else:
		print("Spectrum Analyzer successfully attached to bus '%s'" % bus_name)

func _process(delta):
	if analyzer_instance == null:
		return

	var mags = analyzer_instance.get_magnitude_for_frequency_range(kick_min_hz, kick_max_hz)

	var energy := 0.0

	# --- Correct detection for Godot 4 ---
	if typeof(mags) == TYPE_VECTOR2:
		var left = mags.x
		var right = mags.y
		energy = (left + right) * 0.5
	else:
		print("UNKNOWN TYPE:", mags)

	# amplify & clamp
	var zoom_factor = clamp(energy * sensitivity, 0.0, 1.0)

	var target_scalar = lerp(min_zoom_factor, max_zoom_factor, zoom_factor)
	var target = Vector2(target_scalar, target_scalar)

	zoom = zoom.lerp(target, delta * smooth_speed)
