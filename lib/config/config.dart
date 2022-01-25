
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Config {

  static String deviceId;

  Future init() async {
    developer.log('init', name: 'project_armoire.Config');
    Config.deviceId = (await PlatformDeviceId.getDeviceId).trim();

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