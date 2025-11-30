import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProviderS extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  String? get error => _errorMessage;
  bool get isLoading => _isLoading;

  User? get user => _user;

  AuthProviderS() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String location,
    required String gender,
  }) async {
    try {
      _setLoading(true);

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final tokenid = await _user?.getIdToken();
      if (tokenid != null) {
        await prefs.setString(
            'token', tokenid); // ✅ This saves the actual token
      }

      if (_user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set({
          'uid': _user!.uid,
          'email': email,
          'name': name,
          'location': location,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _errorMessage = null;
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      print("Signup error: $_errorMessage");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _setLoading(true); // Start loading
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final tokenid = await _user?.getIdToken();
      if (tokenid != null) {
        await prefs.setString(
            'token', tokenid); // ✅ This saves the actual token
      }
      _errorMessage = null; // clear old errors
    } catch (e) {
      _errorMessage = e.toString(); // store error
    } finally {
      _setLoading(false); // Done loading
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut(); // Sign out from Firebase

    // Remove token or session info from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // or 'user', 'uid' – whatever you saved

    _user = null;
    notifyListeners(); // Notify UI (e.g., go to login screen)
  }
}
