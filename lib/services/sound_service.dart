import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as dev;

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String assetPath) async {
    try {
      // stop current sound if playing to allow rapid fire sounds
      await _player.stop();
      // audioplayers AssetSource usually expects path relative to 'assets/' folder
      // but some versions or configs might differ. 
      // We will assume assetPath is relative to assets/ as per pubspec
      await _player.play(AssetSource(assetPath));
      dev.log('Playing sound: $assetPath', name: 'SoundService');
    } catch (e) {
      dev.log('Error playing sound ($assetPath): $e', name: 'SoundService');
      // Retry with assets/ prefix if first one fails
      if (!assetPath.startsWith('assets/')) {
        try {
          await _player.play(AssetSource('assets/$assetPath'));
          dev.log('Playing sound with assets/ prefix: $assetPath', name: 'SoundService');
        } catch (e2) {
          dev.log('Retry failed ($assetPath): $e2', name: 'SoundService');
        }
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}
