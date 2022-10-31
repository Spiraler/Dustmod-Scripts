#include "textbox.as"
const string EMBED_tbbg = "textboxbg.png";
const string EMBED_blip = "blip.ogg";
class script : callback_base {

	scene@ g;
	dustman@ p;
	sprites@ spr;
	canvas@ tc;
	textfield@ candy_text;
	textfield@ taunt_text;
	float px, py; //used to call player's location only on steps
	int taunttimer;
	
	bool textmode, inbox, intele;
	int tbid; //id of current textbox
	textbox tb;
	
	[entity] array<uint> fogtriggers;
	[text] array<pos> ftspots;
	
	array<bool> visited(4);
	int candy;
	
	bool toEnd;
	int endTimer, frame;
	
	[position, mode:WORLD, layer:19, y:tele_y]
    float tele_x;
    [hidden]
    float tele_y;
	
	[position, mode:WORLD, layer:19, y:text_y]
    float text_x;
    [hidden]
    float text_y;
	
	script() {
		@g = get_scene();
		@spr = create_sprites();
		@tc = create_canvas(true, 22, 15);
		@candy_text = create_textfield();
		candy_text.set_font("ProximaNovaReg", 36);
		candy_text.align_horizontal(-1);
		candy_text.align_vertical(-1);
		@taunt_text = create_textfield();
		taunt_text.set_font("ProximaNovaReg", 36);
		taunt_text.align_horizontal(0);
		taunt_text.align_vertical(0);
		
		add_broadcast_receiver("textTime", this, "textTime");
	}
	
	void textTime(string id, message@ msg) {
		if (msg.get_string("triggerType") == "textTrigger") {
			inbox = true;
			tbid = msg.get_int("id");
		}
		if (msg.get_string("triggerType") == "teleTrigger") {
			intele = true;
		}
	}
	
	void on_level_start() {
		@p = controller_controllable(0).as_dustman();
		spr.add_sprite_set("script");
		g.disable_score_overlay(true);
		
		textmode = false;
		inbox = false;
		intele = false;
		tbid = -1;
		
		candy = 0;
		frame = 0;
		
		for (uint i = 0; i < visited.length(); i++) {
			visited[i] = false;
		}
		toEnd = false;
		endTimer = -1;
		
		candy_text.text("Goal: acquire candy\nCandy: 0");
		taunt_text.text("taunt");
		taunttimer = -1;
	}
	
	void checkpoint_load() {
		@p = controller_controllable(0).as_dustman();
		spr.add_sprite_set("script");
		g.disable_score_overlay(true);
		
		textmode = false;
		inbox = false;
		intele = false;
		tbid = -1;
		
		for (uint i = 0; i < ftspots.length(); i++) {
			if (visited[i])
				if (@entity_by_id(fogtriggers[i]) != null)
					entity_by_id(fogtriggers[i]).set_xy(ftspots[i].x(), ftspots[i].y());
		}
	}
	
	void step(int entities) {
		p.combo_timer(1);
		p.skill_combo(1);
		px = p.x();
		py = p.y();
		
		if (frame < 55) {
			frame++;
		} else if (frame == 55) {
			frame = 69;
			add_textbox(-1);
		}
		
		if (!textmode) {
			if (p.taunt_intent() == 1) {
				if (inbox) {
					add_textbox(tbid);
					no_controls();
				}
				if (intele) {
					p.set_speed_xy(0, 0);
					p.x(tele_x);
					p.y(tele_y);
				}
				p.taunt_intent(2);
			}
		} else {
			if (p.taunt_intent() == 1) {
				if (tb.is_full()) {
					clear_textbox();
				} else {
					tb.full_text();
				}
			}
			tb.step();
			no_controls();
		}
		
		if (endTimer >= 0) {
			endTimer--;
			if (endTimer == 0)
				g.end_level(0, 0);
		}
		
		if (taunttimer >= 0) {
			taunttimer--;
		}
		if (inbox || intele) {
			taunttimer = 2;
		}
		
		inbox = false; //must go after all textTrigger behavior
		intele = false;
	}
	
	void editor_step() {
		//candy_text.text("Goal:");
	}
	
	void editor_draw(float subframe) {
		//tc.draw_text(candy_text, text_x, text_y, 1, 1, 0);
	}
	
	void draw(float subframe) {
		if (textmode) {
			tb.draw();
			spr.draw_hud(22, 10, "tbbg", 0, 1, -650, 146, 0, 1, 1, 0xFFFFFFFF);
		} else {
			if (taunttimer >= 0) {
				taunt_text.draw_world(20, 18, px, py - 120, 1, 1, 0);
			}
		}
		tc.draw_text(candy_text, text_x, text_y, 1, 1, 0);
	}
	
	void build_sounds(message@ msg) {
		msg.set_string("blip", "blip");
	}
	
	void build_sprites(message@ msg) {
		msg.set_string("tbbg", "tbbg");
	}
	
	void no_controls() {
		p.taunt_intent(2);
		p.jump_intent(2);
		p.dash_intent(2);
		p.light_intent(11);
		p.heavy_intent(11);
		p.x_intent(0);
		p.y_intent(0);
	}
	
	void add_textbox(int id) {
		p.set_speed_xy(0, p.y_speed());
		textmode = true;
		if (id == -1) {
			tb = textbox("It's Halloween, which means it's time to go trick-or-treating.\nThere are four houses in your neighborhood. You are immune\nto the combo timer due to a dark ritual. Use taunt to interact.");
		}
		if (id <= 4 && id > 0) {
			visited[id - 1] = true;
			entity_by_id(fogtriggers[id - 1]).set_xy(ftspots[id - 1].x(), ftspots[id - 1].y());
			
			if (id == 1) {
				//top right, has teleporter
				if (p.character() == "dustman")
					tb = textbox("Wow, cool dustman costume! I'm surprised you came all the\nway out here for candy. Luckily you can take my teleporter\nover there to the right!");
				else if (p.character() == "dustgirl")
					tb = textbox("Yo, nice dustgirl costume! I'm surprised you came all the\nway out here for candy. Luckily you can take my teleporter\nover there to the right!");
				else if (p.character() == "dustkid")
					tb = textbox("Aw, what a cute dustkid costume! I'm surprised you came all\nthe way out here for candy. Luckily you can take my teleporter\nover there to the right!");
				else if (p.character() == "dustworth")
					tb = textbox("Dang, sick dustworth costume! I'm surprised you came all the\nway out here for candy. Luckily you can take my teleporter\nover there to the right!");
			} else if (id == 2) {
				//bottom right
				if (p.character() == "dustman")
					tb = textbox("Good job getting here, definitely worthy of candy. I do hope you\nleft enough dustblocks to get back. Though you should be able\nto get back even without any.");
				if (p.character() == "dustgirl")
					tb = textbox("Good job getting here, definitely worthy of candy. I do hope you\nleft enough dustblocks to get back. Though you should be able\nto get back even without any. Yes, even you dustgirl.");
				if (p.character() == "dustkid")
					tb = textbox("Nice one getting here kid, definitely worthy of candy. I do hope\nyou left enough dustblocks to get back. Though you should be\nable to get back even without any.");
				if (p.character() == "dustworth")
					tb = textbox("Good job getting here, definitely worthy of candy. I do hope you\nleft enough dustblocks to get back. Though you should be able\nto get back even without any. Especially you dustworth.");
			} else if (id == 3) {
				//top left, has drop
				if (p.character() == "dustman")
					tb = textbox("Your broom is alright I guess, though I saw a girl with a cooler\none already. Either way you get candy for making it up here.\nAnd you get to fall down my chute to get back.");
				if (p.character() == "dustgirl")
					tb = textbox("I like your pushbroom, and your whole style, and the way you\ngot to the top of my tower. For that you get candy. And as a\nbonus you get to use the chute on your right to get back.");
				if (p.character() == "dustkid")
					tb = textbox("Sick dusters, they look like they could beat up a bear in three\nseconds. For making it up here, take some candy. I recommend\ntaking the chute on your right to get back faster.");
				if (p.character() == "dustworth")
					tb = textbox("Not surprising to see you at the top of a climb section. Well\neither way have some candy, just because that's a cool vacuum.\nAnd lucky you, you can use my chute to get back.");
			} else if (id == 4) {
				//bottom left
				tb = textbox("There's a sign saying \"please take one\" next to a bowl of candy.\nAs a law-abiding citizen of polite society, you follow the sign,\nand take only one candy.");
			}
			
			
		}
		if (id == 7) {
			bool ready = true;
			for (uint i = 0; i < visited.length(); i++) {
				if (!visited[i])
					ready = false;
			}
			if (ready) {
				tb = textbox("What a good Halloween, you got a lot of candy!\n                     \nThank you for playing.");
				toEnd = true;
			} else {
				if (candy == 0)
					tb = textbox("It is not time yet. You need candy.");
				else
					tb = textbox("It is not time yet. You need more candy.");
			}
		}
		if (id == 8) {
			tb = textbox("Music: Mario Party 2 Horror Land theme.");
		}
		if (id == 9) {
			tb = textbox("Left: Ogmur's Pillar, Formless City.\nRight: Birack's Facility, Nim's Grotto.");
		}
		if (id == 10) {
			//right fork
			tb = textbox("Up: Birack's Facility.\nDown: Nim's Grotto.\nLeft: Center of Town.");
		}
		if (id == 11) {
			//left fork
			tb = textbox("Up: Ogmur's Pillar.\nLeft: Formless City.\nRight: Center of Town.");
		}
		if (id == 69) {
			tb = textbox("What a stupid porcupine costume...                \nYou should kick this kid into the stratosphere.");
		}
		if (id == 70) {
			tb = textbox("I'm stuck down here! Luckily I was able to make this bench out\nof old twigs and trash people threw away. It's actually fine to\nsleep on once you're used to it.");
		}
	}
	
	void clear_textbox() {
		textmode = false;
		if (toEnd)
			endTimer = 3;
		else {
			candy = 0;
			for (uint i = 0; i < visited.length(); i++) {
				if (visited[i]) {
					if (i == 3)
						candy += 7;
					else 
						candy++;
				}
			}
			if (candy == 10) {
				candy_text.text("Goal: go home and rest\nCandy: 10");
			} else {
				candy_text.text("Goal: acquire candy\nCandy: " + candy);
			}
		}
	}

}

class textTrigger : trigger_base {
	
	scene@ g;
	scripttrigger@ self;
	controllable@ trigger_entity;
	[text] int id;

	textTrigger() {
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
		msg.set_int("id", id);
		msg.set_string("triggerType","textTrigger");
		broadcast_message("textTime", msg);
	}
	
}

class teleTrigger : trigger_base {
	
	scene@ g;
	scripttrigger@ self;
	controllable@ trigger_entity;
	[text] int id;

	teleTrigger() {
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
		msg.set_int("id", id);
		msg.set_string("triggerType","teleTrigger");
		broadcast_message("textTime", msg);
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