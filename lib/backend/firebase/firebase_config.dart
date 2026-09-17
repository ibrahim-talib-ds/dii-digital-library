import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDI2pL6HhEx08IU8xf5aW1zbY-WHOAOpB0",
            authDomain: "dii-library.firebaseapp.com",
            projectId: "dii-library",
            storageBucket: "dii-library.firebasestorage.app",
            messagingSenderId: "797503405765",
            appId: "1:797503405765:web:579c3e8a13a03478607aac"));
  } else {
    await Firebase.initializeApp();
  }
}
