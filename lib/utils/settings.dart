

import 'package:flutter/material.dart';

class Settings {
    static final Settings _settings = Settings._internal();
  
  factory Settings(BuildContext context) {
    return _settings;
  }
  
  Settings._internal();
}