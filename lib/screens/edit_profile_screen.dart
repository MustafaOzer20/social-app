import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:social_app/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Users user;

  const EditProfileScreen({this.user});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var _formKey = GlobalKey<FormState>();
  String newUserName;
  String newBio;
  File _choosePhoto;
  bool _loading = false;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.clear,color: Colors.white,)
          ),
          title: Text("Profili Düzenle",style: GoogleFonts.pacifico(),),
          actions: [
            IconButton(onPressed: _saveNewProfile, icon: Icon(Icons.check,color: Colors.white.withOpacity(0.7),))
          ],
        ),
        body: ListView(
          children: [
            _loading ? LinearProgressIndicator() : SizedBox(height: 0,),
            _setProfilePhotos(),
            Center(
              child: FlatButton.icon(
                textColor: Colors.black54,
                onPressed: choosePhotograph,
                icon: Icon(Icons.drive_folder_upload),
                label: Text("Profil Fotoğrafını Değiştir"),
              ),
            ),
            _setProfileInformation(),
          ],
        ),
      ),
    );
  }

  _setProfilePhotos() {
    return Padding(
      padding: const EdgeInsets.only(top: 15,bottom: 20),
      child: Center(
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey[300],
            backgroundImage: _imageControl(),
          )
      ),
    );
  }

  _setProfileInformation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.user.userName,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: "Kullanıcı adı",
              ),
              validator: (val){
                return val.trim().length <= 3 || val.trim().length > 10
                    ? "Kullanıcı adı en az 4, en fazla 10 karakter olmalı"
                    : null;
              },
              onSaved: (val){
                newUserName = val;
              },
            ),
            TextFormField(
              initialValue: widget.user.bio,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.content_paste),
                labelText: "Hakkında",
              ),
              validator: (val){
                return val.trim().length > 100 ? "100 karakterden fazla olmamalı" : null;
              },
              onSaved: (val){
                newBio = val;
              },
            ),

          ],
        ),
      ),
    );
  }

  _saveNewProfile()async{
    if(_formKey.currentState.validate()){
      setState(() {
        _loading = true;
      });
      _formKey.currentState.save();

      String profileImageUrl;
      if(_choosePhoto == null){
        profileImageUrl = widget.user.imageUrl;
      }
      else{
        profileImageUrl = await StorageService().profileImageUpload(_choosePhoto);
      }

      FireStoreServices().updateUser(
        UserId: widget.user.id,
        userName: newUserName,
        bio: newBio,
        imageUrl: profileImageUrl
      );
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
    }
  }

  choosePhotograph() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Gönderi Oluştur"),
            children: [
              SimpleDialogOption(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                onPressed: () {
                  takePhoto();
                },
                child: Text("Fotoğraf Çek"),
              ),
              SimpleDialogOption(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                onPressed: () {
                  chooseFromGallery();
                },
                child: Text("Galeriden Seç"),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("İptal"),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
  deletePhoto(){

  }
  takePhoto() async{
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80
    );
    setState(() {
      _choosePhoto = File(image.path);
    });
  }

  chooseFromGallery() async{
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80
    );
    setState(() {
      _choosePhoto = File(image.path);
    });
  }

  _imageControl() {
    if(widget.user.imageUrl.isNotEmpty && _choosePhoto == null){
      return NetworkImage(widget.user.imageUrl);
    }else if(widget.user.imageUrl.isEmpty && _choosePhoto == null){
      return AssetImage("assets/images/defaultImage.png");
    }else{
      return FileImage(_choosePhoto);
    }
  }
}
