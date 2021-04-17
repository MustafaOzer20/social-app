import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications{
  final String id;
  final String activityAuthorId;
  final String activityType;
  final String postId;
  final String postImage;
  final String comment;
  final Timestamp createdTime;

  Notifications({this.id, this.activityAuthorId, this.activityType, this.postId, this.postImage, this.comment, this.createdTime});

  factory Notifications.docBuild(DocumentSnapshot doc) {
    var docData = doc.data();
    return Notifications(
      id : doc.id,
      activityAuthorId: docData['activityAuthorId'],
      activityType: docData['activityType'],
      postId: docData['postId'],
      postImage: docData['postImage'],
      comment: docData['comment'],
      createdTime: docData['createdTime'],
    );
  }

}