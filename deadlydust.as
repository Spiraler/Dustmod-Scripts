#include "pos.as"
class script : callback_base {

	scene@ g;
	
	script() {
		@g = get_scene();
	}
	
	void on_level_start() {
		
	}
	
	void step(int entities) {
		
	}
	
	void draw(float subframe) {
		
	}

}

class killer : trigger_base {
	
	scene@ g;
	scripttrigger@ self;
	controllable@ trigger_entity;
	[text] pos topleft;
	[text] pos botright;
	int t, b, l, r;
	bool isClear = false;
	
	killer() {
		@g = get_scene();
	}
	
	void init(script@ s, scripttrigger@ self) {
		@this.self = @self;
		t = int32(topleft.y() / 48) - 2;
		b = int32(botright.y() / 48) + 2;
		l = int32(topleft.x() / 48) - 2;
		r = int32(botright.x() / 48) + 2;
		
		
	}
	
	void step() {
		if (!isClear) {
			isClear = checkClear();
		}
	}
	
	void activate(controllable@ e) {
		if (e.player_index() == 0 && !isClear) {
			e.as_dustman().kill(false);
		}
	}
	
	bool checkClear() {
		for (int i = t; i <= b; i++) {
			for (int j = l; j <= r; j++) {
				if (g.get_tile_filth(j, i).top() + g.get_tile_filth(j, i).left() + g.get_tile_filth(j, i).right() + g.get_tile_filth(j, i).bottom() != 0) {
					return false;
				}
			}
		}
		return true;
	}
	
}