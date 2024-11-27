import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:chivbankick/pages/default.dart';
import 'package:chivbankick/utils/apistuff.dart';
import 'package:chivbankick/utils/utils.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    // ignore: implicit_call_tearoffs
    locationBuilder: RoutesLocationBuilder(
      routes: {
        // Return either Widgets or BeamPages if more customization is needed
        '/': (context, state, data) => const MyHomePage(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    ApiStuff();
    return MaterialApp.router(
      title: "Admin GUI",
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
