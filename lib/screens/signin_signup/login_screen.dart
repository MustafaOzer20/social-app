import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/signin_signup/reset_password.dart';
import 'signup_screen.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:social_app/widgets/loginWidgets/loginFormArea.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;
  String email, passwd;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
        child: Stack(
          children: [
            LogInArea(size),
            _loadingAnimation(),
          ],
        ),
      ),
    );
  }
  Widget LogInArea(size){
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 35,vertical: 50),
        children: [
          FlutterLogo(size: 90,),
          SizedBox(height: 70,),
          LoginFormArea(
            emailBool: true,
            controller: emailController,
            labelText: "Email",
            icon: Icons.email,
            onSaved: (val) => email = val,
          ),
          SizedBox(height: 15,),
          LoginFormArea(
            controller: passController,
            labelText: "Password",
            icon: Icons.vpn_key,
            onSaved: (val) => passwd = val,
          ),
          SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassword()));
                  },
                  child: Text("Parolanızı mı unuttunuz?",style: TextStyle(color: Colors.white),)
              )
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                  },
                  child: Text("Kayıt Ol"),
                  color: Colors.white,
                  textColor: Colors.deepPurple,
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: FlatButton(
                  onPressed: (){
                    logIn();
                  },
                  child: Text("Giriş Yap"),
                  color: Colors.white,
                  textColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 25,),
          Center(child: Text('veya',style: TextStyle(color: Colors.white),)),
          SizedBox(height: 25,),
          RaisedButton(
            onPressed: (){
              logInWithGoogle();
            },
            color: Colors.white,
            splashColor: Colors.grey[200],
            textColor: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage("assets/images/google.png"), height: 70,width: 70,),
                Text("Google ile giriş yap"),
              ],
            ),

          ),
        ],
      ),
    );
  }
  void logInWithGoogle() async{
    final _authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      loading = true;
    });
    try{
      Users user = await _authService.signInWithGoogle();
      if(user != null){
        Users firestoreUser =  await FireStoreServices().getUser(user.id);
        if(firestoreUser == null){
          FireStoreServices().buildUser(
              id: user.id,
              userName: user.userName,
              email: user.email,
              imageUrl: user.imageUrl
          );
        }
      }
    }catch(e){
      setState(() {
        loading = false;
      });
      showWarning(errCode: e.code);
    }
  }
  void logIn() async{
    final _authService = Provider.of<AuthService>(context, listen: false);

    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        loading = true;
      });
      try{
        await _authService.signInWithEmail(email, passwd);
      }catch(e){
        setState(() {
          loading = false;
        });
        showWarning(errCode : e.code);
      }
    }
  }
  showWarning({errCode}){
    String errMessage;
    if(errCode == "invalid-email")
      errMessage = "Girdiğiniz mail adresi geçersizdir.";
    else if(errCode == "user-not-found")
      errMessage = "Böyle bir kullanıcı bulunmuyor.";
    else if(errCode == "wrong-password")
      errMessage = "Şifre Yanlış";
    else if(errCode == "user-disabled")
      errMessage = "Kullanıcı engellenmiş.";
    else
      errMessage = "Tanımlanamayan bir hata oluştu $errCode";

    var snackbar = SnackBar(content: Text(errMessage),);
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _loadingAnimation(){
    if(loading){
      return Center(child: CircularProgressIndicator(),);
    }
    return Center();
  }

}
