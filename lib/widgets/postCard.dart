import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/posts.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/comments_screen.dart';
import 'package:social_app/screens/nav_pages/newprofile.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Users author;

  const PostCard({this.post, this.author});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _likeCount = 0;
  bool _isLiked = false;
  String activeUserId;
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    _likeCount = widget.post.likesCount;
    _isLikedFunc();
  }

  _isLikedFunc()async{
    bool userIsLiked = await FireStoreServices().isLiked(widget.post, activeUserId);
    if(userIsLiked){
      if(mounted){
        setState(() {
          _isLiked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isDeleted ? SizedBox(height: 0,) : Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.only(top: 5,bottom: 5),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 20,
                offset: Offset(0,10),
              ),
            ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          children: [_postTitle(), SizedBox(height: 3,), _postImage(), _likeCount != 0 ? _postFooter() : SizedBox(height: 10,)],
        ),
      ),
    );
  }

  postSettings(){
    showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Text("Gönderi Seçenekleri"),
            children: [
              SimpleDialogOption(
                child: Text("Gönderiyi Sil"),
                onPressed: ()async{
                  await FireStoreServices().deletePost(activeUserId, widget.post);
                  setState(() {
                    isDeleted = true;
                  });
                  Navigator.pop(context);
                },
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                      onPressed: (){Navigator.pop(context);},
                    textColor: Colors.red,
                    child: Text("Vazgeç"),
                  ),
                ),
              ),
            ],
          );
        },
    );
  }

  _postTitle() {
    return ListTile(
      leading: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profileUserId: widget.author.id,)));
        },
        child: CircleAvatar(
          backgroundColor: Colors.grey[300],
          backgroundImage: widget.author.imageUrl.isNotEmpty
              ? NetworkImage(widget.author.imageUrl)
              : AssetImage("assets/images/defaultImage.png"),
        ),
      ),
      title: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profileUserId: widget.author.id,)));
        },
        child: Text(
          widget.author.userName,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: mySubtitle(),
      trailing: activeUserId == widget.author.id ? GestureDetector(
        child: Icon(Icons.more_vert),
        onTap: postSettings,
      ) : null,
    );
  }

  _postImage() {
    return GestureDetector(
      onDoubleTap: likeFunc,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: MediaQuery.of(context).size.width-30,
              height: MediaQuery.of(context).size.width-30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                /*boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 20,
                    offset: Offset(0,10),
                  ),
                ],*/
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.post.postImageUrl),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 15,
              right: 25,
              child: GestureDetector(onTap: likeFunc, child: Icon(Icons.favorite,size: 30,color: _isLiked ? Colors.red : Colors.white.withOpacity(0.7),))
          ),
          Positioned(
              bottom: 15,
              right: 65,
              child: GestureDetector(
                onTap: ()async{
                  Users user = await FireStoreServices().getUser(activeUserId);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen(post: widget.post,user: user,postUser: widget.author)));
                },
                  child: Icon(Icons.mode_comment,size: 28,color: Colors.white.withOpacity(0.7),)
              )
          ),
        ],
      ),
    );
  }

  _postFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: EdgeInsets.only(left: 30.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "$_likeCount beğeni",
              style: TextStyle(fontSize: 17, color: Colors.black54),
            )),
      ),
    );
  }

  void likeFunc() {
    if(_isLiked){
      setState(() {
        _isLiked = false;
        _likeCount -= 1;
      });
      FireStoreServices().removeLikePost(widget.post, activeUserId);
    }
    else{
      setState(() {
        _isLiked = true;
        _likeCount += 1;
      });
      FireStoreServices().likePost(widget.post, activeUserId);
    }

  }

  mySubtitle() {
    if(widget.post.description.isNotEmpty){
      return RichText(
          maxLines: 2,
          text: TextSpan(text: widget.post.description, style: TextStyle(color: Colors.grey[600]))
      );
    }
    if(widget.post.location.isNotEmpty){
      return RichText(
      maxLines: 1,
      text: TextSpan(text: widget.post.location, style: TextStyle(color: Colors.grey[600]))
    );
    }
    return null;
  }
}
