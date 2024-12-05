#include "pos.as"
class script : callback_base {

	scene@ g;
	camera@ cam;
	dustman@ p;
	[text] int right;
	[text] pos secret;
	bool inSecret;
	
	script() {
		@g = get_scene();
		add_broadcast_receiver("camChange", this, "camChange");
	}
	
	void on_level_start() {
		@cam = get_active_camera();
		cam.script_camera(true);
		cam.rotation(-45);
		
		@p = controller_controllable(0).as_dustman();
		
		inSecret = false;
		
		//rotate_enemies();
	}
	
	void step(int entities) {
		if (inSecret)
			secret_cam();
		else
			normal_cam();
	}
	
	void camChange(string id, message@ msg) {
		if (msg.get_int("isSecret") == 1) {
			cam.scale_x(1.5);
			cam.scale_y(1.5);
			cam.prev_scale_x(1.5);
			cam.prev_scale_y(1.5);
			cam.rotation(45);
			inSecret = true;
		} else {
			cam.scale_x(1);
			cam.scale_y(1);
			cam.prev_scale_x(1);
			cam.prev_scale_y(1);
			cam.rotation(-45);
			inSecret = false;
		}
	}
	
	void normal_cam() {
		//this implementation assumes the "left" node of the camera is at 0, 0
		//I tried it without that assumption and the camera jittered
		float c = (p.x() + p.y()) / 2;
		if (c < 0)
			c = 0;
		else if (c > right)
			c = right;
		cam.x(c);
		cam.y(c);
		cam.prev_x(c);
		cam.prev_y(c);
	}
	
	void secret_cam() {
		cam.x(secret.x());
		cam.y(secret.y());
		cam.prev_x(secret.x());
		cam.prev_y(secret.y());
	}
	
	/*void rotate_enemies() {
		for (int i = 0; i < enemies.length(); i++) {
			entity_by_id(enemies[i]).rotation(45);
		}
	}*/
	
	void draw(float subframe) {
		
	}

}

class notifier : trigger_base {
	
	scene@ g;
	[text] int isSecret;
	scripttrigger@ self;
	
	notifier() {
		@g = get_scene();
	}
	
	void init(script@ s, scripttrigger@ self) {
		@this.self = @self;
	}
	
	void activate(controllable@ e) {
		if (e.player_index() == 0) {
			notifyScript();
		}
	}
	
	void notifyScript() {
		message@ msg = create_message();
		msg.set_int("isSecret", isSecret);
		broadcast_message("camChange", msg);
	}
	
}