import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/Coffee/Provider/CoffeeProvider.dart';
import 'features/Landing Page/CoffeeLandingPage.dart';

void main() {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CoffeeProvider()),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CoffeeLandingPage(),
    );
  }
}