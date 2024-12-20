#include "pos.as"
class script : callback_base {

	scene@ g;
	camera@ cam;
	dustman@ p;
	
	[text] pos topCam;
	[text] pos bottomCam;
	[text] float screenHeight;
	bool top;
	
	int com;
	
	script() {
		@g = get_scene();
	}
	
	void on_level_start() {
		@p = controller_controllable(0).as_dustman();
		
		@cam = get_active_camera();
		cam.script_camera(true);
		cam.scale_x(1080 / screenHeight);
		cam.scale_y(1080 / screenHeight);
		cam.prev_scale_x(1080 / screenHeight);
		cam.prev_scale_y(1080 / screenHeight);
		goTopCam();
		
		top = true;
		
		com = p.combo_count();
	}
	
	void step(int entities) {
		if (top) {
			if (p.x() > 0) {
				top = false;
				p.y(p.y() + 1344);
				goBottomCam();
			}
		} else {
			if (p.x() < 0) {
				top = true;
				p.y(p.y() - 1344);
				goTopCam();
			}
		}
		
		if (com != p.combo_count()) {
			update_filth();
		}
		com = p.combo_count();
	}
	
	void update_filth() {
		int cx = p.x() / 48;
		int cy = p.y() / 48 - 1;
		for (int i = cy - 8; i < cy + 9; i++) {
			for (int j = cx - 8; j < cx + 9; j++) {
				if (top || j >= 0) {
					tilefilth@ tif = g.get_tile_filth(j, i);
					int temp = tif.left();
					tif.left(tif.right());
					tif.right(temp);
					g.set_tile_filth(-j - 1, i, tif);
				}
			}
		}
	}
	
	void entity_on_remove(entity@ e) {
		if (e.type_name() == "enemy_tutorial_hexagon" || e.type_name() == "enemy_tutorial_square") {
			hitbox@ h = create_hitbox(p.as_controllable(), 0, -e.x(), e.y(), -5, 5, -5, 5);
			h.damage(4);
			g.add_entity(h.as_entity(), false);
		}
	}
	
	void entity_on_add(entity@ e) {
		if (e.type_name() == "filth_ball" && e.as_filth_ball().filth_type() != 2) {
			filth_ball@ fb = create_filth_ball(2, -e.x(), e.y(), e.base_rectangle().right(), e.base_rectangle().bottom(), -e.as_filth_ball().direction(), e.as_filth_ball().distance());
			fb.state_timer(e.as_filth_ball().state_timer());
			g.add_entity(fb.as_entity(), false);
			
			e.as_filth_ball().filth_type(2);
		}
	}
	
	void goTopCam() {
		cam.x(topCam.x());
        cam.y(topCam.y());
		cam.prev_x(topCam.x());
		cam.prev_y(topCam.y());
	}
	
	void goBottomCam() {
		cam.x(bottomCam.x());
        cam.y(bottomCam.y());
		cam.prev_x(bottomCam.x());
		cam.prev_y(bottomCam.y());
	}

}