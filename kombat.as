#include "Others/lib/drawing/Sprite.cpp"
const string EMBED_finish = "finish.png";
const string EMBED_fatality = "fatality.png";
const string EMBED_fatality_sound = "fatality.ogg";
const string EMBED_finish_sound = "finish-him.ogg";
class script : callback_base {

	scene@ g;
	dustman@ p;
	
	Sprite finish;
	Sprite fatality;
	
	[entity] uint bearID;
	controllable@ bear;
	
	int freezeTimer;
	int endTimer;
	
	script() {
		@g = get_scene();
	}
	
	void on_level_start() {
		@p = controller_controllable(0).as_dustman();
		
		finish = Sprite("script", "finish", 0.5, 0.5);
		fatality = Sprite("script", "fatality", 0.5, 0.5);
		
		@bear = entity_by_id(bearID).as_controllable();
		bear.life(45);
		
		freezeTimer = -2;
		endTimer = -2;
		g.time_warp(1);
		
		g.disable_score_overlay(true);
	}
	
	void step(int entities) {
		if (freezeTimer == -2 && bear.life() <= 3) {
			freezeTimer = 104;
			startFreeze();
		}
		if (freezeTimer >= 0) {
			p.combo_timer(1);
			freezeTimer--;
			if (freezeTimer == 0) {
				endFreeze();
			}
		}
		if (endTimer >= 0) {
			p.combo_timer(1);
			endTimer--;
			if (endTimer == 0) {
				g.end_level(0, 0);
			}
		}
	}
	
	void startFreeze() {
		g.time_warp(0.01);
		g.play_script_stream("finish_sound", 0, 0, 0, false, 1);
		bear.time_warp(0.01);
	}
	
	void endFreeze() {
		g.time_warp(1);
	}
	
	void draw(float subframe) {
		if (freezeTimer >= -1) {
			finish.draw(20, 16, 0, 1, 0, -432, 0, (105 - float(freezeTimer)) / 52, (105 - float(freezeTimer)) / 52);
		}
		if (endTimer >= -1) {
			fatality.draw(20, 16, 0, 1, 0, -332, 0, 2, 2);
		}
	}
	
	void entity_on_add(entity@ e) {
		if (e.as_hitbox() != null && e.as_hitbox().owner().player_index() == -1) {
			e.as_hitbox().damage(3000);
		}
	}
	
	void entity_on_remove(entity@ e) {
		if (e.id() == bearID) {
			endTimer = 134;
			g.play_script_stream("fatality_sound", 0, 0, 0, false, 1);
		}
	}
	
	void build_sounds(message@ msg) {
		msg.set_string("finish_sound", "finish_sound");
		msg.set_string("fatality_sound", "fatality_sound");
	}
	
	void build_sprites(message@ msg) {
		msg.set_string("finish", "finish");
		msg.set_string("fatality", "fatality");
	}

}