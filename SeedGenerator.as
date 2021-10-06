class SeedGenerator {

	scene@ g;
	uint seed;
	
	/* This array should stay at 4 entities. You can assign any entities to it
	 * but I recommend using script entities (the scrolls at the bottom of the 
	 * entity menu). You must also declare your SeedGenerator with [text].
	 * These entities MUST be close to where the player spawns.
	 */
	[entity] array<uint> encoders(4);
	
	array<float> encoderXs(4);
	
	SeedGenerator() {
		@g = get_scene();
	}
	
	/* Call this on level start before anything below regardless of replay or not.
	 */
	void locateEncoders() {
		for (uint i = 0; i < encoders.size(); i++) {
			encoderXs[i] = entity_by_id(encoders[i]).x();
		}
	}
	
	/* Call this a bit after level start if it's not a replay. I had success
	 * calling it on frame 13 of the level but earlier might be possible.
	 * The script entities chosen in the editor will be moves a certain amount
	 * so that their location is logged in the replay.
	 */
	uint generateSeed() {
		seed = uint32(timestamp_now());
		seed *= 527;
		puts("seed is " + seed);
		for (uint i = 0; i < encoders.size(); i++) {
			float newpos = encoderXs[i];
			newpos += seed / (1 << (i*8)) % 256 + 300;
			entity_by_id(encoders[i]).x(newpos);
		}
		return seed;
	}
	
	/* Call this at least 10 frames later than generateSeed() if it is a replay. The 
	 * replay tracks entities and will displace the encoders the same as they were 
	 * when the level was originally played, and this function tracks that 
	 * displacement and recreates the seed.
	 */
	uint calculateSeed() {
		uint guess = 0;
		for (uint i = 0; i < encoders.size(); i++) {
			uint theByte = uint32(floor(entity_by_id(encoders[i]).x() - encoderXs[i] - 300));
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
