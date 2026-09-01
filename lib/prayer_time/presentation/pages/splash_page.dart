import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Splash Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}


bool isHivesave2(){
  if (Hive.isBoxOpen('prayer_time')) {
    return true;
  } else {
    return false;
  }
}

