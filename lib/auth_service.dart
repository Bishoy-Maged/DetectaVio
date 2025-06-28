// auth_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String _apiBaseUrl = 'http://localhost:8080/Graduation%20project/api.php'; // Replace with your PHP server URL

  // Register user in both Firebase and PHP backend
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? dob,
    String? gender,
    String? dobDay,
    String? dobMonth,
    String? dobYear,
  }) async {
    try {
      // 1. Register with Firebase
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get Firebase UID
      String firebaseUid = userCredential.user!.uid;

      // 2. Register with PHP backend
      Map<String, dynamic> userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password, // Note: In production, handle this more securely
        'firebaseUid': firebaseUid,
      };

      // Add optional fields if provided
      if (phone != null) userData['phone'] = phone;
      if (address != null) userData['address'] = address;
      if (dob != null) userData['dob'] = dob;
      if (gender != null) userData['gender'] = gender;
      if (dobDay != null) userData['dob_day'] = dobDay;
      if (dobMonth != null) userData['dob_month'] = dobMonth;
      if (dobYear != null) userData['dob_year'] = dobYear;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api.php?action=register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      final result = json.decode(response.body);

      if (result['success']) {
        // Set user display name in Firebase
        await userCredential.user!.updateDisplayName('$firstName $lastName');
        return {'success': true, 'user': result};
      } else {
        // If PHP registration fails, delete the Firebase user
        await userCredential.user!.delete();
        return {'success': false, 'message': result['message']};
      }
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Login user in both Firebase and PHP backend
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login with Firebase
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String firebaseUid = userCredential.user!.uid;

      // 2. Login with PHP backend
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api.php?action=login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password, // In production, consider using tokens instead
          'firebaseUid': firebaseUid,
        }),
      );

      final result = json.decode(response.body);

      if (result['success']) {
        return {'success': true, 'user': result};
      } else {
        // If PHP login fails, sign out from Firebase
        await _firebaseAuth.signOut();
        return {'success': false, 'message': result['message']};
      }
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Logout from both Firebase and PHP (if needed)
  Future<void> logout() async {
    // Firebase logout
    await _firebaseAuth.signOut();

    // You could also make a request to your PHP backend to invalidate sessions if needed
    // await http.post(Uri.parse('$_apiBaseUrl/logout.php'));
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
    }
}