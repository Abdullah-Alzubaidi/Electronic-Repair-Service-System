// ignore: duplicate_ignore
// ignore: prefer_const_constructors

// ignore_for_file: prefer_const_constructors

import 'package:FixZone/pages/EditShopProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NavBarShop extends StatefulWidget {
  const NavBarShop({Key? key}) : super(key: key);

  @override
  State<NavBarShop> createState() => _NavBarShopState();
}

class _NavBarShopState extends State<NavBarShop> {
  String? _imageUrl;
  String? name;
  final uid = FirebaseAuth.instance.currentUser;
  void initState() {
    super.initState();
    initializeFirebase();
    fetchUserData();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
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
          _imageUrl = data?['imageUrl'] ?? '';
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/profile");
              },
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                      shape: BoxShape.circle,
                      image: _imageUrl != null
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_imageUrl!),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    name ?? 'Loading ...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: const Text('Shop Profile'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditShopProfile(shopId: uid),
                  ),
                );
              }
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: const Text('Shop Info'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/ShopInfo", arguments: uid!);
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: const Text(' Requests'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/ShopRequestPage");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.view_list_sharp),
            title: const Text('Accept Request'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/AcceptRequest");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          /* ListTile(
            leading: Icon(Icons.view_list_sharp),
            title: const Text('Request Summary'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/RequestSummary");
            },
          ),*/
          ListTile(
            leading: Icon(Icons.feedback_outlined),
            title: const Text('Customer Feedback'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/CustomerFeedbackPage");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: const Text('History'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/HistoryPage");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/welcome");
            },
          ),
        ],
      ),
    );
  }
}
