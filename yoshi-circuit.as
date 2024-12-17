const string EMBED_FINISH = "finish_noise.ogg";

class script : callback_base {
  scene@ g;
  canvas@ text_canvas;
  textfield@ print_text_field;
  int current_pos;
  int current_lap;
  [text] int laps;
  [entity] uint apple;
  [position,mode:world,layer:22,y:Y1] float X1;
	[hidden] float Y1;
  int endTimer = -2;
	
  script() { 
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    @g = get_scene();
	@text_canvas = create_canvas(true, 22, 15);
	@print_text_field = create_textfield();
        print_text_field.set_font("sans_bold", 36);
        print_text_field.align_horizontal(-1);
        print_text_field.align_vertical(-1);
		print_text_field.text("Lap 0/" + laps);
  }
  
  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('triggerType') == 'lapTrigger') {
      if(msg.get_int('checkpoint') == 0) {
        if (current_pos == 1) {
			//player went backwards
			current_lap--;
			print_text_field.text("Lap " + current_lap + "/" + laps);
			if (current_lap == -69) {
				endTimer = 3;
				hitTheApple();
			}
		}
		current_pos = 0;
      }
	  else if(msg.get_int('checkpoint') == 1) {
		if (current_pos == 0) {
			if (current_lap >= laps) {
				//end level
				endTimer = 3;
			}
			else {
				current_lap++;
				print_text_field.text("Lap " + current_lap + "/" + laps);
			}
		}
		current_pos = 1;
	  }
	  else if(msg.get_int('checkpoint') == 2) {
		current_pos = 2;
	  }
     }
  }
 
  void on_level_start() {
    current_pos = 0;
	current_lap = 0;
	
	print_text_field.text("Lap 0/" + laps);
  }

  void editor_step() {
	  print_text_field.text("Lap 0/" + laps);
  }

  void editor_draw(float sub_frame) {
	  //text_canvas.draw_text(print_text_field, X1, Y1, 1, 1, 0);
  }

  void step(int entities) {
	if (endTimer >= 0) {
		if (endTimer == 0) {
			g.end_level(0, 0);
		}
		endTimer--;
	}
  }

  void draw(float subframe) {
	  text_canvas.draw_text(print_text_field, X1, Y1, 1, 1, 0);
  }
  
  void hitTheApple() {
	  controllable@ thePlayer = controller_controllable(0);
	  hitbox@ h = create_hitbox(thePlayer, 0, entity_by_id(apple).x(), entity_by_id(apple).y(), -5, 5, -5, 5);
	  g.add_entity(h.as_entity(), false);
  }
}

class laptrigger : trigger_base {
  scene@ g;
  scripttrigger@ self;
  bool activated;
  bool active_this_frame;
  controllable@ trigger_entity;
  [text] int position;

  laptrigger() {
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
    msg.set_int('checkpoint', position);
    msg.set_string('triggerType',"lapTrigger");
    broadcast_message('OnMyCustomEventName', msg);
  }
}