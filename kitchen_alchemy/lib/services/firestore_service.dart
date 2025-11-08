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

    await _firestore.collection('users').doc(user.uid).collection('shopping_list')
        .doc(ingredient.id).set(ingredient.toJson());
  }



  Future<void> addSelectedItems(List<Ingredient> ingredients, bool inventory) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    for (final ingredient in ingredients) {
      final docRef = _firestore.collection('users').doc(user.uid)
          .collection(inventory ? 'inventory' : 'shopping_list').doc(ingredient.id);

      batch.set(docRef, ingredient.toJson());
    }
    await batch.commit();
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

  Future<void> deleteInventoryItem(Ingredient ingredient) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(ingredient.id);

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        print('Ingredient not found in inventory: ${ingredient.name}');
        return;
      }

      await docRef.delete();
      print('Ingredient deleted: ${ingredient.name}');
    } catch (e) {
      print('Error deleting ingredient: $e');
    }
  }

  Future<void> deleteShoppingListItem(Ingredient ingredient) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shopping_list')
        .doc(ingredient.id);

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        print('Ingredient not found in shopping_list: ${ingredient.name}');
        return;
      }

      await docRef.delete();
      print('Ingredient deleted: ${ingredient.name}');
    } catch (e) {
      print('Error deleting ingredient: $e');
    }
  }


  Future<bool> hasInventory(String ingredientId, {bool inventory = true}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection(inventory ? 'inventory' : 'shopping_list')
        .doc(ingredientId)
        .get();

    return doc.exists;
  }

  Future<void> addRecipeToShoppingList(List<Ingredient> recipeIngredients) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final shoppingListRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shopping_list');

    for (final ingredient in recipeIngredients) {
      final docRef = shoppingListRef.doc(ingredient.id);

      final alreadyInInventory = await hasInventory(ingredient.id, inventory: true);
      final alreadyInShoppingList = await hasInventory(ingredient.id, inventory: false);

      if (alreadyInInventory || alreadyInShoppingList) continue;

      batch.set(docRef, ingredient.toJson());
    }

    await batch.commit();
  }


}