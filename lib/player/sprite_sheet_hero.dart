import 'package:bonfire/bonfire.dart';

class SpriteSheetHero {
  static Future<void> load() async {
    current = cloaked = await _create('cloaked.png');
    uncloaked = await _create('uncloaked.png');
    //hero3 = await _create('hero3.png');
    //hero4 = await _create('hero4.png');
    //hero5 = await _create('hero5.png');
  }

  static Future<SpriteSheet> _create(String path) async {
    final image = await Flame.images.load(path);
    return SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 13,
      rows: 21,
    );
  }

  static SpriteSheet current;
  static SpriteSheet cloaked;
  static SpriteSheet uncloaked;
  static SpriteSheet hero3;
  static SpriteSheet hero4;
  static SpriteSheet hero5;
}
