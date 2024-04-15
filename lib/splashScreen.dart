
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:try_qr/HomeScreen.dart';
class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Card(
              elevation: 2,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: Image.asset("assets/images/QR_For_Project.jpg"))),
          SizedBox(
            height: 50,
          ),
          Text("QR", style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),)
        ],
      ),
      nextScreen:const HomeScreen(),
      centered: true,
      splashIconSize: 500,
      backgroundColor: Colors.blueGrey.shade100,
      splashTransition:SplashTransition.scaleTransition,
      duration: 100,
      animationDuration: Duration(seconds: 2),
      //animationDuration: Duration(milliseconds: 500),
      curve:Curves.bounceInOut,
    );
  }
}
