class pos {
	
	[position,mode:world,layer:22,y:Y] float X;
	[hidden] float Y;
	
	pos() {
		
	}
	
	float x() {
		return X;
	}
	
	float y() {
		return Y;
	}
	
}

class script : callback_base {
  scene@ g;
  canvas@ text_canvas;
  textfield@ print_text_field;
  dustman@ player;
  int currentLevel; 
  [text] array<pos> starts(6);
  [text] array<pos> camera(6);
  bool started;
  int timer;
  [position,mode:world,layer:22,y:Y1] float X1;
  [hidden] float Y1;
	
  script() { 
    add_broadcast_receiver('DoSomething', this, 'CheckThings');
    @g = get_scene();
	@text_canvas = create_canvas(true, 22, 15);
	@print_text_field = create_textfield();
        print_text_field.set_font("sans_bold", 36);
        print_text_field.align_horizontal(1);
        print_text_field.align_vertical(1);
	currentLevel = 0;
	started = false;
	timer = 600;
  }
  
  void CheckThings(string id, message@ msg) {
	  if(msg.get_string('triggerType') == 'starter') {
		  started = true;
	  }
	  else if(msg.get_string('triggerType') == 'enemyDetector') {
		  if (msg.get_int('level') == currentLevel ) {
			  //current level is empty, go to the next 
			  timer = 600;
			  started = false;
			  currentLevel++;
			  goToLevel(currentLevel);
		  }
	  }
  }
  
  void goToLevel(int level) {
	  player.x(starts[level].x());
	  player.y(starts[level].y());
	  player.set_speed_xy(0.0,0.0);
	  goToCamera(level);
  }
  
  void goToCamera(int level) {
	  camera@ cam = get_active_camera();
	  cam.script_camera(true);
	  cam.x(camera[level].x());
	  cam.y(camera[level].y());
	  cam.prev_x(camera[level].x());
	  cam.prev_y(camera[level].y());
  }
  
  void on_level_end() {
	  
  }
  
  void entity_on_add(entity@ e) {
	  if (e.type_name() == 'filth_ball') {
		  g.remove_entity(e);
	  }
  }
 
  void on_level_start() {
	  @player = controller_controllable(0).as_dustman();
	  goToCamera(currentLevel);
  }
  
  void checkpoint_load() {
	  @player = controller_controllable(0).as_dustman();
	  goToCamera(currentLevel);
	  timer = 600;
	  started = false;
  }

  void editor_step() {
	  print_text_field.text("sample text");
  }

  void editor_draw(float sub_frame) {
	  text_canvas.draw_text(print_text_field, X1, Y1, 1, 1, 0);
  }

  void step(int entities) {
	  int sec = timer / 60;
	  float msec = floor((timer % 60) * 1.4);
	  string timerString = "";
	  if (sec < 10) {
		  timerString = "0";
	  }
	  timerString = timerString + sec + ".";
	  if (msec < 10) {
		  timerString = timerString + "0";
	  }
	  timerString = timerString + msec;
	  if (currentLevel == 5) {
		  timerString = "Complete";
	  }
	  print_text_field.text(timerString);
	  if(started) {
		  timer--;
		  if(timer <= 0) {
			  player.kill(true);
			  timer = 600;
			  started = false;
		  }
	  }
	  else {
		  player.combo_timer(1);
	  }
  }

  void draw(float subframe) {
	  text_canvas.draw_text(print_text_field, X1, Y1, 1, 1, 0);
  }
}

class starter : trigger_base {
  scene@ g;
  scripttrigger@ self;
  bool activated;
  bool active_this_frame;
  controllable@ trigger_entity;

  starter() {
    @g = get_scene();
  }

  void init(script@ s, scripttrigger@ self) {
      @this.self = @self;
      activated = false;
      active_this_frame = false;
  }
  
  void rising_edge(controllable@ e) {
      @trigger_entity = @e;
	  notifyScript();
  }

  void falling_edge(controllable@ e) {
      @trigger_entity = null;
      //do stuff
  }

  void editor_draw(float sub_frame) {
    //stuff
  }

  void editor_step() {
    //stuff
  }

  void step() {
      if(activated) {
          if(not active_this_frame) {
              activated = false;
              falling_edge(@trigger_entity);
			  
          }
          active_this_frame = false;
      }
  }
  
  void activate(controllable@ e) {
      if(e.player_index() == 0) {
          if(not activated) {
              rising_edge(@e);
              activated = true;
          }
          active_this_frame = true;
      }
  }

  void notifyScript() {
    message@ msg = create_message();
	msg.set_string('triggerType',"starter");
    broadcast_message('DoSomething', msg);
  }
}

class enemyDetector : trigger_base {
  scene@ g;
  scripttrigger@ self;
  bool activated;
  bool active_this_frame;
  controllable@ trigger_entity;
  [text] int level;
  [entity] array<uint> enemies;

  enemyDetector() {
    @g = get_scene();
  }

  void init(script@ s, scripttrigger@ self) {
      @this.self = @self;
      activated = false;
      active_this_frame = false;
  }

  void editor_draw(float sub_frame) {
    //stuff
  }

  void editor_step() {
    //stuff
  }

  void step() {
      int total = enemies.length();
	  int alive = total;
	  for (int i = 0; i < total; i++) {
		  if (entity_by_id(enemies[i]) == null) {
			  alive--;
		  }
	  }
	  if (alive == 0) {
		  notifyScript();
	  }
  }
  
  void activate(controllable@ e) {
      
  }

  void notifyScript() {
    message@ msg = create_message();
	msg.set_string('triggerType',"enemyDetector");
	msg.set_int('level',level);
    broadcast_message('DoSomething', msg);
  }
}