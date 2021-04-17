import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/posts.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:social_app/widgets/postCard.dart';
import 'package:social_app/widgets/protectFuture.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{

  List<Post> _posts = [];

  Future<void> _getFlowPosts()async{
    String activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    List<Post> posts = await FireStoreServices().getFlowPosts(activeUserId);
    print(activeUserId);
    print(posts.length);
    if(mounted)
      setState(() {
        _posts = posts;
      });
  }

  @override
  void initState() {
    super.initState();
    _getFlowPosts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Social App", style: GoogleFonts.pacifico(),),
        ),
        body: Container(
          child: RefreshIndicator(
            onRefresh: _getFlowPosts,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _posts.length,
                    itemBuilder: (context, index){
                      Post post = _posts[index];
                      return ProtectFuture(
                        future: FireStoreServices().getUser(post.authorId),
                        builder: (context, snapshot){
                          if(!snapshot.hasData){
                            return SizedBox(height: 0,);
                          }
                          Users user = snapshot.data;
                          return PostCard(author: user, post: post,);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
