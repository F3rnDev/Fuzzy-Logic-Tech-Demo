extends Node
class_name Result

static func no(x: float) -> float:
	return FuzzyFunction.trapezoid(x, 0.0, 0.0, 50.0, 65.0)

static func yes(x: float) -> float:
	return FuzzyFunction.trapezoid(x, 35.0, 50.0, 100.0, 100.0)

static func getGraph(width:float, height:float, fuzzyKey:String):
	var points = []
	var x_scale = width / 100.0
	
	var y_scale = height / 1.0

	for x in range(0, width + 1, 5):
		var graph_x = (x / x_scale)
		var fuzzyVar = {"yes": yes(graph_x), "no": no(graph_x)}
		
		var graph_y = fuzzyVar[fuzzyKey]
		
		var point = Vector2(x, height - (graph_y * y_scale))
		points.append(point)
	
	return points
