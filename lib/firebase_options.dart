import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for Web.
///
/// วิธีเอาค่ามาใส่:
/// Firebase Console → Project settings → Your apps → (Web app) → SDK setup and configuration
/// แล้ว copy ค่าจาก firebaseConfig:
/// apiKey, appId, messagingSenderId, projectId, authDomain, storageBucket, measurementId
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBDSN7yXrUh5pf5KzD8mI5f1WeaDAONAMA",
  authDomain: "recipe-finder-7de09.firebaseapp.com",
  projectId: "recipe-finder-7de09",
  storageBucket: "recipe-finder-7de09.firebasestorage.app",
  messagingSenderId: "581782119165",
  appId: "1:581782119165:web:e7137ecb472e47ed219494",
  measurementId: "G-WSCB4GM193"
  );
}

