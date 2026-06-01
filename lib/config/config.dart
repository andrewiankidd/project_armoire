
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {

  static String deviceId;

  static const String _playerIdKey = 'playerId';

  Future init() async {
    developer.log('init', name: 'project_armoire.Config');

    Config.deviceId = await _resolveStableId();

    if (!kIsWeb && File(".env").existsSync()){
      return dotenv.load(fileName: ".env");
    }
  }

  // a stable id that survives reloads (incl. web via localStorage); derived once
  // from the device id (or random) and then persisted + reused
  Future<String> _resolveStableId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_playerIdKey);
      if (existing != null && existing.isNotEmpty) {
        return existing;
      }
      final generated = await _generateId();
      await prefs.setString(_playerIdKey, generated);
      return generated;
    } catch (e) {
      // storage unavailable: fall back to a non-persisted id (cull cleans up)
      developer.log('could not persist player id: $e', name: 'project_armoire.Config');
      return _generateId();
    }
  }

  Future<String> _generateId() async {
    // prefer the platform device id (stable on native); fall back to random
    try {
      final id = (await PlatformDeviceId.getDeviceId)?.trim();
      if (id != null && id.isNotEmpty) {
        return id;
      }
    } catch (e) {
      developer.log('device id unavailable: $e', name: 'project_armoire.Config');
    }
    return 'player-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
  }

  String get({String configKey, String defaultValue = null}) {
    developer.log('get($configKey)', name: 'project_armoire.Config');
    if (dotenv.isInitialized && dotenv.env.containsKey(configKey) && dotenv.env[configKey].isNotEmpty){
      return dotenv.env[configKey];
    } else {
      return defaultValue;
    }
  }
}