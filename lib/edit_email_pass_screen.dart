import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EditEmailPassScreen extends StatefulWidget {
  const EditEmailPassScreen({super.key});

  @override
  State<EditEmailPassScreen> createState() => _EditEmailPassScreenState();
}

class _EditEmailPassScreenState extends State<EditEmailPassScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    emailController.text = currentUser.email ?? '';
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmailAndPassword() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final newEmail = emailController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final currentPassword = currentPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your current password')),
      );
      setState(() => _isSaving = false);
      return;
    }

    try {
      // Reauthenticate user
      final cred = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      await currentUser.reauthenticateWithCredential(cred);

      // Update email if changed
      if (newEmail != currentUser.email) {
        await currentUser.updateEmail(newEmail);
        await firestore.collection('users').doc(currentUser.uid).update({
          'email': newEmail,
        });
      }

      // Update password if provided
      if (newPassword.isNotEmpty) {
        await currentUser.updatePassword(newPassword);
        await firestore.collection('users').doc(currentUser.uid).update({
          'password': newPassword,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account updated successfully!')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2545),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13315C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFEEF4ED)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Email & Password',
          style: TextStyle(
            color: Color(0xFFEEF4ED),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        height: 750,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B2545), Color(0xFF134074)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please Enter the Current Password to confirm',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateEmailAndPassword,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                width: 200,
                child: Lottie.asset(
                  'images/icons/Animated/LottieFiles/lock_animation.json',
                  repeat: false,
                  animate: true,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
