import 'package:detectavio/pages_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: Colors.grey,
        child:  SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(CupertinoIcons.person,
                  color: Colors.white,),
                ),
                title: Text(
                    "Username",
                style: TextStyle(
                  color: Colors.white,
                ),
                ),
                  subtitle: Text(
                      "Profession",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Divider(
                      color: Colors.white24,
                      height: 1,
                    ),
                  ),
                  ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const PagesScreen(),));
                      },
                    leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: Lottie.asset(
                        'images/icons/Animated/LottieFiles/home_icon.json',
                        width: 20,
                        height: 20,
                        repeat: true, // or false
                        animate: true, // or control it manually,
                    ),
                    ),
                    title: const Text(
                        "Home",
                    style: TextStyle(
                      color: Colors.white
                    ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
