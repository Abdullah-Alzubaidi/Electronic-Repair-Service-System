// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FixZone/User.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin List Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminListCustomers(),
    );
  }
}

class AdminListCustomers extends StatelessWidget {
  const AdminListCustomers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text("Customers:"),
      ),
      backgroundColor: Colors.white70,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            final filteredCustomers = documents
                .where((document) => (document.data() as Map<String, dynamic>)['userType'] == 1)
                .toList();
            return ListView.builder(
              itemCount: filteredCustomers.length,
              itemBuilder: (BuildContext context, int index) {
                final customer = (filteredCustomers[index].data() as Map<String, dynamic>);
                return CustomerCard(
                  customer: customer,
                  customerId: filteredCustomers[index].id,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CustomerCard extends StatefulWidget {
  final Map<String, dynamic> customer;
  final String customerId;

  CustomerCard({
    required this.customer,
    required this.customerId,
  });

  @override
  _CustomerCardState createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${widget.customer['fullName']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Email: ${widget.customer['email']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text('Phone Number: ${widget.customer['phoneNumber']}', style: TextStyle(fontSize: 14)),
                    Text('Address: ${widget.customer['address']}', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Ban'),
                    ),
                  ];
                },
                onSelected: (value) async {
                  if (value == 'delete') {
                    await showDeleteConfirmationDialog(context, widget.customerId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context, String customerId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ban Customer'),
          content: Text('Are you sure you want to ban this customer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteCustomer(context, customerId);
                Navigator.of(context).pop();
              },
              child: Text('Ban'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCustomer(BuildContext context, String customerId) async {
    try {
     DocumentReference documentReference= await FirebaseFirestore.instance.collection('users').doc(customerId);
     documentReference.update({
      'userType':3,
     }).then((value) {
      print('User is banned');
     }).catchError((error){
      print('Failed to ban the user: $error');
     });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer banned successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete customer: $e')),
      );
    }
  }
}
