import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    // ─── Web config ───
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDI2pL6HhEx08IU8xf5aW1zbY-WHOAOpB0",
        authDomain: "dii-library.firebaseapp.com",
        projectId: "dii-library",
        storageBucket: "dii-library.firebasestorage.app",
        messagingSenderId: "797503405765",
        appId: "1:797503405765:web:579c3e8a13a03478607aac",
      ),
    );
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    // ─── Android config ───
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCEmWLxLIuW2rZOyBrHXZIn52b9HiEMK6I",
        appId: "1:797503405765:android:ad0e9cc5583225ca607aac",
        messagingSenderId: "797503405765",
        projectId: "dii-library",
        storageBucket: "dii-library.firebasestorage.app",
      ),
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    // ─── iOS config ───
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCEmWLxLIuW2rZOyBrHXZIn52b9HiEMK6I",
        appId: "1:797503405765:ios:0000000000000000000000",
        messagingSenderId: "797503405765",
        projectId: "dii-library",
        storageBucket: "dii-library.firebasestorage.app",
        iosBundleId: "com.mycompany.diilibrary",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
}
