import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/notifications.dart';
import 'package:social_app/models/posts.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/storage_service.dart';

class FireStoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime myTime = DateTime.now();

  Future<void> buildUser({id, email, userName, imageUrl = ""}) async {
    await _firestore.collection("users").doc(id).set({
      "userName": userName,
      "email": email,
      "imageUrl": imageUrl,
      "bio": "",
      "createTime": myTime,
    });
  }

  Future<Users> getUser(id) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(id).get();
    if (doc.exists) {
      Users user = Users.docBuild(doc);
      return user;
    }
    return null;
  }

  void updateUser({String UserId, String userName, String imageUrl = "", String bio}) {
    _firestore.collection("users").doc(UserId).update({
      'userName': userName,
      'bio': bio,
      'imageUrl': imageUrl
    });
  }

  Future<List<Users>> searchUser(String word)async{
    QuerySnapshot snapshot = await _firestore.collection("users").where("userName", isGreaterThanOrEqualTo: word).get();
    List<Users> users = snapshot.docs.map((doc) => Users.docBuild(doc)).toList();
    return users;
  }

  void follow({String activeUserId, String profileUserId}){
    _firestore.collection('followers').doc(profileUserId).collection("user'sFollowers").doc(activeUserId).set({});
    _firestore.collection('follow').doc(activeUserId).collection("user'sFollow").doc(profileUserId).set({});
    addNotification(activityType: "follow", activityAuthorId: activeUserId, profileUserId: profileUserId,);
  }

  void unFollow({String activeUserId, String profileUserId})async{
    _firestore.collection('followers').doc(profileUserId).collection("user'sFollowers").doc(activeUserId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
    _firestore.collection('follow').doc(activeUserId).collection("user'sFollow").doc(profileUserId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
    QuerySnapshot notifSnapshot = await _firestore.collection("notifications").doc(profileUserId).collection("user'sNotifications").where("activityType", isEqualTo: 'follow').where("activityAuthorId", isEqualTo: activeUserId  ).get();
    notifSnapshot.docs.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  Future<bool> isFollow({String activeUserId, String profileUserId})async{
    DocumentSnapshot doc =  await _firestore.collection('follow').doc(activeUserId).collection("user'sFollow").doc(profileUserId).get();
    if(doc.exists){
      return true;
    }
    return false;
  }

  Future<int> followersCount(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("followers")
        .doc(userId)
        .collection("user'sFollowers")
        .get();
    return snapshot.docs.length;
  }

  Future<int> followCount(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("follow")
        .doc(userId)
        .collection("user'sFollow")
        .get();
    return snapshot.docs.length;
  }

  void addNotification({
    String activityAuthorId,
    String profileUserId,
    String activityType,
    String comment,
    Post post
  })
  {
    if(activityAuthorId == profileUserId)
      return;
    _firestore.collection("notifications")
        .doc(profileUserId)
        .collection("user'sNotifications")
        .add({
          "activityAuthorId" : activityAuthorId,
          "activityType" : activityType,
          "postId" : post?.id,
          "postImage" : post?.postImageUrl,
          "comment" : comment,
          "createdTime" : myTime,
        });
  }

  Future<List<Notifications>> getNotification({String profileUserId})async{
     QuerySnapshot snapshot = await _firestore.collection("notifications").doc(profileUserId)
         .collection("user'sNotifications").orderBy("createdTime", descending: true).limit(20).get();

     List<Notifications> notifications = [];
     snapshot.docs.forEach((DocumentSnapshot doc) {
       Notifications notification = Notifications.docBuild(doc);
       notifications.add(notification);
     });

     return notifications;
  }

  Future<void> createPost(
      {postImageUrl, description, authorId, location}) async {
    await _firestore
        .collection("posts")
        .doc(authorId)
        .collection("user'sPosts")
        .add({
      "postImageUrl": postImageUrl,
      "description": description,
      "authorId": authorId,
      "likesCount": 0,
      "location": location,
      "createTime": myTime,
    });
  }

  Future<List<Post>> getPosts(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("posts")
        .doc(userId)
        .collection("user'sPosts")
        .orderBy("createTime", descending: true)
        .get();
    List<Post> posts = snapshot.docs.map((doc) => Post.docBuild(doc)).toList();
    return posts;
  }

  Future<List<Post>> getFlowPosts(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("flows")
        .doc(userId)
        .collection("user'sFlowPosts")
        .orderBy("createTime", descending: true)
        .get();
    List<Post> posts = snapshot.docs.map((doc) => Post.docBuild(doc)).toList();
    return posts;
  }

  Future<void> deletePost(String activeUserId, Post post)async{
    _firestore.collection("posts").doc(activeUserId).collection("user'sPosts").doc(post.id).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
    QuerySnapshot commentSnapshot = await _firestore.collection("comments").doc(post.id).collection("post'sComments").get();
    commentSnapshot.docs.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
    QuerySnapshot notifSnapshot = await _firestore.collection("notifications").doc(activeUserId).collection("user'sNotifications").where("postId", isEqualTo: post.id).get();
    notifSnapshot.docs.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });

    StorageService().deletePostImage(post.postImageUrl);
    QuerySnapshot likeSnapshot = await _firestore.collection("likes").doc(post.id).collection("post'sLikes").get();
    likeSnapshot.docs.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  Future<Post> getSinglePost(String postId, String postAuthorId)async{
    DocumentSnapshot doc = await _firestore.collection("posts").doc(postAuthorId).collection("user'sPosts").doc(postId).get();
    try{
      Post post = Post.docBuild(doc);
      return post;
    }catch(e){
      return null;
    }
  }

  Future<void> likePost(Post post, String activeUserId) async {
    DocumentReference query = _firestore
        .collection("posts")
        .doc(post.authorId)
        .collection("user'sPosts")
        .doc(post.id);
    DocumentSnapshot doc = await query.get();
    if (doc.exists) {
      Post post = Post.docBuild(doc);
      int newLikesCount = post.likesCount + 1;
      query.update({
        "likesCount": newLikesCount,
      });
      _firestore
          .collection("likes")
          .doc(post.id)
          .collection("post'sLikes")
          .doc(activeUserId)
          .set({});
      addNotification(
        activityAuthorId: activeUserId,
        profileUserId: post.authorId,
        activityType: "like",
        post: post,
      );
    }
  }

  Future<void> removeLikePost(Post post, String activeUserId) async {
    DocumentReference query = _firestore
        .collection("posts")
        .doc(post.authorId)
        .collection("user'sPosts")
        .doc(post.id);
    DocumentSnapshot doc = await query.get();
    if (doc.exists) {
      Post post = Post.docBuild(doc);
      int newLikesCount = post.likesCount - 1;
      query.update({
        "likesCount": newLikesCount,
      });
      DocumentSnapshot docLikes = await _firestore.collection("likes").doc(post.id).collection("post'sLikes").doc(activeUserId).get();
      if(docLikes.exists){
        docLikes.reference.delete();
      }
    }
    QuerySnapshot notifSnapshot = await _firestore.collection("notifications").doc(post.authorId).collection("user'sNotifications").where("activityType", isEqualTo: 'like').where("activityAuthorId", isEqualTo: activeUserId  ).get();
    notifSnapshot.docs.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  Future<bool> isLiked(Post post, String activeUserId)async{
    DocumentSnapshot docLikes = await _firestore.collection("likes").doc(post.id).collection("post'sLikes").doc(activeUserId).get();
    if(docLikes.exists)
      return true;

    return false;
  }

  Stream<QuerySnapshot> getComments(String postId){
    return _firestore.collection("comments").doc(postId).collection("post'sComments").orderBy("createdTime",descending: true).snapshots();
  }

  void addComments({Post post, String activeUserId, String content}){
    _firestore.collection("comments").doc(post.id).collection("post'sComments").add({
      "content": content,
      "authorId": activeUserId,
      "createdTime": myTime
    });

    addNotification(
      activityType: "comment",
      activityAuthorId: activeUserId,
      post: post,
      profileUserId: post.authorId,
      comment: content
    );
  }

}
