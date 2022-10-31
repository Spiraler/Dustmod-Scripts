class textbox {
	
	scene@ g;
	canvas@ tc;
	textfield@ tf;
	
	string text; //the full text that will be written
	string currentText; //the text as it is writing in
	int t; //timer for adding next character
	uint n; //number of characters currently written
	
	textbox(string tex) {
		@g = get_scene();
		@tc = create_canvas(true, 22, 15);
		@tf = create_textfield();
		tf.set_font("ProximaNovaReg", 42);
		tf.align_horizontal(-1);
		tf.align_vertical(-1);
		
		text = tex;
		t = 0;
		n = 0;
	}
	
	textbox() {
		@g = get_scene();
		@tc = create_canvas(true, 22, 15);
		@tf = create_textfield();
		tf.set_font("ProximaNovaReg", 42);
		tf.align_horizontal(-1);
		tf.align_vertical(-1);
		
		text = "You aren't supposed to see this.";
		t = 0;
		n = 0;
	}
	
	//call every frame this textbox is active
	void step() {
		if (t == 0) {
			if (n < text.length()) {
				next_text();
			}
			tf.text(currentText);
		}
		t--;
	}
	
	//draw function
	void draw() {
		//g.draw_rectangle_hud(22, 10, -650, 170, 650, 360, 0, 0xFF000000);
		tc.draw_text(tf, -590, 206, 1, 1, 0);
	}
	
	//adds one more character to the currentText string
	//should only be called internally
	void next_text() {
		n++;
		currentText = text.substr(0, n);
		string c = text.substr(n - 1, 1);
		if (c >= "A" && c <= "z") {
			//initialize the blip in the main part of the script like you would any sound
			g.play_script_stream("blip", 0, 0, 0, false, 10);
		}
		if (c == "." || c == "?" || c == "!") {
			t = 20;
		} else if (c == ",") {
			t = 12;
		} else {
			t = 3;
		}
	}
	
	//used to determine whether this should be closed or made full
	bool is_full() {
		return n == text.length();
	}
	
	//call this when the player hits a button to skip the scrolling
	void full_text() {
		g.play_script_stream("blip", 0, 0, 0, false, 10);
		n = text.length();
		currentText = text;
	}
	
	void clear_text() {
		currentText = "";
		n = 0;
		t = 0;
	}
	
}