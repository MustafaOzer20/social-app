import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/orientation.dart';
import 'package:social_app/services/auth_service.dart';
//import 'package:social_app/widgets/new_navscreen.dart';



void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social App',
        theme: ThemeData(
          accentColor: Colors.blueAccent,
        ),
        home: OrientationState(),
      ),
    );
  }
}
