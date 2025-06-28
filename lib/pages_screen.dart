import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectavio/guidelines_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:detectavio/pinned_screen.dart';
import 'package:detectavio/home_screen.dart';
import 'package:detectavio/options_screen.dart';
import 'package:detectavio/side_menu.dart';
import 'package:detectavio/videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';


class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key});

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int currentIndex = 0;
  List<Widget> screens = [
    NewsScreen(),
    GuidelinesScreen(),
    const VideosScreen(),
    const PinnedScreen(),
    const OptionsScreen(),
  ];

  String _username = "Username";
  String? _profileImageBase64;
  bool _isLoadingProfileImage = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchProfileImage();
  }

  Future<void> _fetchUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && mounted) {
          setState(() {
            _username = '${userDoc['firstName']} ${userDoc['lastName']}';
          });
        }
      } catch (error) {
        print("Error fetching username: $error");
      }
    }
  }

  Future<void> _fetchProfileImage() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          final imageBase64 = data['profileImageUrl'];

          print("Fetched profile image URL: $imageBase64");

          if (mounted) {
            setState(() {
              if (imageBase64 != null &&
                  imageBase64 is String &&
                  imageBase64.isNotEmpty) {
                _profileImageBase64 = imageBase64;
              }
              _isLoadingProfileImage = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingProfileImage = false);
        }
      } catch (error) {
        print("Error fetching profile image: $error");
        if (mounted) setState(() => _isLoadingProfileImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1000,
        backgroundColor: const Color(0xFF13315C),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SideMenu()));
            },
            icon: _isLoadingProfileImage
                ? const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : ClipOval(
              child: SizedBox(
                width: 50,
                height: 50,
                child: _profileImageBase64 != null
                    ? Image.memory(
                  base64Decode(_profileImageBase64!),
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'images/icons/profile icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                tooltip: 'Rate Us',
                onPressed: () {
                  double _rating = 3;

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF0B2545),
                        title: const Text(
                          'Rate Our App',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RatingBar.builder(
                                    initialRating: _rating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemSize: 35,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        _rating = rating;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();

                                      try {
                                        String uid = FirebaseAuth.instance.currentUser!.uid;
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .update({'rating': _rating});

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('You rated us $_rating stars!')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error saving rating: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.star_rate_outlined,
                  color: Color(0xFFEEF4ED),
                ),
              ),
              SizedBox(width: 10,),
              PopupMenuButton<String>(
                tooltip: 'Contact Us',
                onSelected: (value) {
                  if (value == 'facebook') {
                    // Add Facebook contact logic
                  } else if (value == 'whatsapp') {
                    // Add WhatsApp contact logic
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      "Contact Us",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'facebook',
                    child: Row(
                      children: [
                        Icon(Icons.facebook, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Facebook'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'whatsapp',
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                        SizedBox(width: 8),
                        Text('WhatsApp'),
                      ],
                    ),
                  ),
                ],
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: Lottie.asset(
                    'images/icons/Animated/LottieFiles/consultation-hover-conversation.json', // your Lottie animation path
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
              SizedBox(width: 7,),

            ],
          ),
        ],
        title: Text(
          _username,
          style: const TextStyle(
            color: Color(0xFFEEF4ED),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2000.ms, color: const Color(0xFF0B2545)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        showUnselectedLabels: false,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined),
            label: "Guidelines",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video),
            label: "Videos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.push_pin_outlined),
            label: "Pinned",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Options",
          ),
        ],
      ),
      body: screens[currentIndex],
    );
  }
}
