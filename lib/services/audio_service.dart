import 'package:audioplayers/audioplayers.dart';

/// Reproduce los efectos de sonido de la app.
///
/// Usa un único [AudioPlayer] estático compartido. Los sonidos deben estar
/// en `assets/sounds/` **y** declarados en la sección `assets` de
/// `pubspec.yaml`; si no, no se empaquetan en la app.
class AudioService {
  /// Reproductor reutilizable (evita crear uno nuevo por cada sonido).
  static final AudioPlayer _player = AudioPlayer();

  /// Reproduce `assets/sounds/success.mp3` ("beep" de caja registradora)
  /// cuando se agrega un producto al carrito. Si ya se estaba reproduciendo,
  /// lo reinicia. Los errores se ignoran para no interrumpir la compra.
  static Future<void> playSuccess() async {
    try {
      await _player.stop();

      await _player.setVolume(1.0);

      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      print("Error reproduciendo success: $e");
    }
  }
}
