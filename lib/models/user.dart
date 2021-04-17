import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Users {

  final String id;
  final String userName;
  final String imageUrl;
  final String email;
  final String bio;

  Users({@required this.id, this.userName, this.imageUrl, this.email,  this.bio});


  factory Users.firebaseBuildUser(User user) {
    return Users(
      id: user.uid,
      userName: user.displayName,
      imageUrl: user.photoURL,
      email: user.email,
    );
  }


  factory Users.docBuild(DocumentSnapshot doc) {
    var docData = doc.data();
    return Users(
      id : doc.id,
      userName: docData['userName'],
      email: docData['email'],
      imageUrl: docData['imageUrl'],
      bio: docData['bio'],
    );
  }


}