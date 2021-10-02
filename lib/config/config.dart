
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {

  Future init() async {
    return dotenv.load(fileName: ".env");
  }

  String get(String configKey) {
    return dotenv.env[configKey];
  }
}