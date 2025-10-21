import 'package:firebase_core/firebase_core.dart';
import 'package:kitchen_alchemy/firebase_options.dart';
import 'package:kitchen_alchemy/services/auth_service.dart';

class FirebaseService {
  static Future<void> init() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final authService = AuthService();
    final user = await authService.signInAnonymously();
    print('Signed in as: ${user?.uid}');

  }
}