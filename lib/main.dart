import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gold_scraper/home.dart';
import 'package:gold_scraper/push_notifications_service.dart';
import 'package:provider/provider.dart';

import 'controller.dart';

bool enableEmulators = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationService.registerBackgroundService();

  if (kDebugMode && enableEmulators) {
    log("Running on Debug...");
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 5004);
  }

  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MainController()),
      ],
      child: MaterialApp(
        title: 'Gold Scraper',
        themeMode: ThemeMode.dark,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.yellow.shade700,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
