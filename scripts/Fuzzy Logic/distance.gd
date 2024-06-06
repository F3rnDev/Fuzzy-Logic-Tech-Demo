extends Node
class_name Distance

static func near(x: float) -> float:
	return FuzzyFunction.trapezoid(x, 0.0, 0.0, 1.5, 2.5)

static func medium(x: float) -> float:
	return FuzzyFunction.triangle(x, 1.5, 2.5, 3.5)

static func far(x: float) -> float:
	return FuzzyFunction.trapezoid(x, 2.5, 3.5, 5.0, 5.0)

static func fuzzify(x: float):
	return {"near": near(x), "medium": medium(x), "far": far(x)}

static func getGraph(width:float, height:float, fuzzyKey:String):
	var points = []
	var x_scale = width / 5.0
	var y_scale = height / 1.0

	for x in range(0, width + 1, 5):
		var graph_x = (x / x_scale)
		var fuzzyVar = fuzzify(graph_x)
		
		var graph_y = fuzzyVar[fuzzyKey]
		
		var point = Vector2(x, height - (graph_y * y_scale))
		points.append(point)
	
	return points

static func getPoints():
	pass
