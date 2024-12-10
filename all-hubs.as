#include "SeedGenerator.as"
#include "pos.as"
class script : callback_base {

	scene@ g;
	
	SeedGenerator s;
	bool seedset;
	
	[text] pos TopLeft;
	[text] pos BotRight;
	
	[text] array<pos> smallSpawners;
	[text] array<pos> bearSpawners;
	array<string> smalls;
	array<string> bears;
	
	[text] array<pos> tileref;
	
	array<uint> endFlag;
	bool noSpread;
	
	script() {
		@g = get_scene();
	}
	
	void on_level_start() {
		s = SeedGenerator();
		seedset = false;
		
		array<string> stemp = {"enemy_critter", "enemy_gargoyle_small", "enemy_trash_ball", "enemy_slime_ball"};
		smalls = stemp;
		array<string> btemp = {"enemy_bear", "enemy_knight", "enemy_trash_beast", "enemy_slime_beast"};
		bears = btemp;
		array<uint> etemp = {0, 0, 0, 0};
		endFlag = etemp;
		
		noSpread = false;
	}
	
	void step(int entities) {
		if (!seedset) {
			if (!s.ready()) {
				s.step();
			} else {
				srand(s.getSeed());
				seedset = true;
				becomeHub(rand() % 4);
			}
		}
	}
	
	void becomeHub(int type) {
		//spawn enemy_critter enemy_gargoyle_small enemy_trash_ball enemy_slime_ball
		for (int i = 0; i < smallSpawners.length(); i++) {
			entity@ e = create_entity(smalls[type]);
			e.x(smallSpawners[i].x());
			e.y(smallSpawners[i].y());
			g.add_entity(e);
			//the following code is from Ukkiez
			entity@ ai = create_entity("AI_controller");
			ai.x(e.x());
			ai.y(e.y());
			
			varstruct@ vars = ai.vars();
			vars.get_var("puppet_id").set_int32(e.id());
			vararray@ nodes = vars.get_var("nodes").get_array();
			vararray@ nodes_wait_time = vars.get_var("nodes_wait_time").get_array();
			
			nodes.resize(1);
			nodes_wait_time.resize(1);
			nodes.at(0).set_vec2(e.x(), e.y());
			nodes_wait_time.at(0).set_int32(0);
			
			g.add_entity(ai);
			
			if (i == 4 || i == 5 || i == 6) {
				endFlag[i - 4] = e.id();
			}
		}
		
		//spawn enemy_bear enemy_knight enemy_trash_beast enemy_slime_beast
		for (int i = 0; i < bearSpawners.length(); i++) {
			entity@ e = create_entity(bears[type]);
			e.x(bearSpawners[i].x());
			e.y(bearSpawners[i].y());
			g.add_entity(e);
			//the following code is from Ukkiez
			entity@ ai = create_entity("AI_controller");
			ai.x(e.x());
			ai.y(e.y());
			
			varstruct@ vars = ai.vars();
			vars.get_var("puppet_id").set_int32(e.id());
			vararray@ nodes = vars.get_var("nodes").get_array();
			vararray@ nodes_wait_time = vars.get_var("nodes_wait_time").get_array();
			
			nodes.resize(1);
			nodes_wait_time.resize(1);
			nodes.at(0).set_vec2(e.x(), e.y());
			nodes_wait_time.at(0).set_int32(0);
			
			g.add_entity(ai);
			
			if (i == 3) {
				endFlag[3] = e.id();
			}
		}
		
		tileinfo@ tref = g.get_tile(int32(tileref[type].x() / 48), int32(tileref[type].y() / 48 - 1), 19);
		tileinfo@ btref = g.get_tile(int32(tileref[type].x() / 48), int32(tileref[type].y() / 48 - 1), 15);
		int filth = 1;
		if (type == 0)
			filth = 2;
		if (type >= 2)
			filth = type + 1;
		int t = int32(TopLeft.y() / 48) - 2;
		int b = int32(BotRight.y() / 48) + 2;
		int l = int32(TopLeft.x() / 48) - 2;
		int r = int32(BotRight.x() / 48) + 2;
		
		for (int i = t; i <= b; i++) {
			for (int j = l; j <= r; j++) {
				tileinfo@ tin = g.get_tile(j, i);
				tin.sprite_set(tref.sprite_set());
				tin.sprite_tile(tref.sprite_tile());
				tin.sprite_palette(tref.sprite_palette());
				g.set_tile(j, i, 19, tin, true);
				
				tileinfo@ btin = g.get_tile(j, i, 15);
				btin.sprite_set(btref.sprite_set());
				btin.sprite_tile(btref.sprite_tile());
				btin.sprite_palette(btref.sprite_palette());
				g.set_tile(j, i, 15, btin, true);
				
				tilefilth@ tif = g.get_tile_filth(j, i);
				if (tif.top() > 0)
					tif.top(filth);
				if (tif.bottom() > 0)
					tif.bottom(filth);
				if (tif.left() > 0)
					tif.left(filth);
				if (tif.right() > 0)
					tif.right(filth);
				g.set_tile_filth(j, i, tif);
			}
		}
	}
	
	void entity_on_add(entity@ e) {
		if (noSpread && e.type_name() == 'filth_ball') {
			g.remove_entity(e);
		}
	}
	
	void entity_on_remove(entity@ e) {
		if (seedset) {
			for (int i = 0; i < endFlag.length(); i++) {
				if (e.id() == endFlag[i]) {
					endFlag[i] = 0;
					if (checkEnd()) {
						noSpread = true;
						g.end_level(0, 0);
					}
				}
			}
		}
	}
	
	bool checkEnd() {
		uint sum = 0;
		for (int i = 0; i < endFlag.length(); i++)
			sum += endFlag[i];
		return sum == 0;
	}
	
	void draw(float subframe) {
		if (!seedset) {
			g.draw_rectangle_hud(1, 1, -850, -500, 850, 500, 0, 0xFF3E1E7B);
		}
	}

}