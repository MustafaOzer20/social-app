import 'package:flutter/material.dart';

class LoginFormArea extends StatefulWidget {
  final String labelText;
  final IconData icon;
  final TextEditingController controller;
  final bool emailBool;
  final bool username;
  final Function onSaved;

  const LoginFormArea({
      this.labelText,
      this.icon,
      this.controller,
      this.emailBool = false,
      this.username = false,
      this.onSaved
  });

  @override
  _LoginFormAreaState createState() => _LoginFormAreaState(emailBool);
}

class _LoginFormAreaState extends State<LoginFormArea> {
  var myBool;

   _LoginFormAreaState(bool passVisible){
    this.myBool = !passVisible;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextFormField(
        autocorrect: true,
        keyboardType: widget.emailBool && !widget.username ? TextInputType.emailAddress: TextInputType.name,
        controller: widget.controller,
        style: TextStyle(fontSize: 17),
        obscureText: myBool,
        onSaved: widget.onSaved,
        decoration: InputDecoration(
          suffixIcon: !widget.emailBool ? GestureDetector(
            onTap: () {
              setState(() {
                myBool = !myBool;
              });
            },
            child: Container(
              child: myBool
                  ? Icon(
                Icons.visibility,
              )
                  : Icon(
                Icons.visibility_off,
              ),
            ),
          ):null,
          contentPadding: widget.emailBool ? EdgeInsets.symmetric(horizontal: 12,vertical: 23):EdgeInsets.symmetric(horizontal: 12,vertical: 23),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25),),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),borderSide: BorderSide(color: Colors.grey)),
          labelText: widget.labelText,
          prefixIcon: Icon(widget.icon),
        ),
        validator: (val) {
          if (widget.emailBool && !widget.username) {
            if (val.isEmpty) {
              return "Email alanı boş bırakılamaz";
            }else if (!val.contains("@")) {
              return "Girilen değer mail formatında olmalı!";
            }
            return null;
          }
          else if(widget.username){
            if (val.isEmpty) {
              return "Kullanıcı adı boş bırakılamaz!";
            } else if (val.length < 4 || val.length > 10) {
              return "En az 4 en fazla 10 karakter olabilir!";
            }
            return null;
          }
          if (val.length < 6) {
            return "Parola 6 karakterden fazla olmalı";
          }
          return null;
        },
      ),
    );
  }
}
