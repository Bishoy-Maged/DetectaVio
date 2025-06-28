import 'package:detectavio/signin_screen.dart';
import 'package:detectavio/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B2545), Color(0xFF134074)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logoHero',
                  child: SizedBox(
                    height: screenWidth * 0.5,
                    width: screenWidth * 0.5,
                    child: Lottie.asset(
                      'images/icons/Animated/LottieFiles/security_cam2.json',
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Detectavio',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFEEF4ED),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(),)
                    .shimmer(duration: 2000.ms,color: const Color(0xFF0B2545),),
                const SizedBox(height: 10),
                Text(
                  'Welcome',
                  style: TextStyle(
                    color: const Color(0xFFEEF4ED),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                _AuthButton(
                  label: 'Sign Up',
                  icon: Icons.person_add_alt,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.leftToRight,
                        duration: const Duration(milliseconds: 500),
                        child: const SignupScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _AuthButton(
                  label: 'Login',
                  icon: Icons.assignment_ind_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.leftToRightWithFade,
                        duration: const Duration(milliseconds: 500),
                        child: const SigninScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 45,
      child: MaterialButton(
        onPressed: onTap,
        color: const Color(0xFF134074),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFEEF4ED), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFFEEF4ED),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
