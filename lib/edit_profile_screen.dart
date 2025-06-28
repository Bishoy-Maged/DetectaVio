import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:detectavio/pages_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController countryController;
  late TextEditingController birthdateController;
  late TextEditingController currentPasswordController;
  String? selectedGender;

  File? _imageFile;
  String? _imageBase64;
  Uint8List? _cachedImageBytes; // ✅ Cached decoded image
  bool _isConverting = false;
  bool _isSaving = false;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    countryController = TextEditingController();
    birthdateController = TextEditingController();
    currentPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    birthdateController.dispose();
    currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _cachedImageBytes = null; // force refresh
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _convertImageToBase64() async {
    if (_imageFile == null) return;

    setState(() {
      _isConverting = true;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      _imageBase64 = base64Encode(bytes);
    } catch (e) {
      print('Error converting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to convert image: $e')));
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  Future<void> _uploadImageToPHPBackend() async {
    if (_imageBase64 == null) return;

    try {
      final uri = Uri.parse(
          'https://54cc-41-68-182-209.ngrok-free.app/upload_profile_image.php');
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'firebase_uid': currentUser.uid,
          'image': _imageBase64,
        }),
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully: ${response.body}');
      } else {
        print('Failed image upload: ${response.body}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _saveUserData() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in!')));
        return;
      }

      String currentPassword = currentPasswordController.text.trim();

      if (currentPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your current password')));
        return;
      }

      try {
        final cred = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(cred);
      } on FirebaseAuthException catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect current password')));
        return;
      }

      if (_imageFile != null) {
        await _convertImageToBase64();
      }

      await firestore.collection('users').doc(user.uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'country': countryController.text.trim(),
        'birthdate': birthdateController.text.trim(),
        'gender': selectedGender,
        if (_imageBase64 != null) 'profileImageUrl': _imageBase64,
      });

      await _uploadImageToPHPBackend();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PagesScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B2545), Color(0xFF134074)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 1000,
          backgroundColor: const Color(0xFF13315C),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFEEF4ED),
            ),
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              color: Color(0xFFEEF4ED),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: firestore.collection('users').doc(currentUser.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!;
            if (_isFirstLoad) {
              firstNameController.text = userData.get('firstName') ?? '';
              lastNameController.text = userData.get('lastName') ?? '';
              phoneController.text = userData.get('phone') ?? '';
              countryController.text = userData.get('country') ?? '';
              birthdateController.text = userData.get('birthdate') ?? '';
              selectedGender = userData.get('gender') ?? '';
              _imageBase64 = userData.get('profileImageUrl');
              if (_imageBase64 != null) {
                _cachedImageBytes = base64Decode(_imageBase64!); // ✅ decode once
              }
              _isFirstLoad = false;
            }

            ImageProvider displayImage;
            if (_imageFile != null) {
              displayImage = FileImage(_imageFile!);
            } else if (_cachedImageBytes != null) {
              displayImage = MemoryImage(_cachedImageBytes!);
            } else {
              displayImage = const AssetImage('assets/default_profile.png');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: displayImage,
                        backgroundColor: Colors.grey[300],
                      ),
                      if (_isConverting)
                        const Positioned(child: CircularProgressIndicator()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: firstNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: lastNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: countryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: birthdateController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Birthdate',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    dropdownColor: const Color(0xFF0B2545),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Please Enter the Current Password to confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveUserData,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
