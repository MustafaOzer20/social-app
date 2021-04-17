import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_app/models/comment.dart';
import 'package:social_app/models/posts.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final Post post;
  final Users user;
  final Users postUser;

  const CommentsScreen({this.post, this.user, this.postUser});
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {

  TextEditingController commentController = TextEditingController();

  @override
  void initState(){
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          title: Text("Yorumlar",style: GoogleFonts.pacifico(),),
        ),
        body: Column(
          children: [
            widget.post.description.isNotEmpty ? _showDesc() : SizedBox(height: 0,),
            _showComments(),
            _addComment(),
          ],
        ),
      ),
    );
  }

  _showDesc(){
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: widget.postUser.imageUrl.isNotEmpty ? NetworkImage(widget.postUser.imageUrl) : AssetImage("assets/images/defaultImage.png"),
      ),
      title: RichText(
        text: TextSpan(
          text: widget.postUser.userName + "  ",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          children: [
            TextSpan(
              text: widget.post.description,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  _lineComment({Comment comment}){
    return FutureBuilder<Users>(
      future: FireStoreServices().getUser(comment.authorId),
      builder: (context, snapshot) {
        Users author = snapshot.data;

        if(!snapshot.hasData){
          return SizedBox(height: 0,);
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: author.imageUrl.isNotEmpty ? NetworkImage(author.imageUrl) : AssetImage("assets/images/defaultImage.png"),
          ),
          title: RichText(
            text: TextSpan(
              text: author.userName + "  ",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              children: [
                TextSpan(
                  text: comment.content,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          subtitle: Text(timeago.format(comment.createdTime.toDate(), locale: "tr")),
        );
      }
    );
  }

  _showComments() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FireStoreServices().getComments(widget.post.id),
          builder: (context, snapshot){
            if(!snapshot.hasData)
              return Center(child: CircularProgressIndicator(),);

            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index){
                Comment comment = Comment.docBuild(snapshot.data.docs[index]);
                var createTime = comment.createdTime.toDate();
                return _lineComment(comment: comment);
              },
            );
          },
        ),
    );
  }

  _addComment() {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 20,
              backgroundImage: widget.user.imageUrl.isNotEmpty
                  ? NetworkImage(widget.user.imageUrl)
                  : AssetImage("assets/images/defaultImage.png"),
            ),
            SizedBox(width: 15,),
            Expanded(
              child: TextFormField(
                controller: commentController,
                minLines: 1,
                maxLines: 5,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: GoogleFonts.pacifico(color: Colors.white.withOpacity(0.7)),
                  hintText: "${widget.user.userName} olarak yorum yap...",
                  border: InputBorder.none
                ),
              ),
            ),
            FlatButton(
              textColor: Colors.blueAccent,
                onPressed: commentAdd,
                child: Text("Paylaş",style: GoogleFonts.pacifico(color: Colors.white),)
            )
          ],
        )
    );
  }

  commentAdd() {
    FireStoreServices().addComments(activeUserId: widget.user.id, post: widget.post, content: commentController.text);
    commentController.clear();
  }


}
