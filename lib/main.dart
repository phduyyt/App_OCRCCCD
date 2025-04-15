import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/userr/change_password.dart';
import 'screens/userr/user_details.dart';
import 'screens/userr/user_main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        routes: {
          '/user': (_) => UserMainScreen(),
          '/user-details': (_) => UserDetailsScreen(),
          '/change-password': (_) => ChangePasswordScreen(),
          '/login': (_) => LoginScreen(),
        },
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}