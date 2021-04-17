import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/posts.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/edit_profile_screen.dart';
import 'package:social_app/screens/post_screen.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:social_app/widgets/postCard.dart';

class ProfileScreen extends StatefulWidget {
  final String profileUserId;

  const ProfileScreen({this.profileUserId});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int postsCount = 0;
  int followerCount = 0;
  int followCount = 0;
  List<Post> _posts = [];
  String postStyle = "grid";
  String activeUserId;
  bool _isFollow = false;

  _getFollowersCount()async{
    int followersCount = await FireStoreServices().followersCount(widget.profileUserId);
    if(mounted)
      setState(() {
        followerCount = followersCount;
      });
  }
  _getFollowCount()async{
    int followsCount = await FireStoreServices().followCount(widget.profileUserId);
    if(mounted)
      setState(() {
        followCount = followsCount;
      });
  }

  _getPosts()async{
    List<Post> posts = await FireStoreServices().getPosts(widget.profileUserId);
    if(mounted)
      setState(() {
        _posts = posts;
        postsCount = posts.length;
      });
  }

  _isFollowFunc()async{
    bool _isFollowQuery = await FireStoreServices().isFollow(activeUserId: activeUserId, profileUserId: widget.profileUserId);
    setState(() {
      _isFollow = _isFollowQuery;
    });
  }

  @override
  void initState() {
    super.initState();
    _getFollowersCount();
    _getFollowCount();
    _getPosts();
    activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    _isFollowFunc();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Profil",style: GoogleFonts.pacifico(),),
          actions: [
            widget.profileUserId == activeUserId
            ? IconButton(icon: Icon(Icons.logout, color: Colors.white,), onPressed: _logout)
            : SizedBox(height: 0.0,),
          ],
        ),
        body: FutureBuilder<Object>(
            future: FireStoreServices().getUser(widget.profileUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              Users user = snapshot.data;
              return ListView(
                children: [
                  userDetails(user),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialCounter(title: "Gönderiler", num: postsCount),
                      _socialCounter(title: "Takipçi", num: followerCount),
                      _socialCounter(title: "Takip", num: followCount),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: widget.profileUserId == activeUserId ? editProfile(user) : followButton(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: (){
                            setState(() {
                              postStyle = "grid";
                            });
                          },
                          icon:Icon(Icons.grid_view, color: postStyle == "list" ? Colors.grey[500] : Colors.black,)
                      ),
                      IconButton(onPressed: (){setState(() {
                        postStyle = "list";
                      });}, icon:Icon(Icons.format_list_bulleted, color: postStyle != "list" ? Colors.grey[500] : Colors.black)),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 8, top: 8),
                    decoration: BoxDecoration(
                        color: postStyle != "list" ? Colors.grey.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                    ),
                    child: showPosts(user),
                  )
                ],
              );
            }),
      ),
    );
  }
  userDetails(Users user) {
    return Column(
      children: [
        Hero(
          tag: user.imageUrl,
          child: Container(
            margin: EdgeInsets.only(top: 15),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 20,
                )
              ],
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    user.imageUrl),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          user.userName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 60),
          child: Text(
            user.bio,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Card buildPictureCard(String url) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(url),
            )),
      ),
    );
  }
  editProfile(Users user) {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        highlightedBorderColor: Colors.grey[200],
        highlightColor: Colors.grey[100],
        splashColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(user: user,)));
        },
        child: Text("Profili Düzenle"),
      ),
    );
  }

  Widget _socialCounter({String title, int num}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  followButton() {
    return !_isFollow ? follow() : unFollow();
  }

  follow() {
    return FlatButton(
      minWidth: double.infinity,
      onPressed: (){
        FireStoreServices().follow(activeUserId: activeUserId, profileUserId: widget.profileUserId);
        setState(() {
          _isFollow = true;
          followerCount += 1;
        });
      },
      color: Colors.blue,
      child: Text("Takip Et", style: TextStyle(color: Colors.white),),
    );
  }

  unFollow() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        highlightedBorderColor: Colors.grey[200],
        highlightColor: Colors.grey[100],
        splashColor: Colors.white,
        onPressed: () {
          FireStoreServices().unFollow(activeUserId: activeUserId, profileUserId: widget.profileUserId);
          setState(() {
            _isFollow = false;
            followerCount -= 1;
          });
        },
        child: Text("Takipten Çık"),
      ),
    );
  }

  showPosts(Users user) {
    if(postStyle == "list"){
      return ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _posts.length,
          itemBuilder: (context, index){
            return PostCard(post: _posts[index], author: user,);
          }
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      crossAxisCount: 2,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 5 / 6,
      children: [
        for(int i=0; i<_posts.length; i++)
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen(postId: _posts[i].id,postAuthorId: _posts[i].authorId,)));
              },
              child: buildPictureCard(_posts[i].postImageUrl)
          )
      ],
    );
  }
  void _logout(){
    Provider.of<AuthService>(context, listen: false).logOut();
  }



}
