extends Sprite

func _on_Coin_area_entered(area):
	print(area.get_name())
	if "Player" in area.get_name():
		queue_free()

func _on_Coin_body_entered(body):
	print("Collision")
