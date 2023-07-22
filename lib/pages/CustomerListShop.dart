// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FixZone/pages/Shop%20Profile.dart';
import 'package:flutter/animation.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CustomerListShop(),
    );
  }
}

class CustomerListShop extends StatefulWidget {
  const CustomerListShop({Key? key}) : super(key: key);

  @override
  _CustomerListShopState createState() => _CustomerListShopState();
}

class _CustomerListShopState extends State<CustomerListShop> {
  TextEditingController searchController = TextEditingController();
  Future<List<Shop>>? shopListFuture;
  CollectionReference shopsCollection =
      FirebaseFirestore.instance.collection('Shops');
  List<Shop> filteredShopList = [];

  Future<List<Shop>> fetchShopsFromFirebase() async {
    QuerySnapshot snapshot = await shopsCollection.get();
    List<Shop> shops = [];
    snapshot.docs.forEach((doc) {
      String id = doc.id;
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        String? shopName = data['shopName'] as String?;
        dynamic rating = data['rating']; // Change the type to dynamic
        String? imageUrl = data['imageUrl'] as String?;
        List<String>? services = data['services'] != null
            ? List<String>.from(data['services'])
            : null;

        double parsedRating = rating is double
            ? rating
            : (rating is int ? rating.toDouble() : 0.0);

        shops.add(Shop(
          id: id,
          shopName: shopName ?? '',
          rating: parsedRating,
          imageUrl: imageUrl ?? '',
          services: services,
        ));
      }
    });

    if (searchController.text.isNotEmpty) {
      String searchQuery = searchController.text.toLowerCase();
      filteredShopList = shops.where((shop) {
        if (shop.services != null) {
          return shop.services!
              .any((service) => service.toLowerCase().contains(searchQuery));
        }
        return false;
      }).toList();
    } else {
      filteredShopList = shops;
    }

    return filteredShopList;
  }

  @override
  void initState() {
    super.initState();
    shopListFuture = fetchShopsFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            title: const Text("Shops"),
            centerTitle: true,
            floating: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Colors.white70,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: TextFormField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    shopListFuture = fetchShopsFromFirebase();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search The Services',
                  prefixIcon: Icon(Icons.search,
                      color: Colors.black), // Change icon color to black
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                        color: Colors.black), // Change border color to black
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                        color: Colors.black), // Change border color to black
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black), // Change label text color to black
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: FutureBuilder<List<Shop>>(
              future: shopListFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Shop>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (snapshot.hasData) {
                  List<Shop> shopList = snapshot.data!;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ShopCard(shop: shopList[index]);
                      },
                      childCount: shopList.length,
                    ),
                  );
                } else {
                  return SliverFillRemaining(
                    child: Center(child: Text('No shops available.')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final Shop shop;

  ShopCard({required this.shop});

  Future<double> calculateAverageRating(shopId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('shopId', isEqualTo: shopId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Handle the case when no documents found for the current user
      return 0.0;
    }

    double totalRating = 0;
    for (final doc in querySnapshot.docs) {
      final rating = doc.get('rating') as double;
      totalRating += rating;
    }

    final averageRating = totalRating / querySnapshot.docs.length;
    return averageRating;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the shop profile page with a sliding animation
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: ShopProfile(shopId: shop.id),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var curve = Curves.easeInOut;
              var tween =
                  Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
              var opacityAnimation = animation.drive(tween);
              return FadeTransition(
                opacity: opacityAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 14, 0, 0),
              child: Container(
                width: 120,
                height: 120,
                color: shop.imageUrl.isEmpty ? Colors.grey : null,
                child: shop.imageUrl.isEmpty
                    ? const Icon(Icons.image, size: 80, color: Colors.white)
                    : Image.network(
                        shop.imageUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Name: ${shop.shopName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<double>(
                      future: calculateAverageRating(shop.id),
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // While the rating is being fetched, you can show a loading indicator
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // Handle error if the rating retrieval fails
                          return Text('Error: ${snapshot.error}');
                        } else {
                          // Show the actual rating value
                          return Text(
                            'Rating: ${snapshot.data?.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 14),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}

class Shop {
  final String id;
  final String shopName;
  final double rating;
  final String imageUrl;
  final List<String>? services;

  Shop({
    required this.id,
    required this.shopName,
    required this.rating,
    required this.imageUrl,
    this.services,
  });
}
