extends Node
class_name Deffuzyfier

static func deffuzify(fuzzyOutput:Dictionary) -> float:
	#PREENCHIMENTO
	#Preenche o gráfico do SIM e do NÃO. Gerando um poligono para cada função.
	var yesFilled = fillMembership(fuzzyOutput.yes, "yes")
	var noFilled = fillMembership(fuzzyOutput.no, "no")
	
	#COMBINAÇÃO
	#Unifica os dois poligonos gerados em um só
	var merged = Geometry2D.merge_polygons(yesFilled, noFilled)
	
	#CENTROID
	#calcula a centroid desse poligono e retorna seu valor X.
	if merged[0].size() > 0:
		var centroid = calculate_centroid(merged[0])
		return centroid.x
	
	return 0.0

static func fillMembership(fuzzy_value: float, fuzzyKey: String):
	var step_size = 1.0
	var num_steps = 100
	var points = []

	for i in range(num_steps + 1):
		var x = i * step_size
		var membership = 0.0

		if fuzzyKey == "yes":
			membership = Result.yes(x)
		elif fuzzyKey == "no":
			membership = Result.no(x)
		
		var y = min(fuzzy_value, membership)
		
		points.append(Vector2(x, y))

	points.append(Vector2(num_steps * step_size, 0.0))
	points.append(Vector2(0, 0.0))

	return points

static func calculate_centroid(points: Array) -> Vector2:
	var n = points.size()
	var A = 0.0
	var C_x = 0.0
	var C_y = 0.0

	for i in range(n):
		var j = (i + 1) % n
		var x0 = points[i].x
		var y0 = points[i].y
		var x1 = points[j].x
		var y1 = points[j].y
		var cross = x0 * y1 - x1 * y0
		A += cross
		C_x += (x0 + x1) * cross
		C_y += (y0 + y1) * cross

	A *= 0.5
	C_x /= (6.0 * A)
	C_y /= (6.0 * A)

	return Vector2(C_x, C_y)


static func scale_polygon(points: Array, width: float, height: float) -> Array:
	var x_scale = width / 100.0
	var y_scale = height / 1.0

	var scaled_points = []

	for point in points:
		var scaled_x = point.x * x_scale
		var scaled_y = point.y * y_scale
		scaled_points.append(Vector2(scaled_x, height - scaled_y))

	return scaled_points
