import 'package:flutter/material.dart';

import '../Home Page/ui/homepage.dart';

class CoffeeLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.20),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Coffee so good,\nyour taste buds\nwill love it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora'
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'The best grain, the finest roast,\nthe powerful flavor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (_)=>CoffeeHomePage()));},
                  icon: Icon(Icons.login,size: 25,),
                  label: Text('Continue with Google',style: TextStyle(fontSize: 18),),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: TextStyle(fontSize: 16),

                  ),
                ),
                SizedBox(height: 25),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
