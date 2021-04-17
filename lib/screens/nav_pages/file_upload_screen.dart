import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:social_app/services/storage_service.dart';
import 'package:social_app/widgets/loginWidgets/loginFormArea.dart';

class FileUploadScreen extends StatefulWidget {
  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File _file;
  bool loading = false;

  TextEditingController descController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors:[Colors.blueAccent,Color(0xFF6600cc),], //[Color(0xFFFFC300),Color(0xFFFF9A3F)]
            )
        ),
          child: uploadButton()
        )
        : postForm();
  }

  Widget uploadButton() {
    return FlatButton(
      child: Icon(
        Icons.file_upload,
        color: Colors.white,
        size: 50,
      ),
      onPressed: () {
        choosePhotograph();
      },
    );
  }

  Widget postForm() {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: FlatButton(
            onPressed: (){
              setState(() {
                _file = null;
              });
            },
              child: Icon(Icons.arrow_back_ios,color: Colors.white,)
          ),
          backgroundColor: Colors.blueAccent,
          title: Text("Gönderi Oluştur",style: GoogleFonts.pacifico(),),
          actions: [
            Container(
              width: 55,
              child: FlatButton(
                  onPressed: (){
                    createPost();
                  },
                  child: Icon(Icons.check,color: Colors.white.withOpacity(0.7),)
              ),
            )
          ],
        ),
        body: ListView(
          children: [
            loading ? LinearProgressIndicator() : SizedBox(height: 0,),
            AspectRatio(
                aspectRatio: 16.0 / 9.0,
                child: Image.file(_file,fit: BoxFit.cover,)
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: LoginFormArea(
                username: true,
                emailBool: true,
                labelText: "Açıklama Yaz",
                icon: Icons.description,
                controller: descController,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 7),
              child: LoginFormArea(
                username: true,
                emailBool: true,
                labelText: "Fotoğraf nerede çekldi?",
                icon: Icons.location_on,
                controller: locationController,
              ),
            ),
          ],
        ),
      ),
    );
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

  takePhoto() async{
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80
    );
    setState(() {
      _file = File(image.path);
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
      _file = File(image.path);
    });
  }

  createPost()async {
    if(!loading){
      setState(() {
        loading = true;
      });
      String _imageUrl = await StorageService().postImageUpload(_file);
      String activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
      await FireStoreServices().createPost(
          postImageUrl: _imageUrl,
          description: descController.text,
          authorId: activeUserId,
          location: locationController.text
      );
      setState(() {
        loading = false;
        descController.clear();
        locationController.clear();
        _file = null;
      });
    }

  }
}
