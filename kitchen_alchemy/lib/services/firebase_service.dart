import 'package:firebase_core/firebase_core.dart';
import 'package:kitchen_alchemy/firebase_options.dart';

class FirebaseService {
  static Future<void> init() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}