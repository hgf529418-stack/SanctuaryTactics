extends Control

# A deliberately small combat test. Only the player's first lane is interactive.
const ATTACK_DAMAGE := 1
const STARTING_HP := 2
const MAX_LANE_HEALTH := 3

var turn_number := 1
var opponent_hp := STARTING_HP
var opponent_lane_health := MAX_LANE_HEALTH
var attack_available := true
var attacker_selected := false

@onready var player_slot: PanelContainer = $Margin/Layout/PlayerLanes/Lane1/MonsterSlot
@onready var opponent_slot: PanelContainer = $Margin/Layout/OpponentLanes/Lane1/MonsterSlot
@onready var player_info: Label = $Margin/Layout/PlayerLanes/Lane1/MonsterSlot/Info
@onready var opponent_info: Label = $Margin/Layout/OpponentLanes/Lane1/MonsterSlot/Info
@onready var lane_health_label: Label = $Margin/Layout/OpponentLanes/Lane1/LaneHealth
@onready var turn_label: Label = $Margin/Layout/Turn
@onready var message_label: Label = $Margin/Layout/BattleCenter
@onready var end_turn_button: Button = $Margin/Layout/Footer/EndTurn
@onready var reset_button: Button = $Margin/Layout/Footer/ResetTest

func _ready() -> void:
	player_slot.gui_input.connect(_on_player_slot_input)
	opponent_slot.gui_input.connect(_on_opponent_slot_input)
	end_turn_button.pressed.connect(_on_end_turn)
	reset_button.pressed.connect(_reset_test)
	_show_message("Tap your monster in lane 1.")
	_refresh_board()

func _is_press(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if event is InputEventScreenTouch:
		return event.pressed
	return false

func _on_player_slot_input(event: InputEvent) -> void:
	if not _is_press(event):
		return
	player_slot.accept_event()
	if not attack_available:
		_show_message("Already attacked. Tap End Turn.")
		return
	if opponent_lane_health <= 0:
		_show_message("Lane destroyed. Tap Reset Test.")
		return
	attacker_selected = true
	_show_message("Selected! Tap opponent lane 1.")
	_refresh_board()

func _on_opponent_slot_input(event: InputEvent) -> void:
	if not _is_press(event):
		return
	opponent_slot.accept_event()
	if not attacker_selected or not attack_available:
		_show_message("Select your lane 1 monster first.")
		return
	attacker_selected = false
	attack_available = false
	if opponent_hp > 0:
		opponent_hp = maxi(0, opponent_hp - ATTACK_DAMAGE)
		if opponent_hp == 0:
			_show_message("Monster defeated! Lane 1 is open.")
		else:
			_show_message("Hit! Opponent lost 1 HP.")
	else:
		opponent_lane_health = maxi(0, opponent_lane_health - 1)
		if opponent_lane_health == 0:
			_show_message("Lane 1 destroyed! Tap Reset Test.")
		else:
			_show_message("Direct strike! Lane 1 lost 1 marker.")
	_refresh_board()

func _on_end_turn() -> void:
	turn_number += 1
	attack_available = true
	attacker_selected = false
	_show_message("New test turn. Tap your monster.")
	_refresh_board()

func _reset_test() -> void:
	turn_number = 1
	opponent_hp = STARTING_HP
	opponent_lane_health = MAX_LANE_HEALTH
	attack_available = true
	attacker_selected = false
	_show_message("Test reset. Tap your monster.")
	_refresh_board()

func _show_message(message: String) -> void:
	message_label.text = message

func _refresh_board() -> void:
	turn_label.text = "LANE 1 COMBAT TEST  •  TURN %d" % turn_number
	var attack_status := "READY" if attack_available else "USED"
	if attacker_selected:
		attack_status = "SELECTED"
	player_info.text = "TEST MONSTER\nHP 2  |  ATK 1\nATTACK: %s" % attack_status
	if opponent_lane_health <= 0:
		opponent_info.text = "LANE\nDESTROYED"
	elif opponent_hp > 0:
		opponent_info.text = "TRAINING MONSTER\nHP %d  |  ATK —" % opponent_hp
	else:
		opponent_info.text = "EMPTY LANE\nDIRECT STRIKE"
	var markers := ""
	for i in range(MAX_LANE_HEALTH):
		markers += "● " if i < opponent_lane_health else "○ "
	lane_health_label.text = "LANE 1  " + markers.strip_edges()
