extends Node
class_name FuzzyFunction

static func triangle(x: float, a: float, b: float, c: float) -> float:
	var result = max(min((x - a) / (b - a), (c - x) / (c - b)), 0)
	
	return result

static func trapezoid(x: float, a: float, b: float, c: float, d: float) -> float:
	var result = max(min((x - a) / (b - a), 1, (d - x) / (d - c)), 0)
	
	return result

static func isNan(value:float):
	return value != value
