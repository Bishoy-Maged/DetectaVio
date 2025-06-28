import 'package:detectavio/pages_screen.dart';
import 'package:detectavio/signup_screen.dart';
import 'package:detectavio/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password_screen.dart'; // ← added

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final auth = FirebaseAuth.instance;
  late String email;
  late String password;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  var formKey = GlobalKey<FormState>();

  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Get the access token
        final AccessToken? accessToken = loginResult.accessToken;
        if (accessToken != null) {
          // Use `tokenString` instead of `token`
          final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.tokenString);
          // Sign in to Firebase with the Facebook credential
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
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _setLoggedInAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PagesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Replace the flat color with a gradient background:
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
                // Back arrow and animated page title row:
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
                    const SizedBox(width: 65),
                    Text(
                      "Login",
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
                // Email Field:
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
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    prefixIcon: Icon(Icons.mail, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Password Field:
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
                const SizedBox(height: 5),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight, // ✅ correct type
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          alignment: Alignment.center,
                          duration: const Duration(milliseconds: 400),
                          child: const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sign In Button:
                SizedBox(
                  width: 120,
                  height: 40,
                  child: MaterialButton(
                    onPressed: () async {
                      try {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        );
                        var user = await auth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        if (user != null) {
                          Navigator.of(context).pop(); // close loader
                          await _setLoggedInAndNavigate();
                        }
                      } catch (e) {
                        Navigator.of(context).pop(); // close loader
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Social Sign In Buttons:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Facebook sign in button:
                    MaterialButton(
                      shape: const CircleBorder(),
                      onPressed: () async {
                        try {
                          var user = await signInWithFacebook();
                          if (user != null) {
                            await _setLoggedInAndNavigate();
                          }
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
                    // Google sign in button:
                    MaterialButton(
                      shape: const CircleBorder(),
                      onPressed: () async {
                        try {
                          var user = await signInWithGoogle();
                          if (user != null) {
                            await _setLoggedInAndNavigate();
                          }
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
                // Sign Up Link:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Color(0xFFEEF4ED),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTop,
                            alignment: Alignment.center,
                            duration: const Duration(milliseconds: 400),
                            child: const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
                // Lottie animation at the bottom:
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'images/icons/Animated/LottieFiles/verification2.json',
                    width: 40,
                    height: 40,
                    repeat: false,
                    animate: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
