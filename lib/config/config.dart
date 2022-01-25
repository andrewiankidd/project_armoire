
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Config {

  static String deviceId;

  Future init() async {
    developer.log('init', name: 'project_armoire.Config');
    Config.deviceId = (await PlatformDeviceId.getDeviceId).trim();
    return dotenv.load(fileName: ".env");
  }

  String get(String configKey) {
    developer.log('get($configKey)', name: 'project_armoire.Config');
    return dotenv.env[configKey];
  }
}