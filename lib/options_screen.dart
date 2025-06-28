import 'package:detectavio/edit_email_pass_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'main_screen.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B2545), Color(0xFF134074)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _OptionButton(
                    label: 'Edit Profile',
                    lottiePath: 'images/icons/Animated/LottieFiles/avatar-hover-looking-around.json',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          alignment: Alignment.center,
                          duration: const Duration(milliseconds: 400),
                          child: const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _OptionButton(
                    label: 'Settings',
                    lottiePath: 'images/icons/Animated/LottieFiles/settings.json',
                    onTap: () {
                      // Add settings action
                    },
                  ),
                  const SizedBox(height: 15),
                  _OptionButton(
                    label: 'Email/Pass.',
                    lottiePath: 'images/icons/Animated/LottieFiles/edit-hover-line.json',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          alignment: Alignment.center,
                          duration: const Duration(milliseconds: 400),
                          child: const EditEmailPassScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _OptionButton(
                    label: ' History',
                    lottiePath: 'images/icons/Animated/LottieFiles/clock-time-loop-oscillate.json',
                    onTap: () {
                      // Add history action
                    },
                  ),
                  const SizedBox(height: 15),
                  _OptionButton(
                    label: ' Log out',
                    lottiePath: 'images/icons/Animated/LottieFiles/log-out.json',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Are you sure?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close the dialog first

                                // 1. Sign out from Firebase
                                await FirebaseAuth.instance.signOut();

                                // 2. Optionally clear login flag (if used in SplashScreen)
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('isLoggedIn', false);

                                // 3. Navigate to MainScreen and clear navigation stack
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const MainScreen()),
                                (route) => false,
                                );
                                },
                              child: const Text('Yes', style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('No'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final String lottiePath;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.lottiePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 50,
      child: MaterialButton(
        onPressed: onTap,
        color: const Color(0xFF134074),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: Lottie.asset(
                lottiePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEEF4ED),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
