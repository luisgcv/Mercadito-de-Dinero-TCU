import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Un solo reproductor reutilizable
  static final AudioPlayer _player = AudioPlayer();

  // Sonido de éxito
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
