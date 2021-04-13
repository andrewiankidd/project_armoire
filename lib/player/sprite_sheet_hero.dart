import 'package:bonfire/bonfire.dart';

class SpriteSheetHero {
  static SpriteSheet _create(String path) {
    return SpriteSheet(
      imageName: path,
      textureWidth: 64,
      textureHeight: 64,
      columns: 9,
      rows: 21,
    );
  }

  static SpriteSheet current = SpriteSheetHero.cloaked;
  static SpriteSheet get cloaked => _create('cloaked.png');
  static SpriteSheet get uncloaked => _create('uncloaked.png');
  static SpriteSheet get hero3 => _create('hero3.png');
  static SpriteSheet get hero4 => _create('hero4.png');
  static SpriteSheet get hero5 => _create('hero5.png');
}
