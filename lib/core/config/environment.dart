import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Environment {
  static String get fileName => 'dotenv';

  static String get signalRUrl => dotenv.env['SIGNAL_R_URL'] ?? 'SIGNAL_R URL NOT FOUND';
}
