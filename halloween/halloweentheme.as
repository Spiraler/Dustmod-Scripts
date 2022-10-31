const string EMBED_sound1 = "halloween.ogg";

class script {
  scene@ g;
  [text] float volume;

  script() {
    @g = get_scene();
  }

  void build_sounds(message@ msg) {
    msg.set_string("test1", "sound1");
    msg.set_int("test1|loop", 2822); // 2 seconds in
  }

  void on_level_start() {
    g.play_persistent_stream("test1", 1, true, volume, true);
  }
}