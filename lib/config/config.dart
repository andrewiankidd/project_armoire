
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Config {

  static String deviceId;

  Future init() async {
    developer.log('init', name: 'project_armoire.Config');

    // platform_device_id has no web implementation and can throw / return null,
    // so guard it and fall back to a generated id
    try {
      Config.deviceId = (await PlatformDeviceId.getDeviceId)?.trim();
    } catch (e) {
      developer.log('could not resolve device id: $e', name: 'project_armoire.Config');
    }
    if (Config.deviceId == null || Config.deviceId.isEmpty) {
      Config.deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';
    }

    if (!kIsWeb && File(".env").existsSync()){
      return dotenv.load(fileName: ".env");
    }
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