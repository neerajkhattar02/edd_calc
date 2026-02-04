import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edd_calc/local_data_storage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Trigger the animation after a small delay
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    (Timer(Duration(seconds: 3), () async {
      bool isRegistered = await LocalStorage.isUserRegistered();
      if (isRegistered) {
        Navigator.pushReplacementNamed(context, '/edd');
      } else {
        Navigator.pushReplacementNamed(context, '/details');
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 231, 238),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 2),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/ga_calc_splash.png',
                  width: 230,
                  height: 230,
                ),
              ),

              SizedBox(height: 250),

              Image.asset(
                'assets/jhpiego_splash_logo.png',
                width: 75,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
