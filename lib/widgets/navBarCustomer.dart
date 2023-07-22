import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NavBarCustomer extends StatefulWidget {
  const NavBarCustomer({Key? key}) : super(key: key);

  @override
  State<NavBarCustomer> createState() => _NavBarCustomerState();
}

class _NavBarCustomerState extends State<NavBarCustomer> {
  String? _imageUrl;
  String? name;

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
            leading: Icon(Icons.store_mall_directory_outlined),
            title: const Text('Shops'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/CustomerListShop");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: const Text('My request'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/CustomerRequestPage");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.reviews_outlined),
            title: const Text('My reviews'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/CustomerMyReview");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.report,
            ),
            title: const Text('Complaint'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/ComplaintCardPage");
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.lightbulb_outline),
            title: const Text('Suggest features'),
            trailing: Icon(Icons.keyboard_arrow_right,
                size: 30, color: Color.fromARGB(255, 0, 0, 0)),
            onTap: () {
              Navigator.pushNamed(context, "/SuggestFeatures");
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
