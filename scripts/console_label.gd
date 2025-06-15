extends RichTextLabel

func PlayAnim():
	%AnimationPlayer.play("fade")

func Destroy():
	queue_free()
