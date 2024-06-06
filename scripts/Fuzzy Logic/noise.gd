extends Node
class_name FzyNoise

static func low(x: float) -> float:
	return FuzzyFunction.trapezoid(x, 0.0, 0.0, 20.0, 45.0)

static func medium(x: float) -> float:
	return FuzzyFunction.trapezoid(x, 30.0, 40.0, 60.0, 70.0)

static func high(x: float) -> float:
	return FuzzyFunction.trapezoid(x, 55.0, 80.0, 100.0, 100.0)

static func fuzzify(x: float):
	return {"low": low(x), "medium": medium(x), "high": high(x)}

static func getGraph(width:float, height:float, fuzzyKey:String):
	var points = []
	var x_scale = width / 100.0
	var y_scale = height / 1.0

	for x in range(0, width + 1, 5):
		var graph_x = (x / x_scale)
		var fuzzyVar = fuzzify(graph_x)
		
		var graph_y = fuzzyVar[fuzzyKey]
		
		var point = Vector2(x, height - (graph_y * y_scale))
		points.append(point)
	
	return points
