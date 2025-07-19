
import 'package:app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    
    url: 'https://dqirjuaqwxrvotjeyyrf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxaXJqdWFxd3hydm90amV5eXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyODc2NDcsImV4cCI6MjA2Njg2MzY0N30.e2wHSv4c9ps3whiGWvxXxkwkMgTGvmdXhxc8XLErwQ4',
  );
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social App',
      home: SplashScreen(),
    );
  }
}