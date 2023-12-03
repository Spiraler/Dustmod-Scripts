#include "pos.as"
#include "SeedGenerator.as"
class script : callback_base {

	scene@ g;
	dustman@ p;
	SeedGenerator s;
	bool seedset;
	[text] pos start;
	[text] int layers;
	[text] float ydif;
	[text] int invTimer;
	[text] pos top;
	[entity] uint apple;
	bool appleHit;
	
	array<int> qt;
	array<entity@> q;
	
	int goal, cleared, endtimer;
	
	script() {
		@g = get_scene();
		s = SeedGenerator();
	}
	
	void on_level_start() {
		@p = controller_controllable(0).as_dustman();
		seedset = false;
		goal = pow(2, layers - 1);
		cleared = 0;
		endtimer = -2;
		appleHit = false;
		
		entity@ tire = create_entity("enemy_trash_tire");
		tire.x(start.x());
		tire.y(start.y());
		tire.as_hittable().scale(0.5 * (layers + 1));
		tire.as_controllable().taunt_intent(layers);
		g.add_entity(tire);
		q.insertLast(tire);
		qt.insertLast(1);
	}
	
	void entity_on_add(entity@ e) {
		if (e.type_name() == "entity_cleansed") {
			g.remove_entity(e);
		} else if (e.type_name() == "filth_ball") {
			g.remove_entity(e);
		}
	}
	
	void entity_on_remove(entity@ e) {
		if (e.type_name() == "enemy_trash_tire") {
			int l = e.as_controllable().taunt_intent();
			if (l == 1) {
				cleared++;
				if (cleared >= goal)
					endtimer = 3;
			} else {
				split(l - 1, e.x(), e.y());
			}
		}
	}
	
	void split(int layer, float sx, float sy) {
		for (int i = 0; i < 2; i++) {
			entity@ t1 = create_entity("enemy_trash_tire");
			t1.x(sx);
			t1.y(sy - ydif);
			t1.as_hittable().scale(0.5 * (layer + 1));
			t1.as_controllable().taunt_intent(layer);
			g.add_entity(t1);
			q.insertLast(t1);
			qt.insertLast(-3 - invTimer);
		}
	}
	
	void step(int entities) {
		if (!seedset) {
			if (!s.ready()) {
				s.step();
			} else {
				srand(s.getSeed());
				seedset = true;
			}
		}
		
		for (uint i = 0; i < q.length(); i++) {
			if (qt[i] == 0 - invTimer) {
				q[i].as_controllable().set_speed_direction(500 * q[i].as_controllable().scale(), rand() % 150 - 75);
			} else if (q[i].y() < top.y() && qt[i] >= 0){
				q[i].y(q[i].y() + ydif);
				qt[i] = invTimer;
			} else if (qt[i] > 90 && rand() % 240 == 69) {
				q[i].as_controllable().set_speed_xy(q[i].as_hittable().x_speed(), q[i].as_hittable().y_speed() - 2000);
				qt[i] = 1;
			}
			qt[i]++;
		}
		for (int i = q.length() - 1; i >= 0; i--) {
			if (q[i].destroyed()) {
				q.removeAt(i);
				qt.removeAt(i);
			}
		}
		
		if (q.length() == goal && !appleHit) {
			hitbox@ h = create_hitbox(p.as_controllable(), 0, entity_by_id(apple).x(), entity_by_id(apple).y(), -5, 5, -5, 5);
			g.add_entity(h.as_entity(), false);
			appleHit = true;
		}
		
		if (endtimer > 0) {
			endtimer--;
		} else if (endtimer == 0) {
			g.end_level(0,0);
			endtimer--;
		}
	}
	
	void step_post(int entities) {
		for (int i = 0; i < q.length(); i++) {
			q[i].as_controllable().stun_timer(0);
		}
	}

}