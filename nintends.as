#include "pos.as"
const string EMBED_buttons = "action-buttons.png";
const string EMBED_highlight = "action-highlight.png";
class script : callback_base {

	scene@ g;
	camera@ cam;
	dustman@ p;
	sprites@ spr;
	
	[text] pos firstCam;
	[text] pos secondCam;
	[text] float screenHeight;
	bool firstScreen;
	
	[entity] uint firstFlag;
	[text] pos secondStart;
	
	[text] pos buttonTopLeft;
	float buttonHeight, buttonWidth;
	
	bool lfJump, lfDash;
	int lightCount, heavyCount;
	
	script() {
		@g = get_scene();
	}
	
	void on_level_start() {
		@cam = get_active_camera();
		cam.script_camera(true);
		
		@p = controller_controllable(0).as_dustman();
		
		@spr = create_sprites();
		spr.add_sprite_set("script");
		
		firstScreen = true;
		placeFirstCam();
		
		buttonHeight = 336;
		buttonWidth = 696;
		
		lfJump = lfDash = false;
		lightCount = heavyCount = 0;
	}
	
	void step(int entities) {
		if (firstScreen) {
			if (entity_by_id(firstFlag) == null) {
				firstScreen = false;
				placeSecondCam();
				p.x(secondStart.x());
				p.y(secondStart.y());
			}
		}
		
		bool something = false;
		if ((g.mouse_state(0) / 4) % 2 == 1) {
			float mouseX = g.mouse_x_world(0, 19);
			float mouseY = g.mouse_y_world(0, 19);
			if (!firstScreen)
				mouseY -= 2112;
			if (mouseX >= buttonTopLeft.x() && mouseX <= buttonTopLeft.x() + buttonWidth) {
				//left two buttons
				if (mouseY >= buttonTopLeft.y() && mouseY <= buttonTopLeft.y() + buttonHeight) {
					p.jump_intent(1);
					p.dash_intent(0);
					lfDash = false;
					p.light_intent(0);
					lightCount = 0;
					p.heavy_intent(0);
					heavyCount = 0;
					if (p.jump_intent() > 0 && lfJump)
						p.jump_intent(2);
					else
						lfJump = false;
					something = true;
				} else if (mouseY >= buttonTopLeft.y() + buttonHeight + 48 && mouseY <= buttonTopLeft.y() + 2 * buttonHeight + 48) {
					p.light_intent(10);
					something = true;
					p.jump_intent(0);
					lfJump = false;
					p.dash_intent(0);
					lfDash = false;
					p.heavy_intent(0);
					heavyCount = 0;
					if (p.light_intent() == 10 && lightCount == 11)
						p.light_intent(11);
					else if (p.light_intent() == 0) {
						if (lightCount == 11)
							lightCount = 0;
						else if (lightCount > 0) {
							lightCount--;
							p.light_intent(lightCount);
						}
					}
				}
			} else if (mouseX >= buttonTopLeft.x() + buttonWidth + 48 && mouseX <= buttonTopLeft.x() + 2 * buttonWidth + 48) {
				//right two buttons
				if (mouseY >= buttonTopLeft.y() && mouseY <= buttonTopLeft.y() + buttonHeight) {
					if (!lfDash) {
						if (p.y_intent() == 1)
							p.fall_intent(1);
						else 
							p.dash_intent(1);
						lfDash = true;
					}
					something = true;
					p.jump_intent(0);
					lfJump = false;
					p.light_intent(0);
					lightCount = 0;
					p.heavy_intent(0);
					heavyCount = 0;
				} else if (mouseY >= buttonTopLeft.y() + buttonHeight + 48 && mouseY <= buttonTopLeft.y() + 2 * buttonHeight + 48) {
					p.heavy_intent(10);
					something = true;
					p.jump_intent(0);
					lfJump = false;
					p.dash_intent(0);
					lfDash = false;
					p.light_intent(0);
					lightCount = 0;
					if (p.heavy_intent() == 10 && heavyCount == 11)
						p.heavy_intent(11);
					else if (p.heavy_intent() == 0) {
						if (heavyCount == 11)
							heavyCount = 0;
						else if (heavyCount > 0) {
							heavyCount--;
							p.heavy_intent(heavyCount);
						}
					}
				}
			}
		}
		if (!something) {
			p.jump_intent(0);
			lfJump = false;
			p.dash_intent(0);
			lfDash = false;
			p.light_intent(0);
			lightCount = 0;
			p.heavy_intent(0);
			heavyCount = 0;
		}
	}
	
	void step_post(int entities) {
		if (p.jump_intent() == 2)
			lfJump = true;
		if (p.light_intent() > 9)
			lightCount = p.light_intent();
		if (p.heavy_intent() > 9)
			heavyCount = p.heavy_intent();
	}
	
	void draw(float subframe) {
		if (firstScreen) {
			spr.draw_world(20, 15, "buttons", 0, 1, buttonTopLeft.x(), buttonTopLeft.y(), 0, 1, 1, 0xFFFFFFFF);
			if (p.jump_intent() > 0)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x(), buttonTopLeft.y(), 0, 1, 1, 0xFFFFFFFF);
			if (lfDash)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x() + buttonWidth + 48, buttonTopLeft.y(), 0, 1, 1, 0xFFFFFFFF);
			if (p.light_intent() > 0)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x(), buttonTopLeft.y() + buttonHeight + 48, 0, 1, 1, 0xFFFFFFFF);
			if (p.heavy_intent() > 0)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x() + buttonWidth + 48, buttonTopLeft.y() + buttonHeight + 48, 0, 1, 1, 0xFFFFFFFF);
		} else {
			spr.draw_world(20, 15, "buttons", 0, 1, buttonTopLeft.x(), buttonTopLeft.y() + 2112, 0, 1, 1, 0xFFFFFFFF);
			if (p.jump_intent() > 0)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x(), buttonTopLeft.y() + 2112, 0, 1, 1, 0xFFFFFFFF);
			if (lfDash)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x() + buttonWidth + 48, buttonTopLeft.y() + 2112, 0, 1, 1, 0xFFFFFFFF);
			if (p.light_intent() > 0)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x(), buttonTopLeft.y() + buttonHeight + 48 + 2112, 0, 1, 1, 0xFFFFFFFF);
			if (p.heavy_intent() > 0)
				spr.draw_world(20, 16, "highlight", 0, 1, buttonTopLeft.x() + buttonWidth + 48, buttonTopLeft.y() + buttonHeight + 48 + 2112, 0, 1, 1, 0xFFFFFFFF);
		}
			
	}
	
	void build_sprites(message@ msg) {
		msg.set_string("buttons", "buttons");
		msg.set_string("highlight", "highlight");
	}
	
	void placeFirstCam() {
		cam.x(firstCam.x());
		cam.prev_x(firstCam.x());
		cam.y(firstCam.y());
		cam.prev_y(firstCam.y());
		
		cam.scale_x(1080.0 / screenHeight);
		cam.prev_scale_x(1080.0 / screenHeight);
		cam.scale_y(1080.0 / screenHeight);
		cam.prev_scale_y(1080.0 / screenHeight);
	}
	
	void placeSecondCam() {
		cam.x(secondCam.x());
		cam.prev_x(secondCam.x());
		cam.y(secondCam.y());
		cam.prev_y(secondCam.y());
		
		cam.scale_x(1080.0 / screenHeight);
		cam.prev_scale_x(1080.0 / screenHeight);
		cam.scale_y(1080.0 / screenHeight);
		cam.prev_scale_y(1080.0 / screenHeight);
	}

}