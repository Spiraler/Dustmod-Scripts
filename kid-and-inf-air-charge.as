#include "pos.as"
class script : callback_base {

	scene@ g;
	dustman@ p;
	
	script() {
		@g = get_scene();
	}
	
	void on_level_start() {
		@p = controller_controllable(0).as_dustman();
		p.character("dustkid");
	}
	
	void step(int entities) {
		p.dash(4);
	}
	
	void draw(float subframe) {
		
	}

}

class deleter : trigger_base {
	
	scene@ g;
	scripttrigger@ self;
	bool activated;
	[text] pos topLeft;
	[text] pos botRight;
	
	deleter() {
		@g = get_scene();
	}
	
	void init(script@ s, scripttrigger@ self) {
		@this.self = @self;
		activated = false;
	}
	
	void activate(controllable@ e) {
		if (!activated && e.player_index() == 0) {
			activated = true;
			tileinfo@ tin = g.get_tile(int32(topLeft.x() / 48), int32(topLeft.y() / 48 - 1), 19);
			int t = int32(topLeft.y() / 48) - 1;
			int b = int32(botRight.y() / 48) - 1;
			int l = int32(topLeft.x() / 48);
			int r = int32(botRight.x() / 48);
			for (int i = l; i < r + 1; i++) {
				for (int j = t; j < b + 1; j++)
					g.set_tile(i, j, 19, @tin, true);
			}
		}
	}
	
}