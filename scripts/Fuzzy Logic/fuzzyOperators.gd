extends Node
class_name FuzzyOperator

static func AND(x:float, y:float):
	return min(x, y)

static func OR(x:float, y:float):
	return max(x, y)

static func NOT(x:float):
	return 1.0 - x
