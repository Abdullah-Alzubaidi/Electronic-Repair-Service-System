import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: AdminListShop(),
    );
  }
}

class AdminListShop extends StatefulWidget {
  const AdminListShop({Key? key}) : super(key: key);

  @override
  _AdminListShopState createState() => _AdminListShopState();
}

class _AdminListShopState extends State<AdminListShop> {
  CollectionReference shopsCollection = FirebaseFirestore.instance.collection('Shops');

  Future<void> addShopToFirebase() async {
    QuerySnapshot snapshot = await shopsCollection.get();
    String id = '${snapshot.docs.length + 1}';
    Shop newShop = Shop(
      id: id,
      shopName: 'Shop $id',
      email: 'shop$id@gmail.com',
      address: 'Address $id',
      phoneNumber: '1234567890',
    );
    await shopsCollection.doc(id).set({
      'shopName': newShop.shopName,
      'email': newShop.email,
      'address': newShop.address,
      'phoneNumber': newShop.phoneNumber,
    });
  }

  Future<void> deleteShopFromFirebase(String shopId) async {
    try {
     DocumentReference documentReference= await FirebaseFirestore.instance.collection('users').doc(shopId);
     documentReference.update({
      'userType':3,
     }).then((value) {
      print('User is banned');
     }).catchError((error){
      print('Failed to ban the user: $error');
     });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shop banned successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ban shop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text("List of shops:"),
      ),
      backgroundColor: Colors.white70,
      body: StreamBuilder<QuerySnapshot>(
        stream: shopsCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Shop> shopList = snapshot.data!.docs.map((doc) {
              String id = doc.id;
              Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                String? shopName = data['shopName'] as String?;
                String? email = data['email'] as String?;
                String? address = data['address'] as String?;
                String? phoneNumber = data['phoneNumber'] as String?;
                return Shop(
                  id: id,
                  shopName: shopName ?? '',
                  email: email ?? '',
                  address: address ?? '',
                  phoneNumber: phoneNumber ?? '',
                );
              } else {
                return Shop(
                  id: '',
                  shopName: '',
                  email: '',
                  address: '',
                  phoneNumber: '',
                );
              }
            }).toList();
            return ShopList(shopList: shopList, deleteShop: deleteShopFromFirebase);
          }
        },
      ),
      
    );
  }
}

class Shop {
  final String id;
  final String shopName;
  final String email;
  final String address;
  final String phoneNumber;

  Shop({
    required this.id,
    required this.shopName,
    required this.email,
    required this.address,
    required this.phoneNumber,
  });
}

class ShopCard extends StatelessWidget {
  final Shop shop;
  final Function(String) deleteShop;

  ShopCard({required this.shop, required this.deleteShop});

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
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
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
                      'Shop ID: ${shop.id}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Shop Name: ${shop.shopName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text('Email: ${shop.email}', style: TextStyle(fontSize: 14)),
                    Text('Address: ${shop.address}', style: TextStyle(fontSize: 14)),
                    Text('Phone Number: ${shop.phoneNumber}', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, shop.id);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Ban'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String shopId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ban Shop'),
          content: Text('Are you sure you want to ban this shop?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteShop(shopId);
                Navigator.of(context).pop();
              },
              child: Text('Ban'),
            ),
          ],
        );
      },
    );
  }
}

class ShopList extends StatelessWidget {
  final List<Shop> shopList;
  final Function(String) deleteShop;

  ShopList({required this.shopList, required this.deleteShop});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shopList.length,
      itemBuilder: (context, index) {
        return ShopCard(shop: shopList[index], deleteShop: deleteShop);
      },
    );
  }
}
