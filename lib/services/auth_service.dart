import 'package:busmitra/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


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

  Future<void> signInWithGoogle() async {
    try {
      // First try native Google Sign-In (no browser redirect)
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign-in aborted');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final oauth = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await _auth.signInWithCredential(oauth);
      _user = userCredential.user;
    } catch (e) {
      // Fallback to Firebase provider (browser) if native flow fails
      try {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        final userCredential = await _auth.signInWithProvider(provider);
        _user = userCredential.user;
      } catch (e2) {
        throw Exception('Google Sign-In failed: $e2');
      }
    }

    if (_user == null) throw Exception('Authentication failed');

    // Upsert user in Firestore
    final userDoc = _firestore.collection('users').doc(_user!.uid);
    final doc = await userDoc.get();
    final now = DateTime.now();
    if (doc.exists) {
      await userDoc.update({
        'lastLoginAt': now.toIso8601String(),
        'isEmailVerified': _user!.emailVerified,
        'name': _user!.displayName ?? '',
        'email': _user!.email ?? '',
        'profileImageUrl': _user!.photoURL,
      });
    } else {
      final userModel = UserModel(
        uid: _user!.uid,
        email: _user!.email ?? '',
        name: _user!.displayName ?? '',
        profileImageUrl: _user!.photoURL,
        createdAt: now,
        lastLoginAt: now,
        isEmailVerified: _user!.emailVerified,
      );
      await userDoc.set(userModel.toMap());
    }

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