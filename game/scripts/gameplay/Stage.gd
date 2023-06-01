# Attach this Script to any desired stage scene to have some very
# useful helpers to your stage for cameras and such
class_name Stage extends Node2D

@export_category("Stage Positioning")
@export var player_position:Vector2 = Vector2(770, 450)
@export var spectator_position:Vector2 = Vector2(400, 130)
@export var cpu_position:Vector2 = Vector2(100, 100)

@export_category("Stage Camera")
@export var camera_zoom:float = 1.05
@export var camera_speed:float = 1.0

@export var player_camera:Vector2 = Vector2.ZERO
@export var crowd_camera:Vector2 = Vector2.ZERO
@export var cpu_camera:Vector2 = Vector2.ZERO
