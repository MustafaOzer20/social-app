import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/screens/nav_pages/file_upload_screen.dart';
import 'package:social_app/screens/nav_pages/newprofile.dart';
import 'package:social_app/screens/nav_pages/notifications_screen.dart';
import 'package:social_app/screens/nav_pages/search_screen.dart';
import 'package:social_app/services/auth_service.dart';
import 'nav_pages/home_screen.dart';

class NavScreen extends StatefulWidget {
  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final int _numPages = 5;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;



  List<IconData> pages = [
    Icons.home,
    Icons.search,
    Icons.add_box,
    Icons.favorite,
    Icons.person
  ];


  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true,i) : _indicator(false,i));
    }
    return list;
  }

  Widget _indicator(bool isActive,int i) {
    return GestureDetector(
      onTap: (){
        _pageController.jumpToPage(i);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        height: 45.0,
        width: isActive ? 78.0 : 60.0,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.blueAccent,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: isActive
            ? Align(alignment:Alignment.center,child: Icon(pages[_currentPage],color: Colors.blueAccent,))
            : Align(alignment:Alignment.center,child: Icon(pages[i],color: Colors.white,),
      ),
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    return Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index){
            setState(() {
              _currentPage = index;
            });
          },
          controller: _pageController,
          children: [
            HomeScreen(),
            SearchScreen(),
            FileUploadScreen(),
            NotificationsScreen(),
            ProfileScreen(profileUserId: activeUserId,),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
          color: Colors.blueAccent,
          child: Row(
            children: _buildPageIndicator(),
          ),
        )
    );
  }
}
/*
BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false,
          selectedFontSize: 0,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home,size: 27,),
                label: ""
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search,size: 27,),
                label: ""
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined,size: 27,),
                label: ""
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border,size: 27,),
                label: ""
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person,size: 27,),
                label: ""
            ),
          ],
          onTap: (index){
            setState(() {
              _pageController.jumpToPage(index);
            });
          },
        )
 */
