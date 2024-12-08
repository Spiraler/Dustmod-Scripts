#include "Others/lib/drawing/Sprite.cpp"
const string EMBED_music = "boost_song.ogg";
const string EMBED_chirp = "chirp.ogg";
const string EMBED_wyad = "wyad.ogg";
const string EMBED_shake = "shake.png";
const string EMBED_phone = "phone.png";
const string EMBED_meatwad = "meatwad.png";
const string EMBED_frylock = "frylock.png";
class script : callback_base {

	scene@ g;
	Sprite shake = Sprite("script", "shake", 0.5, 1);
	Sprite phone = Sprite("script", "phone", 0.5, 1);
	Sprite meatwad = Sprite("script", "meatwad", 0.5, 1);
	Sprite frylock = Sprite("script", "frylock", 0.5, 1);
	float sx, sy;
	float px, py;
	float mx, my;
	float fx, fy;
	int t;
	float rot;
	
	script() {
		@g = get_scene();
		
		sx = -625;
		sy = -100;
		px = 625;
		py = -100;
		mx = -625;
		my = 350;
		fx = 625;
		fy = 400;
		t = rot = 0;
		
	}
	
	void on_level_start() {
		g.play_persistent_stream("music", 1, true, 1, true);
		g.override_sound("sfx_impact_heavy_1", "wyad", true);
		g.override_sound("sfx_impact_heavy_2", "wyad", true);
		g.override_sound("sfx_impact_heavy_3", "wyad", true);
		g.override_sound("sfx_impact_light_1", "chirp", true);
		g.override_sound("sfx_impact_light_2", "chirp", true);
		g.override_sound("sfx_impact_light_3", "chirp", true);
	}
	
	void step(int entities) {
		t += 6;
		rot = 20 * sin(t * DEG2RAD);
	}
	
	void draw(float subframe) {
		shake.draw_hud(20, 17, 0, 1, sx, sy, rot);
		phone.draw_hud(20, 17, 0, 1, px, py, -1 * rot);
		meatwad.draw_hud(20, 17, 0, 1, mx, my, rot);
		frylock.draw_hud(20, 17, 0, 1, fx, fy, 0);
	}
	
	void build_sounds(message@ msg) {
		msg.set_string("music", "music");
		msg.set_int("music|loop", 0);
		msg.set_string("chirp", "chirp");
		msg.set_string("wyad", "wyad");
	}
	
	void build_sprites(message@ msg) {
		msg.set_string("shake", "shake");
		msg.set_string("phone", "phone");
		msg.set_string("meatwad", "meatwad");
		msg.set_string("frylock", "frylock");
	}

}