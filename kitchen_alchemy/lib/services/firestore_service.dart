import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Ingredient>> getInventory() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final ingredients = await _firestore.collection('users').doc(user.uid).collection('inventory').get();
    return  ingredients.docs.map((doc) => Ingredient.fromJson(doc.data())).toList();
  }

  Future<List<Ingredient>> getShoppingList() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final shopping = await _firestore.collection('users').doc(user.uid).collection('shopping_list').get();
    return shopping.docs.map((doc) => Ingredient.fromJson(doc.data())).toList();
  }

  Future<void> addInventory(Ingredient ingredient) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('inventory')
        .doc(ingredient.id).set(ingredient.toJson());
  }

  Future<void> addShoppingList(Ingredient ingredient) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('shsopping_list')
        .doc(ingredient.id).set(ingredient.toJson());
  }

  Future<void> updateInventory(String userId, List<dynamic> inventory) async {
    await _firestore.collection('users').doc(userId).update({
      'inventory': inventory,
    });
  }

  Future<void> updateShoppingList(String userId, List<dynamic> shoppingList) async {
    await _firestore.collection('users').doc(userId).update({
      'shoppingList': shoppingList,
    });
  }

  Future<DocumentSnapshot> getUserDoc(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

}