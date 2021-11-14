const string EMBED_CB = "combo_break.ogg";
const string EMBED_avoid = "avoid.png";
class script : callback_base {

	scene@ g;
	camera@ cam;
	dustman@ player;
	sprites@ spr;
	
	[position, mode:WORLD, layer:19, y:first_y]
    float first_x;
    [hidden]
    float first_y;
	[position, mode:WORLD, layer:19, y:second_y]
    float second_x;
    [hidden]
    float second_y;
	[text] float height;
	
	[position, mode:WORLD, layer:19, y:avoid_y]
    float avoid_x;
    [hidden]
    float avoid_y;
	
	[text] array<pos> fr_teles;
	[text] array<pos> sr_teles;
	
	[text] pos secret_in;
	[text] pos secret_out;
	[text] pos secret_camera;
	
	bool top;
	bool in_teleporter;
	int current_tele;
	
	float toptopy;
	float topboty;
	float bottopy;
	float botboty;
	float leftx;
	float cy1, cy2;
	uint color;
	
	float prev_combo_timer;
	
	bool is_over;
	
	script() {
		@g = get_scene();
		add_broadcast_receiver('in_tele', this, 'in_tele');
		
		toptopy = -1532;
		topboty = 0;
		bottopy = 292;
		botboty = 1822;
		leftx = -624;
		cy1 = topboty;
		cy2 = topboty;
		color = 0xFFFFFFFF;
		prev_combo_timer = 0;
		
		@spr = create_sprites();
	}
	
	void on_level_start() {
		@cam = get_active_camera();
		cam.script_camera(true);
		camera_goto(first_x, first_y, height);
		
		@player = controller_controllable(0).as_dustman();
		
		g.disable_score_overlay(true);
		
		top = true;
		in_teleporter = false;
		current_tele = 0;
		is_over = false;
		
		spr.add_sprite_set("script");
	}
	
	void in_tele(string id, message@ msg) {
		in_teleporter = true;
		current_tele = msg.get_int('id');
		
		if (current_tele == 70) {
			player.combo_timer(1);
		}
	}
	
	void step(int entities) {
		if (player.heavy_intent() == 10) {
			player.heavy_intent(11);
			if (in_teleporter)
				teleport(current_tele);
		}
		
		in_teleporter = false;
		
		if (player.skill_combo() >= 80)
			player.skill_combo(10);
		if (!is_over)
			update_timer();
		
		if (prev_combo_timer != 0 && player.combo_timer() == 0 && !is_over) {
			g.play_script_stream("CB", 0, 0, 0, false, 10);
		}
		prev_combo_timer = player.combo_timer();
		
		spr.add_sprite_set("script");
	}
	
	void build_sounds(message@ msg) {
		msg.set_string("CB", "CB");
	}
	
	void build_sprites(message@ msg) {
		msg.set_string("avoid", "avoid");
	}
	
	void update_timer() {
		if (top) {
			cy1 = topboty - (topboty - toptopy) * player.combo_timer();
			if (player.combo_count() == 0)
				cy1 = topboty;
			cy2 = topboty;
		} else {
			cy1 = botboty - (botboty - bottopy) * player.combo_timer();
			if (player.combo_count() == 0)
				cy1 = botboty;
			cy2 = botboty;
		}
		color = 0xFFFF0000 + uint32(256 * player.combo_timer()) * 0x101;
		if (player.combo_count() == 0)
			color = 0xFFFFFFFF;
	}
	
	void draw(float subframe) {
		g.draw_rectangle_world(20, 10, leftx, cy1, leftx + 48, cy2, 0, color);
		spr.draw_world(20, 1, "avoid", 0, 1, avoid_x, avoid_y, 0, 1, 1, 0xFFFFFFFF);
	}
	
	void editor_draw(float subframe) {
		spr.draw_world(20, 1, "avoid", 0, 1, avoid_x, avoid_y, 0, 1, 1, 0xFFFFFFFF);
	}
	
	void editor_step( ) {
		spr.add_sprite_set("script");
	}
	
	void teleport(int id) {
		if (current_tele == 69) {
			teleport_secret(true);
			return;
		}
		if (current_tele == 70) {
			teleport_secret(false);
			return;
		}
		if (top) {
			player_goto(sr_teles[id].x(), sr_teles[id].y());
			camera_goto(second_x, second_y, height);
			top = false;
		} else {
			player_goto(fr_teles[id].x(), fr_teles[id].y());
			camera_goto(first_x, first_y, height);
			top = true;
		}
	}
	
	void teleport_secret(bool going_in) {
		if (going_in) {
			player_goto(secret_in.x(), secret_in.y());
			camera_goto(secret_camera.x(), secret_camera.y(), 520);
		} else {
			player_goto(secret_out.x(), secret_out.y());
			camera_goto(first_x, first_y, height);
		}
	}
	
	void player_goto(float x, float y) {
		player.x(x);
		player.y(y);
		player.set_speed_xy(0.0,0.0);
	}
	
	void camera_goto(float x, float y, float h) {
		cam.x(x);
		cam.prev_x(x);
		cam.y(y);
		cam.prev_y(y);
		cam.scale_x(1080 / h);
		cam.prev_scale_x(1080 / h);
		cam.scale_y(1080 / h);
		cam.prev_scale_y(1080 / h);
	}
	
	void on_level_end() {
		if (top)
			cy1 = toptopy;
		else
			cy1 = bottopy;
		color = 0xFFFFFFFF;
		is_over = true;
	}

}

class teleporter : trigger_base {
	
	[text] int id;
	//cyan, magenta, yellow, green, red, blue
	
	teleporter() {
		
	}
	
	void activate(controllable@ e) {
		if (e.player_index() == 0) {
			message@ msg = create_message();
			msg.set_int('id',id);
			broadcast_message('in_tele', msg);
		}
	}
	
	
}

class pos {
	
	[position,mode:world,layer:19,y:Y] float X;
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