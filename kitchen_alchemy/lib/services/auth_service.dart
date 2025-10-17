import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<User?> signInAnonymously() async {
    if (_auth.currentUser != null) return _auth.currentUser!;

    final userCredential = await _auth.signInAnonymously();
    final user = userCredential.user!;

    final userDoc = await _firestore.collection('users').doc(user.uid);


    await userDoc.set({
      'createdAt': FieldValue.serverTimestamp(),
    });

    await userDoc.collection('inventory').doc('ingredient').set({
      'id': 1,
      'name': 'chicken',
      'quantity': 250,
      'unit': 'g',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await userDoc.collection('shopping_list').doc('ingredient').set({
      'id': 1,
      'name': 'chicken',
    });


    return user;
  }

  User? get currentUser => _auth.currentUser;
}