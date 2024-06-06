extends Control

# Pontos para desenhar os polígonos
var points_yes = []
var points_no = []
var points_merged = []

# Cores para os polígonos
var color_yes = Color(0, 1, 0, 0.2)  # Verde semi-transparente
var color_no = Color(1, 0, 0, 0.2)   # Vermelho semi-transparente
var color_merge = Color.YELLOW

# Valores fuzzy (exemplo)
var heardPlayer = {"yes": 0.2, "no": 0.8}

func _ready():
	# Gerar pontos para os gráficos de pertinência
	points_yes = Result.fillMembership(heardPlayer["yes"], "yes")
	points_no = Result.fillMembership(heardPlayer["no"], "no")

func _draw():
	print("Points yes: ", points_yes)
	print("Points no: ", points_no)
	
	var merged = Geometry2D.merge_polygons(points_yes, points_no)
	draw_polygon(Result.scale_polygon(merged[0], size.x, size.y), [color_merge])
#
#	print("Expected result: ", [Vector2(0, 80)])

#	# Desenhar os polígonos de pertinência
#	if points_yes.size() > 1:
#		draw_polygon(points_yes, [color_yes])
#	if points_no.size() > 1:
#		draw_polygon(points_no, [color_no])
#
#	# Desenhar os contornos dos polígonos
#	if points_yes.size() > 1:
#		draw_polyline(points_yes, color_yes, 2)
#	if points_no.size() > 1:
#		draw_polyline(points_no, color_no, 2)
