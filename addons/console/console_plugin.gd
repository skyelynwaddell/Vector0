@tool
extends EditorPlugin


#Version: 1.0.3
#Contents: View Files
#Description:
#
#Console that can drop down with the ~ key, as seen in games like Quake, that allows developer to add commands to quickly test things.
#
#Simply use "Console.add_command("command_name", <function>, <num_parameters>)" to add console commands!  Parameters are passed in as strings.
#
#Other useful settings:
#Console.enable_on_release_build
#Console.pause_enabled
#Console.enabled
#
#And signals you can connect to:
#console_opened
#console_closed
#console_unknown_command


func _enter_tree():
	print("Console plugin activated.")
	add_autoload_singleton("Console", "res://addons/console/Console.gd")


func _exit_tree():
	remove_autoload_singleton("Console")
