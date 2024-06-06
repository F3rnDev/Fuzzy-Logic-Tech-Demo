extends Panel

@export var dist:float
@export var noise:float

var width
var height
var x_scale
var y_scale
var colors

@export_enum("Distance", "Noise", "Result") var graph_value:String = "Distance"
var fuzzy
var curValue

func _ready():
	width = size.x
	height = size.y
	
	match graph_value:
		"Distance":
			fuzzy = Distance
			x_scale = width / 5.0
			y_scale = height / 1.0
			curValue = dist
		"Noise":
			fuzzy = FzyNoise
			x_scale = width / 100.0
			y_scale = height / 1.0
			curValue = noise

	colors = [Color.RED, Color.GREEN, Color.BLUE]

func _draw():
	match graph_value:
		"Distance":
			draw_distance_graph()
			set_points()
		"Noise":
			draw_noise_graph()
			set_points()
		"Result":
			draw_result_graph()
			fill_result_graph()

func draw_result_graph():
	for i in range(2):
		var curKey = "yes"
		
		if i == 1:
			curKey = "no"
		
		var points = Result.getGraph(width, height, curKey)
		draw_polyline(points, colors[i], 5)

func draw_distance_graph():
	for i in range(3):
		var curKey
		
		match i:
			0:
				curKey = "near"
			1:
				curKey = "medium"
			2:
				curKey = "far"
		
		var points = Distance.getGraph(width, height, curKey)
		draw_polyline(points, colors[i], 5)

func draw_noise_graph():
	for i in range(3):
		var curKey
		
		match i:
			0:
				curKey = "low"
			1:
				curKey = "medium"
			2:
				curKey = "high"
		
		var points = FzyNoise.getGraph(width, height, curKey)

		draw_polyline(points, colors[i], 5)

func fill_result_graph():
	var fzyDist = Distance.fuzzify(dist)
	var fzyNoise = FzyNoise.fuzzify(noise)
	var inference = InferenceSystem.calculate(fzyDist, fzyNoise)
	
	var filledGraphYes = Deffuzyfier.fillMembership(inference.yes, "yes")
	var filledGraphNo = Deffuzyfier.fillMembership(inference.no, "no")
	
	var merged = Geometry2D.merge_polygons(filledGraphYes, filledGraphNo)
	draw_polygon(Deffuzyfier.scale_polygon(merged[0], width, height), [Color.YELLOW])
	draw_polyline(Deffuzyfier.scale_polygon(merged[0], width, height), Color.YELLOW, 5)
	
	var centroid = Deffuzyfier.calculate_centroid(Deffuzyfier.scale_polygon(merged[0], width, height))
	
	draw_circle(Vector2(centroid.x, centroid.y), 5, Color.RED)

func set_points():
	var fuzzyValue = fuzzy.fuzzify(curValue)
	var marker_x = curValue * x_scale
	
	if graph_value == "Distance":
		#near
		var nearMarker_y = height - (fuzzyValue.near * y_scale)
		draw_circle(Vector2(marker_x, nearMarker_y), 10, Color.RED)
		
		#medium
		var mediumMarker_y = height - (fuzzyValue.medium * y_scale)
		draw_circle(Vector2(marker_x, mediumMarker_y), 10, Color.GREEN)
		
		#far
		var farMarker_y = height - (fuzzyValue.far * y_scale)
		draw_circle(Vector2(marker_x, farMarker_y), 10, Color.BLUE)
	else:
		#low
		var lowMarker_y = height - (fuzzyValue.low * y_scale)
		draw_circle(Vector2(marker_x, lowMarker_y), 10, Color.RED)
		
		#medium
		var mediumMarker_y = height - (fuzzyValue.medium * y_scale)
		draw_circle(Vector2(marker_x, mediumMarker_y), 10, Color.GREEN)
		
		#high
		var highMarker_y = height - (fuzzyValue.high * y_scale)
		draw_circle(Vector2(marker_x, highMarker_y), 10, Color.BLUE)

func _process(delta):
	if graph_value != "Result":
		match graph_value:
			"Distance":
				curValue = dist
				var fuzzyVar = fuzzy.fuzzify(curValue)
				$Label.text = "Distancia: " + str([snapped(fuzzyVar.near, 0.01), snapped(fuzzyVar.medium, 0.01), snapped(fuzzyVar.far, 0.01)])
			"Noise":
				curValue = noise
				var fuzzyVar = fuzzy.fuzzify(curValue)
				$Label.text = "Barulho: " + str([snapped(fuzzyVar.low, 0.01), snapped(fuzzyVar.medium, 0.01), snapped(fuzzyVar.high, 0.01)])
	else:
		var fuzzyDist = Distance.fuzzify(dist)
		var fuzzyNoise = FzyNoise.fuzzify(noise)
		var fuzzyResult = InferenceSystem.calculate(fuzzyDist, fuzzyNoise)
		var defuzzyResult = Deffuzyfier.deffuzify(fuzzyResult)
		
		if fuzzyResult:
			$Label.text = "Resultado: " + str([snapped(fuzzyResult.yes, 0.01), snapped(fuzzyResult.no, 0.01)]) + " / Deffuzy: " + str(snapped(defuzzyResult, 0.01))
		
	queue_redraw()
