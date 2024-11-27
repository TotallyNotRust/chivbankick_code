import 'dart:async';

import 'package:chivbankick/models/user.dart';
import 'package:dio/dio.dart';

class ApiStuff {
  ApiStuff() {
    Timer.periodic(const Duration(minutes: 1), (timer) { 
      ApiStuff.userFetchCount = 0;
    });
  }

  static int userFetchCount = 0; 


  static Future<User?> fetchUser(String playfabID) async {
    if (userFetchCount >= 20) return null; 
    userFetchCount += 1;

    var data = await Dio().get("https://chivalry2stats.com:8443/api/player/findByPlayFabId/$playfabID");
    return User.fromMap(data.data!);
  }
}