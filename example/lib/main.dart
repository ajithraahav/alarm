import 'dart:async';
import 'package:alarm_example/provider.dart/provider.dart';
import 'package:alarm_example/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init(showDebugLogs: true);

  runApp(
    ChangeNotifierProvider(
      create:(context) => AlarmProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ExampleAlarmHomeScreen(),
      ),
    ),
  );
}
