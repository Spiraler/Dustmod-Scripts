#include "SeedGenerator.as"
const string EMBED_HARDDROP = "harddrop.ogg";
const string EMBED_HOLD = "hold.ogg";
const string EMBED_LINECLEAR = "lineclear.ogg";
const string EMBED_TETRIS = "tetris.ogg";

class script : callback_base {
  scene@ g;
  canvas@ text_canvas, hold_canvas, next_canvas, middle_canvas, timer_canvas;
  textfield@ print_text_field, hold_text, next_text, middle_text, timer_text;
  [position, mode:WORLD, layer:19, y:fixed_y]
    float fixed_x;
    [hidden]
    float fixed_y;
    
  [text] float screen_height;
    
  float scale_x, scale_y;
	
  array<array<int>> board(24, array<int>(10));
  int boardX, boardY, blockWidth;
	
  piece currentPiece;
  array<int> nextQ(161);
  dustman@ player;
  
  int holdPiece, holdX2, holdX3, holdX4, holdY1, holdY2;
  bool usedHold;
  int gravTimer;
	
  int dasLeftTimer, dasRightTimer;
  bool hdsb, rlsb, rrsb, oesb, hsb;
  // safety booleans to make sure holding those buttons doesn't do nonsense
	
  [position, mode:WORLD, layer:19, y:lines_y]
    float lines_x;
    [hidden]
    float lines_y;
	
  [position, mode:WORLD, layer:19, y:hold_y]
    float hold_x;
    [hidden]
    float hold_y;
	
  [position, mode:WORLD, layer:19, y:next_y]
    float next_x;
    [hidden]
    float next_y;
	
  [position, mode:WORLD, layer:19, y:middle_y]
    float middle_x;
    [hidden]
    float middle_y;
	
  [position, mode:WORLD, layer:19, y:timer_y]
    float timer_x;
    [hidden]
    float timer_y;
	
  int holdX, holdY, nextX, nextY;
  
  int linesCleared;
  
  [text] SeedGenerator s;
  uint seed;
  int stepCount;
  
  bool triggerEnd;
  int endCountdown;
  
  [entity] uint apple;
  
  int overallTimer;
	
  script() { 
    @g = get_scene();
	s = SeedGenerator();
	
	@text_canvas = create_canvas(false, 20, 15);
	@hold_canvas = create_canvas(false, 20, 16);
	@next_canvas = create_canvas(false, 20, 17);
	@middle_canvas = create_canvas(false, 20, 18);
	@timer_canvas = create_canvas(false, 20, 15);
	@print_text_field = create_textfield();
        print_text_field.set_font("sans_bold", 36);
        print_text_field.align_horizontal(1);
        print_text_field.align_vertical(1);
	@hold_text = create_textfield();
        hold_text.set_font("ProximaNovaReg", 36);
        hold_text.align_horizontal(1);
        hold_text.align_vertical(1);
	@next_text = create_textfield();
        next_text.set_font("ProximaNovaReg", 36);
        next_text.align_horizontal(1);
        next_text.align_vertical(1);
	@middle_text = create_textfield();
        middle_text.set_font("ProximaNovaReg", 100);
        middle_text.align_horizontal(0);
        middle_text.align_vertical(1);
		middle_text.colour(0x40FFFFFF);
	@timer_text = create_textfield();
        timer_text.set_font("sans_bold", 36);
        timer_text.align_horizontal(1);
        timer_text.align_vertical(1);
		
	boardX = -192;
	boardY = -1872;
	blockWidth = 48;
	
	holdX = -480;
	holdY = -1632;
	nextX = 336;
	nextY = -1632;
	
	triggerEnd = false;
  }
  
  void CheckThings(string id, message@ msg) {
	  
  }
 
  void on_level_start() {
	  g.disable_score_overlay(true);
	  overallTimer = 0;
	  @player = controller_controllable(0).as_dustman();
	  
	  s.locateEncoders();
      stepCount = 0;
	  
	  if(screen_height > 0)
            scale_x = scale_y = 1080 / screen_height;
        
      camera@ cam = get_active_camera();
        
      cam.script_camera(true);
        
      fix_camera(cam);
      fix_prev_camera(cam);
	  
	  for (int i = 0; i < 24; i++) {
			for (int j = 0; j < 10; j++) {
				board[i][j] = 0;
			}
	    }
		
	  dasLeftTimer = 0;
	  dasRightTimer = 0;
	  
	  hdsb = true;
	  rlsb = true;
	  rrsb = true;
	  oesb = true;
	  hsb = true;
	  
	  holdPiece = 0;
	  usedHold = false;
	  gravTimer = 60;
	  
	  linesCleared = 0;
	  
	  endCountdown = 3;
  }
  
      void fix_prev_camera(camera@ cam) {
        cam.prev_x(fixed_x);
        cam.prev_y(fixed_y);
        
        if(screen_height > 0) {
            cam.prev_scale_x(scale_x);
            cam.prev_scale_y(scale_y);
        }
    }
    
    void fix_camera(camera@ cam) {
        cam.x(fixed_x);
        cam.y(fixed_y);
        
        if(screen_height > 0) {
            cam.scale_x(scale_x);
            cam.scale_y(scale_y);
        }
    }

  void editor_draw(float sub_frame) {
	  text_canvas.draw_text(print_text_field, lines_x, lines_y, 1, 1, 0);
	  hold_canvas.draw_text(hold_text, hold_x, hold_y, 1, 1, 0);
	  next_canvas.draw_text(next_text, next_x, next_y, 1, 1, 0);
	  timer_canvas.draw_text(timer_text, timer_x, timer_y, 2, 2, 0);
	  middle_canvas.draw_text(middle_text, middle_x, middle_y, 2, 2, 0);
  }
  
  void editor_step() {
	  print_text_field.text("Lines: 0/40");
	  hold_text.text("Hold");
	  next_text.text("Next");
	  middle_text.text("40");
	  timer_text.text("timer");
  }

  void step(int entities) {
	  if (triggerEnd) {
		  if (endCountdown == 0)
			  g.end_level(0, 0);
		  else
			  endCountdown--;
	  } else {
		  overallTimer++;
		  string timeText = "" + overallTimer / 3600 + ":";
		  int seconds = (overallTimer / 60) % 60;
		  if (seconds < 10)
			  timeText = timeText + "0";
		  timeText = timeText + seconds + ".";
		  int mseconds = (overallTimer % 60) * 100 / 60;
		  if (mseconds < 10)
			  timeText = timeText + "0";
		  timeText = timeText + mseconds;
		  timer_text.text(timeText);
	  }
	  
	  if (stepCount < 25) {
		  stepCount++;
	  }
	  if (stepCount == 13) {
		  if (!is_replay())
			seed = s.generateSeed();
	  }		  
	  if (stepCount == 25) {
		  if (is_replay()) {
			  seed = s.calculateSeed();
		  }
		  generateBags();
		  currentPiece = piece(popNext());
		  stepCount = 527;
	  }
	  
	  if (gravTimer == 0) {
		  currentPiece.downOne(board);
		  gravTimer = 60;
	  } else {
		  gravTimer--;
	  }
	  
	  if (player.x_intent() == -1) {
		  dasLeftTimer++;
		  if (dasLeftTimer == 1) {
			  currentPiece.moveLeft(board);
		  }
		  if (dasLeftTimer >= 7) {
			  currentPiece.dasLeft(board);
		  }
	  } else {
		  dasLeftTimer = 0;
	  }
	  if (player.x_intent() == 1) {
		  dasRightTimer++;
		  if (dasRightTimer == 1) {
			  currentPiece.moveRight(board);
		  }
		  if (dasRightTimer >= 7) {
			  currentPiece.dasRight(board);
		  }
	  } else {
		  dasRightTimer = 0;
	  }
	  
	  if (player.y_intent() == 1) {
		  softDrop();
	  }
	  if (player.y_intent() == -1) {
		  if (hdsb) {
			  hardDrop();
			  hdsb = false;
		  }
	  } else {
		  hdsb = true;
	  }
	  
	  if (player.heavy_intent() == 10) {
		  if (rrsb) {
			  currentPiece.rotateRight(board);
			  rrsb = false;
			  player.heavy_intent(11);
		  }
	  } else {
		  rrsb = true;
	  }
	  if (player.light_intent() == 10) {
		  if (rlsb) {
			  currentPiece.rotateLeft(board);
			  rlsb = false;
			  player.light_intent(11);
		  }
	  } else {
		  rlsb = true;
	  }
	  if (player.dash_intent() == 1) {
		  if (hsb) {
			  hold();
			  hsb = false;
			  player.dash_intent(2);
		  }
	  } else {
		  hsb = true;
	  }
	  if (player.jump_intent() == 1) {
		  if (oesb) {
			  currentPiece.rotate180(board);
			  oesb = false;
			  player.jump_intent(2);
		  }
	  } else {
		  oesb = true;
	  }
	  
	  print_text_field.text("Lines: " + linesCleared + "/40");
	  middle_text.text("" + (40 - linesCleared));
	  hold_text.text("Hold");
	  next_text.text("Next");
  }

  void draw(float subframe) {
	  drawBoard();
	  drawHold();
	  drawNext();
	  currentPiece.draw(g, board);
	  
	  text_canvas.draw_text(print_text_field, lines_x, lines_y, 1, 1, 0);
	  hold_canvas.draw_text(hold_text, hold_x, hold_y, 1, 1, 0);
	  next_canvas.draw_text(next_text, next_x, next_y, 1, 1, 0);
	  timer_canvas.draw_text(timer_text, timer_x, timer_y, 2, 2, 0);
	  middle_canvas.draw_text(middle_text, middle_x, middle_y, 2, 2, 0); 
  }
  
  void softDrop() {
	  currentPiece.drop(board);
  }
  
  void hardDrop() {
	  currentPiece.instantDrop(board);
	  place();
  }
  
  void hold() {
	  if (!usedHold) {
		  if (holdPiece == 0) {
			  holdPiece = currentPiece.getLetter();
			  currentPiece = piece(popNext());
		  } else {
			  int temp = currentPiece.getLetter();
			  currentPiece = piece(holdPiece);
			  holdPiece = temp;
		  }
		  usedHold = true;
		  audio@ abc = g.play_script_stream("HOLD", 0, 0, 0, false, 1);
		  abc.time_scale(0.5);
		  gravTimer = 60;
	  }
  }
  
  void drawHold() {
	  if (holdPiece != 0) {
		  drawPieceAt(holdPiece, holdX, holdY);
	  }
  }
  
  void drawNext() {
	  for (int i = 0; i < 5; i++) {
		  drawPieceAt(nextQ[i], nextX, nextY + (blockWidth * 3 * i));
	  }
  }
  
  void generateBags() {
	  srand(seed);
	  for (int i = 0; i < 22; i++) {
		  array<int> bag = {1, 2, 3, 4, 5, 6, 7};
		  for (int j = 7; j > 0; j--) {
			  uint chosen = rand() % j;
			  nextQ[(7 * i) + 7 - j] = bag[chosen];
			  bag.removeAt(chosen);
		  }
	  }
  }
  
  int popNext() {
	  int tr = nextQ[0];
	  nextQ.removeAt(0);
	  return tr;
  }
  
  int checkNext() {
	  return nextQ[0];
  }
  
  void place() {
	  array<int> cx = currentPiece.xs();
	  array<int> cy = currentPiece.ys();
	  for (int i = 0; i < 4; i++) {
		  board[cy[i]][cx[i]] = currentPiece.getLetter();
	  }
	  
	  audio@ ab = g.play_script_stream("HARDDROP", 0, 0, 0, false, 1);
	  ab.time_scale(0.5);
	  
	  int cleared = clearLines();
	  if (cleared > 0) {
		  audio@ a = g.play_script_stream("LINECLEAR", 0, 0, 0, false, 1);
		  a.time_scale(0.5);
	  }
	  if (cleared == 4) {
		  audio@ a = g.play_script_stream("TETRIS", 0, 0, 0, false, 1);
	  }
	  
	  bool death = checkDead(cleared);
	  if (death) {
		  if (checkSecretGrade()) {
			  hitTheApple();
			  triggerEnd = true;
		  } else {
			  player.kill(false);
		  }
	  }
	  
	  linesCleared += cleared;
	  
	  if (linesCleared >= 40) {
		  triggerEnd = true;
		  linesCleared = 40;
	  }
	  
	  currentPiece = piece(popNext());
	  usedHold = false;
	  gravTimer = 60;
  }
  
  int clearLines() {
	  int cleared = 0;
	  for (int i = 0; i < 24; i++) {
		  bool full = true;
		  for (int j = 0; j < 10; j++) {
			  if (board[i][j] == 0) {
				  full = false;
			  }
		  }
		  if (full) {
			  cleared++;
			  for (int k = i; k > 0; k--) {
				  board[k] = board[k - 1];
			  }
			  for (int k = 0; k < 10; k++) {
				  board[0][k] = 0;
			  }
		  }
	  }
	  return cleared;
  }
  
  bool checkDead(int cleared) {
	  bool killByHeight = false;
	  if (cleared == 0) {
		  killByHeight = true;
		  array<int> over = currentPiece.ys();
		  for (int i = 0; i < 4; i++) {
			  if (over[i] > 2) {
				  killByHeight = false;
			  }
		  }
	  }
	  if (killByHeight) {
		  return true;
	  } else {
		  piece test = piece(checkNext());
		  array<int> testX = test.xs();
		  array<int> testY = test.ys();
		  for (int i = 0; i < 4; i++) {
			  if (board[testY[i]][testX[i]] != 0) {
				  return true;
			  }
		  }
	  }
	  return false;
  }
  
  bool checkSecretGrade() {
	  for (int i = 23; i > 13; i--) {
		  for (int j = 0; j < 10; j++) {
			  if (j == 23 - i) {
				  if (board[i][j] != 0)
					  return false;
			  } else {
				  if (board[i][j] == 0)
					  return false;
			  }
		  }
	  }
	  for (int i = 13; i > 4; i--) {
		  for (int j = 0; j < 10; j++) {
			  if (j == i - 5) {
				  if (board[i][j] != 0)
					  return false;
			  } else {
				  if (board[i][j] == 0)
					  return false;
			  }
		  }
	  }
	  if (board[4][0] == 0)
		  return false;
	  return true;
  }
  
  void hitTheApple() {
	  controllable@ thePlayer = controller_controllable(0);
	  hitbox@ h = create_hitbox(thePlayer, 0, entity_by_id(apple).x(), entity_by_id(apple).y(), -5, 5, -5, 5);
	  g.add_entity(h.as_entity(), false);
  }
  
  void drawBoard() {
	  for (int i = 0; i < 24; i++) {
		  for (int j = 0; j < 10; j++) {
			  if (board[i][j] != 0) {
				  int X1 = boardX + blockWidth * j;
				  int Y1 = boardY + blockWidth * i;
				  g.draw_rectangle_world(18, 10, X1, Y1, X1 + blockWidth, Y1 + blockWidth, 0, getColor(board[i][j]));
			  }
		  }
	  }
  }
  
  void drawPieceAt(int letter, int x, int y) {
	    // only for hold and next queue, draws each piece centered in a 3x5 cell area with top left corner (x,y)
		switch (letter) {
			case 1:
				g.draw_rectangle_world(18, 10, x + (blockWidth * 0.5), y + blockWidth, x + (blockWidth * 4.5), y + (blockWidth * 2), 0, getColor(letter));
				break;
			case 2:
				g.draw_rectangle_world(18, 10, x + blockWidth, y + (blockWidth * 0.5), x + (blockWidth * 2), y + (blockWidth * 1.5), 0, getColor(letter));
				g.draw_rectangle_world(18, 10, x + blockWidth, y + (blockWidth * 1.5), x + (blockWidth * 4), y + (blockWidth * 2.5), 0, getColor(letter));
				break;
			case 3:
				g.draw_rectangle_world(18, 10, x + (blockWidth * 3), y + (blockWidth * 0.5), x + (blockWidth * 4), y + (blockWidth * 1.5), 0, getColor(letter));
				g.draw_rectangle_world(18, 10, x + blockWidth, y + (blockWidth * 1.5), x + (blockWidth * 4), y + (blockWidth * 2.5), 0, getColor(letter));
				break;
			case 4:
				g.draw_rectangle_world(18, 10, x + (blockWidth * 1.5), y + (blockWidth * 0.5), x + (blockWidth * 3.5), y + (blockWidth * 2.5), 0, getColor(letter));
				break;
			case 5:
				g.draw_rectangle_world(18, 10, x + (blockWidth * 2), y + (blockWidth * 0.5), x + (blockWidth * 4), y + (blockWidth * 1.5), 0, getColor(letter));
				g.draw_rectangle_world(18, 10, x + blockWidth, y + (blockWidth * 1.5), x + (blockWidth * 3), y + (blockWidth * 2.5), 0, getColor(letter));
				break;
			case 6:
				g.draw_rectangle_world(18, 10, x + (blockWidth * 2), y + (blockWidth * 0.5), x + (blockWidth * 3), y + (blockWidth * 1.5), 0, getColor(letter));
				g.draw_rectangle_world(18, 10, x + blockWidth, y + (blockWidth * 1.5), x + (blockWidth * 4), y + (blockWidth * 2.5), 0, getColor(letter));
				break;
			case 7:
				g.draw_rectangle_world(18, 10, x + (blockWidth * 2), y + (blockWidth * 1.5), x + (blockWidth * 4), y + (blockWidth * 2.5), 0, getColor(letter));
				g.draw_rectangle_world(18, 10, x + blockWidth, y + (blockWidth * 0.5), x + (blockWidth * 3), y + (blockWidth * 1.5), 0, getColor(letter));
				break;
		}
  }
  
  uint getColor(int color) {
	  uint tr = 0;
	  switch (color) {
		case 1:
			tr = 0xff3cbe8f;
			break;
		case 2:
			tr = 0xff5f4db1;
			break;
		case 3:
			tr = 0xffc1703e;
			break;
		case 4:
			tr = 0xffc0a73e;
			break;
		case 5:
			tr = 0xff8ebf3d;
			break;
		case 6:
			tr = 0xffb04ba5;
			break;
		case 7:
			tr = 0xffc54047;
			break;
	  }
	  return tr;
  }
  
  void build_sounds(message@ msg) {
	  msg.set_string("HARDDROP", "HARDDROP");
	  msg.set_string("HOLD", "HOLD");
	  msg.set_string("LINECLEAR", "LINECLEAR");
	  msg.set_string("MOVE", "MOVE");
	  msg.set_string("ROTATE", "ROTATE");
	  msg.set_string("TETRIS", "TETRIS");
  }
  
  
}


class piece {
	
	int letter, rot, x, y, w, h;
	array<int> xMinos(4), yMinos(4);
	int gpo;
	
	int boardX, boardY, blockWidth;
	
	int arrTimer, sdfTimer;
	
	piece() {
		
	}
	
	/* rotation reference:
		0 - default
		1 - clockwise/right once
		2 - 180
		3 - counter-clockwise/left once
	*/
	
	/* letter guide:
		0 - blank
		1 - I
		2 - J
		3 - L
		4 - O
		5 - S
		6 - T
		7 - Z */
	
	piece(int type) {
		letter = type;
		rot = 0;
		if (type == 1) {
			x = 3;
			y = 2;
			w = 4;
			h = 1;
			array<int> t_xMinos = {0, 1, 2, 3};
			array<int> t_yMinos = {0, 0, 0, 0};
			xMinos = t_xMinos;
			yMinos = t_yMinos;
		} else if (type == 2) {
			x = 3;
			y = 1;
			w = 3;
			h = 2;
			array<int> t_xMinos = {0, 0, 1, 2};
			array<int> t_yMinos = {0, 1, 1, 1};
			xMinos = t_xMinos;
			yMinos = t_yMinos;
		} else if (type == 3) {
			x = 3;
			y = 1;
			w = 3;
			h = 2;
			array<int> t_xMinos = {0, 1, 2, 2};
			array<int> t_yMinos = {1, 1, 1, 0};
			xMinos = t_xMinos;
			yMinos = t_yMinos;
		} else if (type == 4) {
			x = 4;
			y = 1;
			w = 2;
			h = 2;
			array<int> t_xMinos = {0, 0, 1, 1};
			array<int> t_yMinos = {0, 1, 0, 1};
			xMinos = t_xMinos;
			yMinos = t_yMinos;
		} else if (type == 5) {
			x = 3;
			y = 1;
			w = 3;
			h = 2;
			array<int> t_xMinos = {0, 1, 1, 2};
			array<int> t_yMinos = {1, 1, 0, 0};
			xMinos = t_xMinos;
			yMinos = t_yMinos;
		} else if (type == 6) {
			x = 3;
			y = 1;
			w = 3;
			h = 2;
			array<int> t_xMinos = {0, 1, 1, 2};
			array<int> t_yMinos = {1, 1, 0, 1};
			xMinos = t_xMinos;
			yMinos = t_yMinos;
		} else if (type == 7) {
			x = 3;
			y = 1;
			w = 3;
			h = 2;
			array<int> t_xMinos = {0, 1, 1, 2};
			array<int> t_yMinos = {0, 0, 1, 1};
			xMinos = t_xMinos;
			yMinos = t_yMinos;
		}
		// I know this looks awful oh well
		
		boardX = -192;
		boardY = -1872;
		blockWidth = 48;
		
		arrTimer = 2;
		sdfTimer = 2;
	}
	
	void rotateLeft(array<array<int>> board) {
		if (letter != 4) {
			bool fail = false;
			array<int> testX(4);
			array<int> testY(4);
			int tx = x;
			int ty = y;
			for (int i = 0; i < 4; i++) {
				testX[i] = yMinos[i];
				testY[i] = w - xMinos[i] - 1;
			}
			if (letter == 1) {
				switch (rot) {
					case 0:
						tx += 1;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty -= 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 1:
						tx -= 2;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 2:
						tx += 2;
						ty -= 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty += 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 3:
						tx -= 1;
						ty += 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
				}
			} else {
				switch (rot) {
					case 0:
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 1:
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 2:
						tx += 1;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 3:
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
				}
			}
			if (!fail) {
				x = tx;
				y = ty;
				for (int i = 0; i < 4; i++) {
					xMinos[i] = testX[i];
					yMinos[i] = testY[i];
				}
				if (rot == 0)
					rot = 3;
				else
					rot--;
				int tw = w;
				w = h;
				h = tw;
			}
		}
	}
	
	void rotateRight(array<array<int>> board) {
		if (letter != 4) {
			bool fail = false;
			array<int> testX(4);
			array<int> testY(4);
			int tx = x;
			int ty = y;
			for (int i = 0; i < 4; i++) {
				testY[i] = xMinos[i];
				testX[i] = h - yMinos[i] - 1;
			}
			if (letter == 1) {
				switch (rot) {
					case 0:
						tx += 2;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 1:
						tx -= 2;
						ty += 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty -= 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 2:
						tx += 1;
						ty -= 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 3:
						tx -= 1;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 3;
						ty += 2;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 3;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
				}
			} else {
				switch (rot) {
					case 0:
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 1:
						tx -= 1;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 2:
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						ty += 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
					case 3:
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						ty += 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx += 1;
						ty -= 3;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						tx -= 1;
						if (trySpot(board, testX, testY, tx, ty))
							break;
						fail = true;
						break;
				}
			}
			if (!fail) {
				x = tx;
				y = ty;
				for (int i = 0; i < 4; i++) {
					xMinos[i] = testX[i];
					yMinos[i] = testY[i];
				}
				if (rot == 3)
					rot = 0;
				else
					rot++;
				int tw = w;
				w = h;
				h = tw;
			}
		}
	}
	
	void rotate180(array<array<int>> board) {
		if (letter != 4) {
			bool fail = false;
			array<int> testX(4);
			array<int> testY(4);
			int tx = x;
			int ty = y;
			for (int i = 0; i < 4; i++) {
				testX[i] = w - xMinos[i] - 1;
				testY[i] = h - yMinos[i] - 1;
			}
			switch (rot) {
				case 0:
					ty++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx -= 2;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx += 2;
					ty++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx -= 2;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					fail = true;
					break;
				case 1:
					tx--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty -= 2;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx--;
					ty--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					fail = true;
					break;
				case 2:
					ty--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx += 2;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx -= 2;
					ty--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx += 2;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					fail = true;
					break;
				case 3:
					tx++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty -= 2;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					tx++;
					ty--;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					ty++;
					if (trySpot(board, testX, testY, tx, ty))
						break;
					fail = true;
					break;
			}
			if (!fail) {
				x = tx;
				y = ty;
				for (int i = 0; i < 4; i++) {
					xMinos[i] = testX[i];
					yMinos[i] = testY[i];
				}
				if (rot < 2)
					rot += 2;
				else
					rot -= 2;
			}
		}
	}
	
	bool trySpot(array<array<int>> board, array<int> testX, array<int> testY, int tx, int ty) {
		for (int i = 0; i < 4; i++) {
			if (tx + testX[i] > 9 || tx + testX[i] < 0) {
				return false;
			}
			if (ty + testY[i] > 23 || ty + testY[i] < 0) {
				return false;
			}
			if (board[ty + testY[i]][tx + testX[i]] != 0) {
				return false;
			}
		}
		return true;
	}
	
	void moveLeft(array<array<int>> board) {
		bool canMove = true;
		if (x > 0) {
			for (int i = 0; i < 4; i++) {
				if (board[y + yMinos[i]][x + xMinos[i] - 1] != 0) {
					canMove = false;
				}
			}
		} else {
			canMove = false;
		}
		if (canMove) {
			x--;
		}
		ghostPiece(board);
	}
	
	void dasLeft(array<array<int>> board) {
		arrTimer--;
		if (arrTimer == 1) {
			moveLeft(board);
			arrTimer = 2;
		}
	}
	
	void moveRight(array<array<int>> board) {
		bool canMove = true;
		if (x + w < 10) {
			for (int i = 0; i < 4; i++) {
				if (board[y + yMinos[i]][x + xMinos[i] + 1] != 0) {
					canMove = false;
				}
			}
		} else {
			canMove = false;
		}
		if (canMove) {
			x++;
		}
		ghostPiece(board);
	}
	
	void dasRight(array<array<int>> board) {
		arrTimer--;
		if (arrTimer == 1) {
			moveRight(board);
			arrTimer = 2;
		}
	}
	
	void ghostPiece(array<array<int>> board) {
		int down = 24 - y - h;
		for (int i = 0; i < 4; i++) {
			if (!isAbove(i)) {
				for (int j = y + yMinos[i] + 1; j < 24; j++) {
					if (board[j][x + xMinos[i]] != 0 && j - y - yMinos[i] - 1 < down) {
						down = j - y - yMinos[i] - 1;
					}
				}
			}
		}
		gpo = down;
	}
	
	bool isAbove(int pos) {
		for (int i = 0; i < 4; i++) {
			if (xMinos[i] == xMinos[pos] && yMinos[i] > yMinos[pos]) {
				return true;
			}
		}
		return false;
	}
	
	void drop(array<array<int>> board) {
		sdfTimer--;
		if (sdfTimer == 1) {
			downOne(board);
			sdfTimer = 2;
		}
	}
	
	void instantDrop(array<array<int>> board) {
		ghostPiece(board);
		y += gpo;
	}
	
	void downOne(array<array<int>> board) {
		ghostPiece(board);
		if (gpo != 0) {
			y++;
		}
	}
	
	array<int> xs() {
		array<int> p(4);
		for (int i = 0; i < 4; i++) {
			p[i] = x + xMinos[i];
		}
		return p;
	}
	
	array<int> ys() {
		array<int> p(4);
		for (int i = 0; i < 4; i++) {
			p[i] = y + yMinos[i];
		}
		return p;
	}
	
	int getLetter() {
		return letter;
	}
	
	void draw(scene@ g, array<array<int>> board) {
		ghostPiece(board);
		for (int i = 0; i < 4; i++) {
			int X1 = boardX + blockWidth * (xMinos[i] + x);
			int Y1 = boardY + blockWidth * (yMinos[i] + y);
			g.draw_rectangle_world(18, 10, X1, Y1, X1 + blockWidth, Y1 + blockWidth, 0, getColor(letter, false));
			int gY1 = boardY + blockWidth * (yMinos[i] + y + gpo);
			g.draw_rectangle_world(18, 10, X1, gY1, X1 + blockWidth, gY1 + blockWidth, 0, getColor(letter, true));
		}
	}
	
	uint getColor(int color, bool ghost) {
	  uint tr = 0;
	  if (ghost) {
		  switch (color) {
		  case 1:
			  tr = 0x603cbe8f;
			  break;
		  case 2:
			  tr = 0x605f4db1;
			  break;
		  case 3:
			  tr = 0x60c1703e;
			  break;
		  case 4:
			  tr = 0x60c0a73e;
			  break;
		  case 5:
			  tr = 0x608ebf3d;
			  break;
		  case 6:
			  tr = 0x60b04ba5;
			  break;
		  case 7:
			  tr = 0x60c54047;
			  break;
	    }  
	  } else {
		  switch (color) {
		  case 1:
			  tr = 0xff3cbe8f;
			  break;
		  case 2:
			  tr = 0xff5f4db1;
			  break;
		  case 3:
			  tr = 0xffc1703e;
			  break;
		  case 4:
			  tr = 0xffc0a73e;
			  break;
		  case 5:
			  tr = 0xff8ebf3d;
			  break;
		  case 6:
			  tr = 0xffb04ba5;
			  break;
		  case 7:
			  tr = 0xffc54047;
			  break;
	    }  
	  }
	  return tr;
  }
	
}