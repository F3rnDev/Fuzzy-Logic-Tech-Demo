extends Node
class_name InferenceSystem
#--TABLE--
#	near (perto)	|	low (baixo)		|	Sim
#	near (perto)	|	medium (médio)	|	Sim
#	near (perto)	|	high (alto)		|	Sim
#	medium (médio)	|	low (baixo)		|	Não
#	medium (médio)	|	medium (médio)	|	Sim
#	medium (médio)	|	high (alto)		|	Sim
#	far (longe)		|	low (baixo)		|	Não
#	far (longe)		|	medium (médio)	|	Não
#	far (longe)		|	high (alto)		|	Sim
	
#--STATEMENTS--
	#IF near THEN yes
	
	#IF medium AND low THEN no
	#IF medium AND medium OR medium AND high THEN yes

	#IF far AND low OR far AND medium THEN no
	#IF far AND high THEN yes
#

static func calculate(distance:Dictionary, noise:Dictionary):
	var heardPlayer = {"yes": 0.0, "no": 0.0}
	
	#IF near THEN yes
	heardPlayer.yes = FuzzyOperator.OR(heardPlayer.yes, distance.near)
	
	#IF medium AND low THEN no
	var r2Operator = FuzzyOperator.AND(distance.medium, noise.low)
	heardPlayer.no = FuzzyOperator.OR(heardPlayer.no, r2Operator)
	
	#IF medium AND medium OR medium AND high THEN yes
	var r3State1 = FuzzyOperator.AND(distance.medium, noise.medium)
	var r3State2 = FuzzyOperator.AND(distance.medium, noise.high)
	var r3Operator = FuzzyOperator.OR(r3State1, r3State2)
	
	heardPlayer.yes = FuzzyOperator.OR(heardPlayer.yes, r3Operator)
	
	#IF far AND low OR far AND medium THEN no
	var r4State1 = FuzzyOperator.AND(distance.far, noise.low)
	var r4State2 = FuzzyOperator.AND(distance.far, noise.medium)
	var r4Operator = FuzzyOperator.OR(r4State1, r4State2)
	
	heardPlayer.no = FuzzyOperator.OR(heardPlayer.no, r4Operator)
	
	#IF far AND high THEN yes
	var r5Operator = FuzzyOperator.AND(distance.far, noise.high)
	heardPlayer.yes = FuzzyOperator.OR(heardPlayer.yes, r5Operator)
	
	return heardPlayer
