import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/nav_pages/newprofile.dart';
import 'package:social_app/services/firestore_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController searchController = TextEditingController();
  Future<List<Users>> _searchResult;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(),
        body: _searchResult != null ? getSearch() : notSearch(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.blueAccent,
      title: TextFormField(
        cursorColor: Colors.white,
        onFieldSubmitted: (val){
          setState(() {
            _searchResult = FireStoreServices().searchUser(val);
          });
        },
        controller: searchController,
        style: TextStyle(fontSize: 17,color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search,color: Colors.white,),
          suffixIcon: GestureDetector(
              onTap: (){
                searchController.clear();
                setState(() {
                  _searchResult = null;
                });
            },
              child: Icon(Icons.clear,color: Colors.white,)
          ),
          border: InputBorder.none,
          hintStyle: GoogleFonts.pacifico(color: Colors.white.withOpacity(0.7)),
          hintText: "Kullanıcı Ara...",
          fillColor: Colors.blueAccent,
          filled: true,
          contentPadding: EdgeInsets.only(top: 10)
        ),
      ),
    );
  }

  getSearch() {
    return FutureBuilder(
      future: _searchResult,
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }
        if(snapshot.data.length == 0){
          return Center(child: Text("Sonuç Bulunamadı.",style: TextStyle(color: Colors.black54),),);
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index){
            Users user = snapshot.data[index];
            return userRow(user);
          },
        );
      },
    );
  }

  userRow(Users user){
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profileUserId: user.id,)));
      },
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: user.imageUrl.isNotEmpty ? NetworkImage(user.imageUrl) : AssetImage("assets/images/defaultImage.png"),
      ),
      title: Text(user.userName, style: TextStyle(fontWeight: FontWeight.bold),),
      subtitle: Text(user.bio,overflow: TextOverflow.ellipsis,),
    );
  }

  notSearch() {
    return Container();
  }
}
