extends Node

const COIN = preload("res://scenes/game/coin.tscn")
const BOMB = preload("res://scenes/game/bomb.tscn")

var texture_play = preload("res://assets/graphics/play.png")
var texture_pause = preload("res://assets/graphics/pause.png")

@onready var coin_hover: TextureRect = $CoinHover
@onready var board: Board = $Board
@onready var player_one_name: Label = %PlayerOne
@onready var player_two_name: Label = %PlayerTwo

@onready var player_1_score_label: Label = $VBoxPlayer1/Player1Score
@onready var player_2_score_label: Label = $VBoxPlayer2/Player2Score
@onready var games_left_label: Label = $GamesLeft

@onready var play_pause: TextureButton = %PlayPause
@onready var pause_label: Label = %PauseLabel

@onready var player_timout: Timer = %PlayerTimout

const BOMB_ID: int = 99
var bomb: Bomb = null
var first_bomb_drops_at: int
var second_bomb_drops_at: int
var third_bomb_drops_at: int

var current_turn: int = 1
var round: int = 0
var paused = false

var _explosions_pending: int = 0
signal all_explosions_done

# bot can select predefined colors
# when game is finished the coins drops out of the board

func _ready() -> void:
	_game_reset()
	games_left_label.text = str(GameManager.games_left)
	coin_hover.new_spawn_pos.connect(_spawn)
	Designer.set_label_text(player_one_name, WebsocketServer.get_player_one().name, 30, 250.0)
	Designer.set_label_text(player_two_name, WebsocketServer.get_player_two().name, 30, 250.0)
	_send_update_state()

	WebsocketServer.player_timeout.timeout.connect(player_got_timeout)

func player_got_timeout():
	_game_is_over([int(WebsocketServer.player_one_active) + 1])

func _game_reset():
	current_turn = 1
	first_bomb_drops_at = randi_range(5, 10) 
	second_bomb_drops_at = randi_range(15,20)
	third_bomb_drops_at = randi_range(25,30)

func start():
	_game_reset()
	GameManager.setState(GameManager.GameState.STARTED)
	
func _can_spawn_next():
	return GameManager.getState() != GameManager.GameState.ITEM_FALLING
	
func _any_bomb_to_spawn() -> bool:
	return current_turn == first_bomb_drops_at or current_turn == second_bomb_drops_at or current_turn == third_bomb_drops_at

func _is_any_bomb_ticking() -> bool:
	return (current_turn > first_bomb_drops_at or current_turn > second_bomb_drops_at or current_turn > third_bomb_drops_at) and is_instance_valid(bomb)

func _next():
	GameManager.setState(GameManager.GameState.NEXT)
	current_turn += 1
	if _any_bomb_to_spawn():
		_spawn_bomb()
		return
		
	if _is_any_bomb_ticking():
		var about_to_explode = bomb.tick()
		if about_to_explode:
			return

	if WebsocketServer.player_one_active and WebsocketServer.is_player_one_bot() or not WebsocketServer.player_one_active and WebsocketServer.is_player_two_bot():
		_send_update_state()
	
func _bomb_dropped():
	if WebsocketServer.player_one_active and WebsocketServer.is_player_one_bot() or not WebsocketServer.player_one_active and WebsocketServer.is_player_two_bot():
		_send_update_state()
	GameManager.setState(GameManager.GameState.NEXT)
		
func _send_update_state():
	if WebsocketServer.get_active_bot():
		var bomb_data = _get_all_bomb_data()
		var payload = {
			"bot": WebsocketServer.get_active_bot().name,
			"coin_id": WebsocketServer.get_active_bot().id,
			"round": current_turn,
			"bombs": bomb_data,
			"board": board.board
		}
		WebsocketServer.send(JSON.stringify(payload))
	
func _get_all_bomb_data():
	var bomb_data = []
	for child in get_children():
		if child is Bomb:
			if child.boom_in_round > current_turn:
				bomb_data.append({
					"row": child.final_destination_row, 
					"col": child.final_destination_col, 
					"explode_in_round": child.boom_in_round})
	return bomb_data
	
func finish():
	_explosions_pending = 0
	GameManager.setState(GameManager.GameState.FINISHED)
	board.init()
	for child in get_children():
		if child is Coin or child is Bomb:
			child.free()
	if GameManager.games_left > 0:
		start()
		_send_update_state()
	else:
		paused = false
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/results/results.tscn")

func _spawn(position: Vector2, column: int) -> void:
	var new_coin = COIN.instantiate()
	add_child(new_coin)
	if not WebsocketServer.player_one_active:
		new_coin.change_chip()
	new_coin.position = position
	new_coin.set_column(column)
	
	_switch_player()
	var player_id = int(WebsocketServer.player_one_active) + 1
	var row = board.insert(player_id, column)
	if row != -1:
		new_coin.set_row(row)
		new_coin.end_movement.connect(_update_game)
	else:
		new_coin.is_wrong()
		_game_is_over([int(not WebsocketServer.player_one_active) + 1])
		player_1_score_label.text = str(GameManager.player_1_score)
		player_2_score_label.text = str(GameManager.player_2_score)
		games_left_label.text = str(GameManager.games_left)
	
func _spawn_bomb():
	const tile_size: int = 64
	const offset: int = 5
	const max_columns: int = 7
	const height: int = 146
	bomb = BOMB.instantiate()
	var rand_column = randi_range(0, max_columns - 1)
	while board.get_free_row(rand_column) == -1:
		rand_column = randi_range(0, max_columns - 1)
	
	var position = Vector2(offset * tile_size + rand_column * tile_size + tile_size/2, height)
	bomb.position = position
	bomb.set_boom_info(current_turn)
	var row = board.insert(BOMB_ID, rand_column)
	bomb.set_final_destination(row, rand_column)
	bomb.detonate.connect(_detonate)
	bomb.dropped.connect(_bomb_dropped)
	add_child(bomb)

func _detonate(row: int, col: int):
	GameManager.setState(GameManager.GameState.EXPLOSION)
	var exploding_coins = board.update_after_detonation(row, col)
	if len(exploding_coins) == 0:
		GameManager.setState(GameManager.GameState.NEXT)
		if WebsocketServer.player_one_active and WebsocketServer.is_player_one_bot() or not WebsocketServer.player_one_active and WebsocketServer.is_player_two_bot():
			_send_update_state()
		return
		
	for child in get_children():
		if child is Coin:
			if exploding_coins.has(Vector2(child.row, child.column)):
				_explosions_pending += 1
				child.exploded.connect(_on_chip_exploded, CONNECT_ONE_SHOT)
				child.explode()
		
	await all_explosions_done
	_update_coin_rows(exploding_coins)
	var winners = board.detect_winner_full_scan()
	if winners.size() > 0:
		_highlight(board.get_winning_coins())
		_game_is_over(winners)
		return
		
	GameManager.setState(GameManager.GameState.NEXT)
	if WebsocketServer.player_one_active and WebsocketServer.is_player_one_bot() or not WebsocketServer.player_one_active and WebsocketServer.is_player_two_bot():
		_send_update_state()
	
func _on_chip_exploded():
	_explosions_pending -= 1
	if _explosions_pending == 0:
		all_explosions_done.emit()
		
func _switch_player():
	WebsocketServer.player_one_active = not WebsocketServer.player_one_active
		
func _update_game(column: int):
	var player_id = int(WebsocketServer.player_one_active) + 1
	var won = board.is_winner(player_id)
	if won:
		_highlight(board.get_winning_coins())
		_game_is_over([player_id])
	else:
		_next()
	
func _highlight(coins: Array[Vector2]) -> void:
	for child in get_children():
		if child is Coin:
			if coins.has(Vector2(child.row, child.column)):
				child.highlight()
				
func _update_coin_rows(exploding_coins: Array[Vector2]):
	var all_coins = []
	for child in get_children():
		if child is Coin:
			all_coins.append(child)
		elif child is Bomb:
			exploding_coins.append(Vector2(child.final_destination_row,child.final_destination_col))

	var coins_without_explodings = all_coins.filter(func(coin): return not exploding_coins.has(Vector2(coin.row,coin.column)))
	
	for exploding_coin in exploding_coins:
		var coins_same_column_without_exploding = coins_without_explodings.filter(func(coin): return coin.column == exploding_coin.y)
		for coin_same_column in coins_same_column_without_exploding:
			if coin_same_column.row >= exploding_coin.x:
				coin_same_column.row = coin_same_column.row - 1

func _on_play_pause_pressed() -> void:
	paused = not paused
	get_tree().paused = paused
	if paused:
		pause_label.visible = true
		play_pause.texture_normal = texture_play
	else:
		pause_label.visible = false
		play_pause.texture_normal = texture_pause
	
func _game_is_over(player_ids: Array[int]) -> void:
	GameManager.won(player_ids)
	player_1_score_label.text = str(GameManager.player_1_score)
	player_2_score_label.text = str(GameManager.player_2_score)
	games_left_label.text = str(GameManager.games_left)

	GameManager.set_next_starting_player()
	coin_hover.update_chip_to_next_starting_player()

	await get_tree().create_timer(1).timeout
	finish()
