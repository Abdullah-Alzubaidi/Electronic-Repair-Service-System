import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FixZone/widgets/navBarAdmin.dart';
import 'package:flutter/material.dart';
import 'package:FixZone/pages/BottomNavigationBarItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = ''; // Declare the 'name' variable

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
  void initState() {
    super.initState();
    fetchUserData(); // Call the fetchUserData() function when the state is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarAdmin(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text('Welcome, $name'),
      ),
      backgroundColor: Color.fromARGB(255, 45, 171, 175),
      body: Center(
        child: YourWidget(), // Replace 'YourWidget' with your actual widget.
      ),
    );
  }
}
