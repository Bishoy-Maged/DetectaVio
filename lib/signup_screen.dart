import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectavio/pages_screen.dart';
import 'package:detectavio/main_screen.dart';
import 'package:detectavio/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  late String email;
  late String password;
  String? selectedGender;
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phonenumberController = TextEditingController();
  final countryController = TextEditingController();
  final birthdateController = TextEditingController();
  bool _obscureText = true;
  var formKey = GlobalKey<FormState>();

  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final AccessToken? accessToken = loginResult.accessToken;
        if (accessToken != null) {
          final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.tokenString);
          return await FirebaseAuth.instance
              .signInWithCredential(facebookAuthCredential);
        } else {
          throw Exception("AccessToken is null");
        }
      } else {
        throw Exception("Facebook login failed: ${loginResult.message}");
      }
    } catch (e) {
      print("Error during Facebook sign-in: $e");
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signUpWithFirebaseAndPHP() async {
    try {
      // --- Firebase Authentication ---
      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;

      // --- Store details in Firestore ---
      await firestore.collection('users').doc(uid).set({
        'firstName': firstnameController.text.trim(),
        'lastName': lastnameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'phone': phonenumberController.text.trim(),
        'country': countryController.text.trim(),
        'gender': selectedGender,
        'birthdate': birthdateController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'profileImageUrl': null,
        'rating': null,
      });

      // --- Call PHP API to add user to MySQL database ---
      final url = Uri.parse(
          "https://eed2-2c0f-fc89-8090-bc7c-8440-5205-f15d-b3d4.ngrok-free.app/Graduation%20project/Backend/Login/register.php");
      final phpResponse = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "signUp": true,
          "fName": firstnameController.text.trim(),
          "lName": lastnameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "phone": phonenumberController.text.trim(),
          "address": countryController.text.trim(),
          "dob_day": birthdateController.text.split('-')[2],
          "dob_month": birthdateController.text.split('-')[1],
          "dob_year": birthdateController.text.split('-')[0],
          "gender": selectedGender,
          "firebase_uid": uid,
        }),
      );
      print("PHP Response: ${phpResponse.body}");

      // --- SAVE LOGIN STATE HERE ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // --- Close loading dialog & Navigate to home (PagesScreen) ---
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PagesScreen()),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: 750,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B2545), Color(0xFF134074)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation, secondaryAnimation) =>
                                    const MainScreen(),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration:
                                    const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFFEEF4ED),
                              ),
                            ),
                            const SizedBox(width: 55),
                            // Animated Page Title using fadeIn and slideDown
                            Text(
                              "Sign Up",
                              style: const TextStyle(
                                color: Color(0xFFEEF4ED),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 1000.ms)
                                .slideY(begin: -0.5, duration: 1000.ms),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: firstnameController,
                                keyboardType: TextInputType.name,
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "First Name can't be empty";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "First Name",
                                  labelStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(30.0))),
                                  prefixIcon: Icon(Icons.person, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: lastnameController,
                                keyboardType: TextInputType.name,
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Last Name can't be empty";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "Last Name",
                                  labelStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(30.0))),
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email Address can't be empty";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            email = value;
                          },
                          decoration: const InputDecoration(
                            labelText: "Email Address",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                            prefixIcon: Icon(Icons.mail, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password can't be empty";
                            } else if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            password = value;
                          },
                          obscureText: _obscureText,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            ),
                            prefixIcon: const Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.remove_red_eye_rounded
                                    : Icons.visibility_off_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: phonenumberController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone Number can't be empty";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                            prefixIcon: Icon(Icons.phone, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: countryController,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Country/Address can't be empty";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Country/Address",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                            prefixIcon:
                            Icon(Icons.location_on, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: const InputDecoration(
                            labelText: "Gender",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                            prefixIcon:
                            Icon(Icons.people, color: Colors.white),
                          ),
                          dropdownColor: Colors.blueGrey,
                          style: const TextStyle(color: Colors.white),
                          items: ["Male", "Female", "Other"].map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Gender can't be empty";
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: birthdateController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Birth Date can't be empty";
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      surface: Colors.blueGrey,
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                birthdateController.text =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: "Birth Date",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                            prefixIcon:
                            Icon(Icons.date_range, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 120,
                          height: 40,
                          child: MaterialButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) =>
                                  const Center(child: CircularProgressIndicator()),
                                );
                                await signUpWithFirebaseAndPHP();
                              }
                            },
                            color: const Color(0xFF134074),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: Color(0xFFEEF4ED)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              shape: const CircleBorder(),
                              onPressed: () async {
                                try {
                                  await signInWithFacebook();
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Error"),
                                        content: Text(e.toString()),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              color: const Color(0xFF134074),
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: Lottie.asset(
                                  'images/icons/Animated/LottieFiles/facebook-morph-circle.json',
                                  fit: BoxFit.contain,
                                  repeat: false,
                                ),
                              ),
                            ),
                            MaterialButton(
                              shape: const CircleBorder(),
                              onPressed: () async {
                                try {
                                  await signInWithGoogle();
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Error"),
                                        content: Text(e.toString()),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              color: const Color(0xFF134074),
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: Lottie.asset(
                                  'images/icons/Animated/LottieFiles/google-morph-circle.json',
                                  fit: BoxFit.contain,
                                  repeat: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.topToBottom,
                                    alignment: Alignment.center,
                                    duration: const Duration(milliseconds: 400),
                                    child: const SigninScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                        const Image(
                          image: AssetImage('images/the_search1.png'),
                          width: 150,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),
        );
    }
}
