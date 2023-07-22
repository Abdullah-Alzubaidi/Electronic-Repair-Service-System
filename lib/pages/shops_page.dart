// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:FixZone/pages/ChatListShop.dart';
import 'package:FixZone/pages/ChatPage.dart';
import 'package:FixZone/widgets/navBarShop.dart';
import 'package:FixZone/pages/BottomNavigationBarItem.dart';

import '../User.dart' as MyAppUser; // Add a prefix to avoid naming conflict

class ShopsPage extends StatefulWidget {
  final MyAppUser.User? user;

  const ShopsPage({Key? key, this.user}) : super(key: key);

  @override
  _ShopsPageState createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  String name = ''; // Declare the 'name' variable

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Call the fetchUserData() function when the state is initialized
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userData.exists) {
        final data = userData.data();
        print('Document Data: $data');

        setState(() {
          name = data?['fullName'] ?? '';
          // Fetch other user data fields if needed
        });
      } else {
        print('Document does not exist');
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarShop(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text('Welcome, $name'),
        actions: [
          IconButton(
            icon: Icon(Icons.wechat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListShop()),
              );
              print('Open chat');
            },
          ),
        ],
      ),
      body: Center(
        child: YourWidget(),
      ),
    );
  }
}
