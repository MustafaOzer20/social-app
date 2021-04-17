import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String id;
  final String postImageUrl;
  final String description;
  final String authorId;
  final int likesCount;
  final String location;

  Post({this.id, this.postImageUrl, this.description, this.authorId, this.likesCount, this.location});

  factory Post.docBuild(DocumentSnapshot doc) {
    var docData = doc.data();
    return Post(
      id : doc.id,
      postImageUrl: docData['postImageUrl'],
      description: docData['description'],
      authorId: docData['authorId'],
      likesCount: int.tryParse(docData['likesCount'].toString()),
      location: docData['location']
    );
  }



}