extends Node

signal log_msg(msg)

func log(msg: String):
	print_rich(msg)
	emit_signal("log_msg", msg)

