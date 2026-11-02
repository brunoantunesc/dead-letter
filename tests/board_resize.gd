extends SceneTree
var failures: Array = []

func check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func _initialize() -> void:
	_run.call_deferred()

func _settle() -> void:
	for frame in 5: await process_frame

func _run() -> void:
	root.size = Vector2i(1280, 820)
	var desk = load("res://ui/main.tscn").instantiate()
	root.add_child(desk)
	desk.seed_input.text = "995009"
	desk._open_seed()
	await _settle()
	check(desk.inspector_body.get_theme_font_size("normal_font_size") >= 22, "main reading text enlarged")
	check(desk.submit_button.get_global_rect().end.y <= root.size.y and desk.submit_button.get_global_rect().end.x <= root.size.x, "report submission remains visible at 1280x820")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/results/desk_readable.png")
	desk._open_board()
	await _settle()
	var board = desk.board
	board._select_card("room:lobby")
	board._place_selected()
	var before: Vector2 = board.canvas.size
	var position: Vector2 = board.model.cards["room:lobby"].position
	var zoom: float = board.canvas.zoom
	root.size = Vector2i(1600, 1000)
	await _settle()
	check(board.size.is_equal_approx(Vector2(root.size)), "board fills resized window")
	check(board.canvas.size.x > before.x + 250 and board.canvas.size.y > before.y + 120, "canvas grows with window rather than scaling fixed viewport")
	check(board.model.cards["room:lobby"].position == position and board.canvas.zoom == zoom, "resize preserves arrangement and zoom")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/results/board_large.png")
	root.size = Vector2i(1280, 820)
	await _settle()
	check(board.canvas.size.is_equal_approx(before), "canvas shrinks back to original size")
	check(board.model.cards["room:lobby"].position == position, "shrinking preserves card position")
	board.hide()
	root.size = Vector2i(1920, 1080)
	await _settle()
	check(desk.inspector_body.size.x > 600, "reading area expands with a larger main window")
	check(desk.submit_button.get_global_rect().end.y <= root.size.y, "report footer remains visible at 1920x1080")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/results/desk_readable_large.png")
	print("Board resize failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
