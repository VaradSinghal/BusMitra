import 'package:busmitra/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;
  Stream<User?> get userStream => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      
      // Create user document in Firestore with enhanced user model
      final userModel = UserModel(
        uid: _user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        isEmailVerified: _user!.emailVerified,
      );
      
      await _firestore.collection('users').doc(_user!.uid).set(userModel.toMap());
      
      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<UserModel?> getCurrentUserData() async {
    if (_user == null) return null;
    
    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateLastLogin() async {
    if (_user == null) return;
    
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }
}