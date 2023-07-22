// ignore_for_file: must_be_immutable, unused_import, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:FixZone/pages/ChatPage.dart';
import 'package:FixZone/pages/CustomerFeedbackPage.dart';
import 'package:FixZone/pages/ShopInfo.dart';
import 'package:FixZone/pages/submit%20request.dart';

late String shopName = '';

class EditShopProfile extends StatefulWidget {
  late String shopId;

  EditShopProfile({required this.shopId, Key? key}) : super(key: key);

  @override
  State<EditShopProfile> createState() => _EditShopProfileState();
}

class _EditShopProfileState extends State<EditShopProfile> {
  String? selectedService;
  bool showBottomNavBar = false;
  bool hideIconandEnterservices = false;
  late String currentUserId; // Variable to store current user ID
  List<String> services = [];
  TextEditingController serviceController = TextEditingController();
  late String phoneNumberShop = '';
  late String shopImage = '';
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchServices() async {
    final shopData = await FirebaseFirestore.instance
        .collection('Shops')
        .doc(widget.shopId)
        .get();
    if (shopData.exists) {
      final fetchedServices =
          List<String>.from(shopData.data()?['services'] ?? []);
      setState(() {
        services = fetchedServices;
      });
    }
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid; // Store the current user ID

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        final data = userData.data();
        dynamic type = data?['userType'];

        if (type is int && type == 1) {
          setState(() {
            showBottomNavBar = true;
            hideIconandEnterservices = true;
          });
        } else {
          setState(() {
            widget.shopId = user.uid;
          });
        }
      }
      // Fetch shop data from Firestore
      final shopData = await FirebaseFirestore.instance
          .collection('Shops')
          .doc(widget.shopId)
          .get();

      if (shopData.exists) {
        phoneNumberShop = shopData.data()?['phoneNumber'] as String? ?? '';
        print('Phone Number: $phoneNumberShop');
        shopImage = shopData.data()?['imageUrl'] as String? ?? '';
        print('Image: $shopImage');
        services = List<String>.from(shopData.data()?['services'] ?? []);
        print('Services: $services');
      }

      // Call fetchServices() here
      await fetchServices();
      await Future.delayed(Duration(seconds: 1));
    }
  }

  void addService() async {
    final newService = serviceController.text.trim();
    if (newService.isNotEmpty) {
      setState(() {
        services.add(newService);
        serviceController.clear();
      });

      // Update the "Shops" document in Firestore with the new services list
      final shopDoc =
          FirebaseFirestore.instance.collection('Shops').doc(widget.shopId);
      final shopData = await shopDoc.get();

      if (shopData.exists) {
        final currentServices =
            List<String>.from(shopData.data()?['services'] ?? []);
        currentServices.add(newService);

        await shopDoc.update({'services': currentServices});
      }
    }
  }

  void removeService(String service) {
    setState(() {
      services.remove(service);
    });

    // Update the "Shops" document in Firestore with the updated services list
    final shopDoc =
        FirebaseFirestore.instance.collection('Shops').doc(widget.shopId);
    shopDoc.update({'services': services});
  }

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Upload the image to Firestore and store the URL in the 'backgroundImage' field
      final shopDoc =
          FirebaseFirestore.instance.collection('Shops').doc(widget.shopId);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('shop_backgrounds')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadURL = await snapshot.ref.getDownloadURL();
      shopDoc.update({'backgroundImage': downloadURL});
    }
  }

  Future<double> calculateAverageRating() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('shopId', isEqualTo: widget.shopId)
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
    List<DropdownMenuItem<String>> dropdownItems = services.map((service) {
      return DropdownMenuItem<String>(
        value: service,
        child: Text(service),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text("Shop Profile:"),
      ),
      backgroundColor: Colors.blueGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.grey,
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        )
                      : StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Shops')
                              .doc(widget.shopId)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final shopData = snapshot.data!.data()!
                                  as Map<String, dynamic>;
                              final backgroundImageURL =
                                  shopData['backgroundImage'] as String?;
                              return backgroundImageURL != null
                                  ? Image.network(
                                      backgroundImageURL,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.add_a_photo,
                                      size: 50,
                                      color: Colors.white,
                                    );
                            } else {
                              return const Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.white,
                              );
                            }
                          },
                        ),
                ),
                Visibility(
                    visible: !hideIconandEnterservices,
                    child: Positioned(
                      top: 16.0,
                      right: 16.0,
                      child: IconButton(
                        onPressed: _pickImage,
                        icon: Icon(Icons.edit),
                      ),
                    )),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Shops')
                        .doc(widget.shopId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('Document does not exist');
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Column(
                          children: [
                            RatingBar.builder(
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                // Handle rating update here
                              },
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No rating available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }
                      final shopData =
                          snapshot.data!.data()! as Map<String, dynamic>;
                      final shopName = shopData['shopName'] as String? ??
                          'Shop Name Unavailable';

                      return Container(
                        width: double.infinity,
                        height: 100,
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: snapshot.hasData &&
                                        snapshot.data!.exists &&
                                        (snapshot.data!.data()
                                                as Map<String, dynamic>)
                                            .containsKey('imageUrl')
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          (snapshot.data!.data() as Map<String,
                                              dynamic>)['imageUrl'],
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: snapshot.hasData &&
                                      snapshot.data!.exists &&
                                      (snapshot.data!.data()
                                              as Map<String, dynamic>)
                                          .containsKey('imageUrl')
                                  ? null
                                  : Icon(Icons.image,
                                      size: 80,
                                      color: const Color.fromARGB(255, 0, 0,
                                          0)), // Remove the 'const' keyword
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap:
                                        () {}, // Empty onTap callback to disable user interaction
                                    child: FutureBuilder<double>(
                                      future: calculateAverageRating(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<double> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }
                                        final averageRating =
                                            snapshot.data ?? 0.0;
                                        return RatingBar.builder(
                                          initialRating: averageRating,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 18.0,
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                              onRatingUpdate: (rating) {
      // Empty onRatingUpdate callback
    },
                                          ignoreGestures: true,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    shopName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "The services provided",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Visibility(
                          visible: !hideIconandEnterservices,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: services.map((service) {
                              return Chip(
                                label: Text(service),
                                onDeleted: () {
                                  removeService(service);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 10),
                        Visibility(
                          visible: !hideIconandEnterservices,
                          child: Stack(
                            children: [
                              TextFormField(
                                controller: serviceController,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  labelText: 'Enter a service',
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  onPressed: addService,
                                  icon: Icon(Icons.add_box_rounded),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 85,
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Select a service',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                      value:
                          selectedService, // Set the currently selected service value
                      items: dropdownItems,
                      onChanged: (String? service) {
                        setState(() {
                          selectedService = service;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNavBar
          ? CurvedNavigationBar(
              backgroundColor: Colors.blueGrey,
              color: Colors.white70,
              height: 60,
              animationDuration: const Duration(milliseconds: 200),
              animationCurve: Curves.easeInOut,
              index: 0,
              items: const <Widget>[
                Column(
                  children: [
                    Icon(Icons.chat, size: 40),
                    Text('Chat'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.send_outlined, size: 40),
                    Text('Request'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.rate_review, size: 40),
                    Text('Review'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.info, size: 40),
                    Text('Info'),
                  ],
                ),
              ],
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Submit(
                        shopId: widget.shopId,
                        typeServices: selectedService ?? '',
                        shopName: shopName,
                        phoneNumberShop: phoneNumberShop,
                        shopImage: shopImage,
                        services: services.toList(),
                      ),
                    ),
                  );
                } else if (index == 2) {
                  print('Shop ID: ${widget.shopId}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerFeedbackPage(shopId: widget.shopId),
                    ),
                  );
                } else if (index == 3) {
                  print('Shop ID: ${widget.shopId}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShopInfo(
                              shopId: widget.shopId,
                            )),
                  );
                } else if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              shopId: widget.shopId,
                              userId: currentUserId,
                            )),
                  );
                }
              },
            )
          : null,
    );
  }
}
