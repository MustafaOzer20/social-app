import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final String id;
  final String content;
  final String authorId;
  final Timestamp createdTime;

  Comment({this.id, this.content, this.authorId, this.createdTime});

  factory Comment.docBuild(DocumentSnapshot doc) {
    var docData = doc.data();
    return Comment(
        id : doc.id,
        content: docData['content'],
        authorId: docData['authorId'],
        createdTime: docData['createdTime'],
    );
  }

}