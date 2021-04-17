import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:social_app/widgets/loginWidgets/loginFormArea.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController usernameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwdTextController = TextEditingController();

  String userName, email, passwd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors:[Color(0xFF9933ff),Color(0xFF6600cc),], //[Color(0xFFFFC300),Color(0xFFFF9A3F)]
            )
        ),
        child: ListView(
          children: [
            loading ? LinearProgressIndicator(): SizedBox(height: 0,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 100),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                            child: Icon(Icons.arrow_back_ios,color: Colors.white,),
                        ),
                        SizedBox(width: 30,),
                        Text("Kayıt Ol",style: TextStyle(fontSize: 20,color: Colors.white),)
                      ],
                    ),

                    SizedBox(height: 40,),
                    LoginFormArea(
                      username: true,
                      emailBool: true,
                      icon: Icons.account_circle,
                      labelText: "Username",
                      controller: usernameTextController,
                      onSaved: (val) => userName = val,
                    ),
                    SizedBox(height: 15,),
                    LoginFormArea(
                      emailBool: true,
                      icon: Icons.email,
                      labelText: "Email",
                      controller: emailTextController,
                      onSaved: (val) => email = val,
                    ),
                    SizedBox(height: 15,),
                    LoginFormArea(
                      icon: Icons.vpn_key,
                      labelText: "Password",
                      controller: passwdTextController,
                      onSaved: (val) => passwd = val,
                    ),
                    SizedBox(height: 30,),
                    buttonArea(),
                  ],
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }

  buttonArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
              minWidth: double.infinity,
              onPressed: (){
                signUp();
              },
              height: 70,
              splashColor: Colors.green,
              icon: Icon(Icons.verified,color: Colors.deepPurple,),
              color: Colors.white,
              textColor: Colors.deepPurple,
              label: Text("Kayıt Ol!")
          ),
        ],
      ),
    );
  }

  signUp() async {
    final _authService = Provider.of<AuthService>(context, listen: false);

    var _formState = _formKey.currentState;
    if(_formState.validate()){
      _formState.save();
      setState(() {
        loading = true;
      });
      try{
        Users user = await _authService.signUpWithEmail(email, passwd);
        if(user != null){
          FireStoreServices().buildUser(id: user.id, email: user.email, userName: userName);
        }
        Navigator.pop(context);
      }catch(e){
        showWarning(errCode : e.code);
        setState(() {
          loading = false;
        });
      }
    }
  }
  showWarning({errCode}){
    String errMessage;
    if(errCode == "invalid-email")
      errMessage = "Girdiğiniz mail adresi geçersizdir.";
    else if(errCode == "email-already-in-use")
      errMessage = "Girdiğiniz mail kullanılmaktadır.";
    else if(errCode == "weak-password")
      errMessage = "Daha güçlü bir şifre girin.";
    else
      errMessage = "Bir hata oluştu.";

    var snackbar = SnackBar(content: Text(errMessage),);
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
