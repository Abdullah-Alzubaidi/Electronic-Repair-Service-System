import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FixZone/pages/ChatList.dart';
import 'package:FixZone/widgets/navBarCustomer.dart';
import 'package:flutter/material.dart';
import 'package:FixZone/pages/BottomNavigationBarItem.dart';
import 'package:FixZone/User.dart' as MyAppUser; // Add a prefix to avoid naming conflict

class CustomerPage extends StatefulWidget {
  final MyAppUser.User? user;

  const CustomerPage({Key? key, this.user}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
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
      drawer: const NavBarCustomer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text('Welcome, $name'),
        actions: [
          IconButton(
            icon: Icon(Icons.wechat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatList()),
              );
              print('Open chat');
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 45, 171, 175),
      body: Center(
        child: YourWidget(),
      ),
    );
  }
}

/*MaterialPageRoute(builder: (context) => ChatPage(shopId: '',)),*/