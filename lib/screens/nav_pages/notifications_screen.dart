import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/notifications.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/nav_pages/newprofile.dart';
import 'package:social_app/screens/post_screen.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Notifications> notifications;
  String _activeUserId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    getNotifications();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> getNotifications()async{
    List<Notifications> _notifications = await FireStoreServices().getNotification(profileUserId: _activeUserId);
    if(mounted){
      setState(() {
        notifications = _notifications;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Bildirimler", style: GoogleFonts.pacifico(),),
        ),
        body: showNotifications(),
      ),
    );
  }

  showNotifications(){
    if(loading){
      return Center(child: CircularProgressIndicator(),);
    }
    if(notifications.isEmpty){
      return Center(child: Text("Hiç bildirim yok."),);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: RefreshIndicator(
        onRefresh: getNotifications,
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index){
            Notifications notification = notifications[index];
            return rowNotification(notification);
          },
        ),
      ),
    );
  }

  rowNotification(Notifications notification){
    String message = buildMessage(notification.activityType);
    return FutureBuilder<Users>(
      future: FireStoreServices().getUser(notification.activityAuthorId),
      builder: (context, snapshot){
        if(!snapshot.hasData)
          return SizedBox(height: 0,);
        Users user = snapshot.data;
        return ListTile(
          leading: InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(profileUserId: user.id,)));
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: user.imageUrl.isNotEmpty
                  ? NetworkImage(user.imageUrl)
                  : AssetImage("assets/images/defaultImage"),
            ),
          ),
          title: RichText(
            text: TextSpan(
              recognizer: TapGestureRecognizer()..onTap=(){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(profileUserId: user.id,)));
              },
              text: "${user.userName}  ",
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: notification.comment == null
                      ? message + "\n"
                      : message + " : '${notification.comment}' ",
                  style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black, fontSize: 14),
                ),
                TextSpan(
                  text: timeago.format(notification.createdTime.toDate(), locale: "tr"),
                  style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black54, fontSize: 14),
                )
              ]
            ),
          ),
          trailing: postImageControl(notification.activityType, notification.postImage, notification.postId),
        );
      }
    );
  }
  postImageControl(String activityType, String postImageUrl, String postId){
    if(activityType == "follow")
      return null;
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(postId: postId, postAuthorId: _activeUserId,)));
      },
        child: Image.network(postImageUrl, width: 50, height: 50, fit: BoxFit.cover,)
    );
  }
  buildMessage(String activityType){
    if(activityType == "like"){
      return "gönderini beğendi.";
    }else if(activityType == "follow"){
      return "seni takip etti.";
    }
    else if(activityType == "comment"){
      return "gönderine yorum yaptı.";
    }
    return null;
  }
}
