#include "pos.as"
#include "SeedGenerator.as"
class script : callback_base {

	scene@ g;
	dustman@ p;
	
	SeedGenerator s;
	bool seedset;
	
	int levelTimer;
	[text] pos topleft;
	[text] pos botright;
	float width;
	float progress;
	float duration;
	
	[entity] uint startText;
	[entity] uint endText;
	
	bool playerInTrigger, endedOnce;
	int endTimer;
	
	script() {
		@g = get_scene();
		
		add_broadcast_receiver('playerIn', this, 'playerIn');
	}
	
	void on_level_start() {
		@p = controller_controllable(0).as_dustman();
		
		s = SeedGenerator();
		seedset = false;
		
		duration = 10000;
		
		levelTimer = 0;
		width = botright.x() - topleft.x() - 8;
		progress = 0;
		
		g.disable_score_overlay(true);
		
		playerInTrigger = false;
		endedOnce = false;
		endTimer = -2;
	}
	
	void step(int entities) {
		if (!seedset) {
			if (!s.ready()) {
				s.step();
			} else {
				srand(s.getSeed());
				seedset = true;
				duration = rand() % 40 + 80;
			}
		}
		
		levelTimer++;
		
		if (progress < 100 && levelTimer >= 55) {
			progress += 100 / (duration * 60);
		} else if (progress >= 100) {
			entity_by_id(startText).y(500);
			entity_by_id(endText).x(p.x());
			entity_by_id(endText).y(p.y());
		}
		
		if (endTimer >= 0) {
			endTimer--;
			if (endTimer == 0) {
				g.end_level(0, 0);
			}
		}
	}
	
	void draw(float subframe) {
		g.draw_rectangle_world(20, 5, topleft.x() + 4, topleft.y() + 4, topleft.x() + 4 + width * progress / 100, botright.y() - 4, 0, 0xFF33FF33);
	}
	
	void playerIn(string id, message@ msg) {
		if (!endedOnce && progress >= 100) {
			endTimer = 3;
			endedOnce = true;
		}
	}

}

class ender : trigger_base {
	
	scene@ g;
	scripttrigger@ self;
	bool activated;
	bool active_this_frame;
	controllable@ trigger_entity;
	
	ender() {
		@g = get_scene();
	}
	
	void init(script@ s, scripttrigger@ self) {
		@this.self = @self;
		activated = false;
	}
	
	void activate(controllable@ e) {
		if (!activated && e.player_index() == 0) {
			notifyScript();
		}
	}
	
	void notifyScript() {
		message@ msg = create_message();
		msg.set_string('triggerType',"ender");
		broadcast_message('playerIn', msg);
	}
}