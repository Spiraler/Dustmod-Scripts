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

class posHud {
	
	[position,mode:hud,y:Y] float X;
	[hidden] float Y;
	
	posHud() {
		
	}
	
	float x() {
		return X;
	}
	
	float y() {
		return Y;
	}
	
}