#include "pos.as"
const string EMBED_DING = "ding.ogg";
class script : callback_base {

	scene@ g;
	textfield@ taunt_text;
	dustman@ p;
	float px, py;
	
	int count = 0;
	int endtimer = -1;
	array<bool> done(4);
	[entity] array<uint> cs(4);
	[text] array<pos> labels(5);
	
	array<uint> tcs = {0xFFCCAA00, 0xFF33AA33, 0xFFAAAAAA, 0xFF00AACC, 0xFFEEEEEE};
	array<uint> bcs = {0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF9000DD};
	array<textfield@> texts(5);
	
	bool tauntable;
	bool sttf; //set tauntable this frame
	
	script() {
		@g = get_scene();
		
		@taunt_text = create_textfield();
		taunt_text.set_font("ProximaNovaReg", 36);
		taunt_text.align_horizontal(0);
		taunt_text.align_vertical(0);
		for (int i = 0; i < 5; i++) {
			@texts[i] = create_textfield();
			texts[i].set_font("ProximaNovaReg", 36);
			texts[i].align_horizontal(0);
			texts[i].align_vertical(0);
			texts[i].colour(tcs[i]);
		}
		
		
		add_broadcast_receiver("bought", this, "bought");
	}
	
	void bought(string id, message@ msg) {
		if (msg.get_int("bought") == 1 && !done[msg.get_int("id")]) {
			count++;
			done[msg.get_int("id")] = true;
			texts[msg.get_int("id")].colour(tcs[4]);
			tcs[msg.get_int("id")] = tcs[4];
			bcs[msg.get_int("id")] = bcs[4];
			g.save_checkpoint(px, py);
		} else {
			tauntable = true;
			sttf = true;
		}
	}
	
	void on_level_start() {
		taunt_text.text("taunt");
		texts[0].text("Lhasa");
		texts[1].text("Kathmandu");
		texts[2].text("Ife");
		texts[3].text("Wittenberg");
		texts[4].text("Venice");
		@p = controller_controllable(0).as_dustman();
		
		for (int i = 0; i < 4; i++) {
			done[i] = false;
		}
	}
	
	void checkpoint_load() {
		@p = controller_controllable(0).as_dustman();
		
		for (int i = 0; i < 4; i++) {
			if (done[i]) {
				g.remove_entity(entity_by_id(cs[i]));
			}
		}
	}
	
	void step(int entities) {
		px = p.x();
		py = p.y();
		
		if (!sttf)
			tauntable = false;
		sttf = false;
		
		if (endtimer > 0) {
			endtimer--;
		} else if (endtimer == 0) {
			g.end_level(px, py);
			endtimer = -2;
		} else if (endtimer == -1) {
			if (count == 4) {
				endtimer = 3;
			}
		}
	}
	
	void editor_draw(float subframe) {
		for (int i = 0; i < 5; i++) {
			if (i == 4) {
				g.draw_rectangle_world(20, 4, labels[i].x() - 120, labels[i].y() - 30, labels[i].x() + 120, labels[i].y() + 30, 0, 0xFF9000DD);
			} else {
				g.draw_rectangle_world(20, 4, labels[i].x() - 120, labels[i].y() - 30, labels[i].x() + 120, labels[i].y() + 30, 0, 0xFF000000);
			}
		}
	}
	
	void draw(float subframe) {
		if (tauntable) {
			taunt_text.draw_world(20, 18, px, py - 120, 1, 1, 0);
		}
		for (int i = 0; i < 5; i++) {
			g.draw_rectangle_world(20, 4, labels[i].x() - 120, labels[i].y() - 30, labels[i].x() + 120, labels[i].y() + 30, 0, bcs[i]);
			g.draw_line_world(20, 5, labels[i].x() - 122, labels[i].y() - 30, labels[i].x() + 122, labels[i].y() - 30, 5, tcs[i]);
			g.draw_line_world(20, 5, labels[i].x() - 120, labels[i].y() - 32, labels[i].x() - 120, labels[i].y() + 32, 5, tcs[i]);
			g.draw_line_world(20, 5, labels[i].x() - 122, labels[i].y() + 30, labels[i].x() + 122, labels[i].y() + 30, 5, tcs[i]);
			g.draw_line_world(20, 5, labels[i].x() + 120, labels[i].y() - 32, labels[i].x() + 120, labels[i].y() + 32, 5, tcs[i]);
			texts[i].draw_world(20, 5, labels[i].x(), labels[i].y(), 1.2, 1.2, 0);
		}
	}
	
	void build_sounds(message@ msg) {
	  msg.set_string("DING", "DING");
	}

}


class citystate : trigger_base {
	scene@ g;
	scripttrigger@ self;
	controllable@ trigger_entity;
	bool playerinit = false;
	
	[text] pos topleft;
	[text] pos botright;
	[text] int id;
	bool done = false;

	citystate() {
		@g = get_scene();
	}

	void init(script@ s, scripttrigger@ self) {
		@this.self = @self;
	}
	
	void activate(controllable@ e) {
		if(!done && e.player_index() == 0) {
			if (e.taunt_intent() == 1) {
				veniceTime();
				done = true;
				notify(1);
			} else {
				notify(0);
			}
		}
	}

	void step() {
		
	}

	void veniceTime() {
		int t = int32(topleft.y() / 48) - 1;
		int b = int32(botright.y() / 48) - 1;
		int l = int32(topleft.x() / 48);
		int r = int32(botright.x() / 48);
		
		//add tiles to layer 20
		for (int i = l - 1; i < r + 2; i++) {
			for (int j = t - 1; j < b + 2; j++) {
				g.set_tile(i, j, 20, g.get_tile(i, j, 19), true);
			}
		}
		
		//change layer 19 to minimal tiles
		for (int i = l; i < r + 1; i++) {
			for (int j = t; j < b + 1; j++) {
				tileinfo@ tin = g.get_tile(i, j, 19);
				tin.sprite_tile(10);
				g.set_tile(i, j, 19, tin, true);
			}
		}
		
		g.play_script_stream("DING", 0, 0, 0, false, 2);
	}
	
	void notify(int buying) {
		message@ msg = create_message();
		msg.set_int("bought", buying);
		msg.set_int("id", id);
		msg.set_string("triggerType","citystate");
		broadcast_message("bought", msg);
	}
}

class comboExtender : trigger_base {
	scene@ g;
	scripttrigger@ self;
	controllable@ trigger_entity;
	
	comboExtender() {
		@g = get_scene();
	}
	
	void init(script@ s, scripttrigger@ self) {
		@this.self = @self;
	}
	
	void activate(controllable@ e) {
		if(e.player_index() == 0) {
			e.as_dustman().combo_timer(1);
		}
	}
	
}