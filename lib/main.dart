import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'application.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      webProvider: ReCaptchaV3Provider('e34aba3c-0939-41c7-9e92-e3717360b26e'), //4D47DCDC-8B10-40D4-AFBE-7C4E7F2C6E21 oder 6Ldwr2wqAAAAAI_6F_2UbsXlNB5fsoWnTxNv_Tho
    );
    runApp(Application());
  } catch (e, stackTrace) {
    if (e is ArgumentError) {
      print('ArgumentError: $e');
      print('Invalid argument: ${e.invalidValue}');
      print('Name: ${e.name}');
      print('Message: ${e.message}');
    } else if (e is PlatformException) {
      print('PlatformException: $e');
    } else if (e is TypeError) {
      print('TypeError: $e');
    } else {
      print('Error initializing Firebase: $e');
    }
    print('Stack trace: $stackTrace');
  }
}