import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: const Center(
          child: Text(
            "Welcome to the home page!",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
  backgroundColor:  Colors.grey,
  color:  Colors.white70,
  buttonBackgroundColor: Colors.white,
  height: 50,
  index: _currentIndex,
  onTap: (int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) { // Change the index comparison to 1 for the "Profile" item
        Navigator.pushNamed(context, "/profile");
      }
    });
  },
  items: const [
    Icon(Icons.person),
  ],
)
        );
  }
}
