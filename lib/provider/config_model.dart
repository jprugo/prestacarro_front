import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/config.dart';

class ConfigModel extends ChangeNotifier {
  late Config config;

  ConfigModel() {
    final file = File(r'C:\PrestaCarroDesktop\config.json');
    config = Config.fromJson(json.decode(file.readAsStringSync()));
    print(config.toJson());
  }
}
