class SeedGenerator {

	scene@ g;
	uint seed, t;
	
	/* This array should stay at 4 entities. You can assign any entities to it
	 * but I recommend using script entities (the scrolls at the bottom of the 
	 * entity menu). You must also declare your SeedGenerator with [text].
	 * These entities MUST be close to where the player spawns.
	 */
	[entity] array<uint> encoders(4);
	
	array<int> encoderXs(4);
	
	SeedGenerator() {
		@g = get_scene();
		t = 0;
	}
	
	/* Call this every step from the start of the level until at least
	 * ready() returns true.
	 */
	void step() {
		if (t == 0)
			locateEncoders();
		if (t == 10 && !is_replay())
			generateSeed();
		if (t == 20 && is_replay())
			calculateSeed();
		t++;
	}
	
	/* Returns true if the seed is ready, false otherwise.
	 */
	bool ready() {
		return t > 20;
	}
	
	void locateEncoders() {
		for (uint i = 0; i < encoders.size(); i++) {
			encoderXs[i] = int(entity_by_id(encoders[i]).x());
			entity_by_id(encoders[i]).x(encoderXs[i]);
		}
	}
	
	uint generateSeed() {
		seed = uint32(timestamp_now());
		seed *= 527;
		puts("seed is " + seed);
		for (uint i = 0; i < encoders.size(); i++) {
			int newpos = encoderXs[i];
			newpos += (seed / (1 << (i*8))) % 256 + 300;
			entity_by_id(encoders[i]).x(newpos);
		}
		return seed;
	}
	
	uint calculateSeed() {
		uint guess = 0;
		for (uint i = 0; i < encoders.size(); i++) {
			uint theByte = uint32(floor(entity_by_id(encoders[i]).x() - encoderXs[i] - 299.5));
			guess += theByte * uint32(1 << (i*8));
		}
		puts("I think the seed was " + guess);
		seed = guess;
		return guess;
	}
	
	uint getSeed() {
		return seed;
	}
	
}


class ByteEncoder : enemy_base {
	/* This is a dummy class that your script entities should be assigned to.
	 */
}
