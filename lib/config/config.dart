
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {

  Future init() async {
    developer.log('init', name: 'project_armoire.Config');
    return dotenv.load(fileName: ".env");
  }

  String get(String configKey) {
    developer.log('get($configKey)', name: 'project_armoire.Config');
    return dotenv.env[configKey];
  }
}