import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService{
  Reference _storage = FirebaseStorage.instance.ref();
  String imageId;

  Future<String> postImageUpload(File imageFile)async{
   imageId = Uuid().v4();
   UploadTask uploadManager = _storage.child("resimler/gonderiler/gonderi_$imageId.jpg").putFile(imageFile);
   TaskSnapshot snapshot = await uploadManager;

   String uploadedImage = await snapshot.ref.getDownloadURL();

   return uploadedImage;
  }

  Future<String> profileImageUpload(File imageFile)async{
    imageId = Uuid().v4();
    UploadTask uploadManager = _storage.child("resimler/profile/profile_$imageId.jpg").putFile(imageFile);
    TaskSnapshot snapshot = await uploadManager;

    String uploadedImage = await snapshot.ref.getDownloadURL();

    return uploadedImage;
  }

  void deletePostImage(String postImageUrl){
    RegExp searchImageName = RegExp(r"gonderi_.+\.jpg");
    var result = searchImageName.firstMatch(postImageUrl);
    String fileName = result[0];
    if(fileName != null){
      _storage.child("resimler/gonderiler/$fileName").delete();
    }
  }
}