import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_app/models/posts.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:social_app/widgets/postCard.dart';

class PostScreen extends StatefulWidget {
  final String postId;
  final String postAuthorId;

  const PostScreen({this.postId, this.postAuthorId});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Post post;
  Users postAuthor;
  bool loading = true;


  getSinglePost()async{
    Post _post = await FireStoreServices().getSinglePost(widget.postId, widget.postAuthorId);
    if(_post != null){
      Users _postAuthor =  await FireStoreServices().getUser(widget.postAuthorId);
      setState(() {
        post = _post;
        postAuthor = _postAuthor;
        loading = false;
      });
    }else{
      setState(() {
        loading = false;

      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSinglePost();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Gönderi", style: GoogleFonts.pacifico()),
          iconTheme: IconThemeData(
            color: Colors.white
          ),
        ),
        body: !loading
            ? post != null ? Column(
              children: [
                PostCard(post: post, author: postAuthor,)
              ],
            ) : Center(child: Text("Gönderi silinmiş.", style: GoogleFonts.pacifico(),),)
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
