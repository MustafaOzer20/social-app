import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/user.dart';
import 'screens/signin_signup/login_screen.dart';
import 'package:social_app/screens/nav_screen.dart';
import 'package:social_app/services/auth_service.dart';

class OrientationState extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder(
      stream: _authService.stateManagment,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator()
              )
          );
        }

        if(snapshot.hasData){
          Users activeUser = snapshot.data;
          _authService.activeUserId = activeUser.id;
          return NavScreen();
        }

        return LogInScreen();
      },
    );
  }
}
