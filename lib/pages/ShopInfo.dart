import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopInfo extends StatefulWidget {
  final String shopId;
  const ShopInfo({Key? key, required this.shopId}) : super(key: key);

  @override
  _ShopInfoState createState() => _ShopInfoState();
}

bool cashSelected = false;
bool cardSelected = false;

class _ShopInfoState extends State<ShopInfo> {
  TextEditingController addressController = TextEditingController();
  String startOperationHours = '';
  String endOperationHours = '';
  bool showTimeSelection = true;
  bool hideCustomerview = false;
  late String currentUserId;
  String startToEnd = '';
  String location = '';
  bool isShop = false;

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
            hideCustomerview = true;
            isShop = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchShopInfo();
    addressController.text = location;
    FirebaseFirestore.instance
        .collection('shopInfo')
        .where('shopId', isEqualTo: currentUserId)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        setState(() {
          startOperationHours = snapshot['startOperationHours'];
          endOperationHours = snapshot['endOperationHours'];
          startToEnd = snapshot['startToEnd'];
          location = snapshot['Location'];
          addressController.text = snapshot['Location'] as String? ?? '';
          location = addressController.text;
        });

        print(startOperationHours);
        print(endOperationHours);
        print(startToEnd);
        print(location);
      } // Call fetchUserData method during initialization
    });
  }

  Future<void> fetchShopInfo() async {
    FirebaseFirestore.instance
        .collection('shopInfo')
        .where('shopId', isEqualTo: widget.shopId)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        setState(() {
          startOperationHours = snapshot['startOperationHours'];
          endOperationHours = snapshot['endOperationHours'];
          startToEnd = snapshot['startToEnd'];
          location = snapshot['Location'];
          addressController.text = snapshot['Location'] as String? ?? '';
          location = addressController.text;
        });

        print(startOperationHours);
        print(endOperationHours);
        print(startToEnd);
        print(location);
      } // Call fetchUserData method during initialization
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          startOperationHours = pickedTime.format(context);
          endOperationHours = '';
          showTimeSelection = false;
        } else {
          endOperationHours = pickedTime.format(context);
          showTimeSelection = true;
        }
      });
    }
  }

  void save() {
    sendShopInfo(currentUserId, addressController);
  }

  void sendShopInfo(String uid, TextEditingController addressController) async {
    CollectionReference shopInfoCollection =
        FirebaseFirestore.instance.collection('shopInfo');

    // Check if the document with the shopId already exists
    QuerySnapshot querySnapshot =
        await shopInfoCollection.where('shopId', isEqualTo: uid).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update existing document
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      DocumentReference documentRef = documentSnapshot.reference;

      await documentRef.update({
        'endOperationHours': endOperationHours,
        'startOperationHours': startOperationHours,
        'Location': addressController.text,
        'startToEnd': getOpeningHours(),
      });
    } else {
      // Create new document and set data
      DocumentReference documentRef = shopInfoCollection.doc();

      Map<String, dynamic> data = {
        'shopId': uid,
        'startOperationHours': startOperationHours,
        'endOperationHours': endOperationHours,
        'startToEnd': getOpeningHours(),
        'Location': addressController.text,
      };

      await documentRef.set(data);
    }

    // Fetch the updated shopInfo and display it if the shopId matches the currentUserId
    DocumentSnapshot updatedShopInfo = await shopInfoCollection.doc(uid).get();

    if (updatedShopInfo.exists && updatedShopInfo['shopId'] == uid) {
      setState(() {
        startOperationHours = updatedShopInfo['startOperationHours'];
        endOperationHours = updatedShopInfo['endOperationHours'];
        startToEnd = updatedShopInfo['startToEnd'];

        // Display other shopInfo fields if needed
      });
    }
  }

  String getOpeningHours() {
    if (startOperationHours.isNotEmpty && endOperationHours.isNotEmpty) {
      return '$startOperationHours - $endOperationHours';
    }
    return '';
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text("Info:"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Operation Hours',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (startOperationHours.isEmpty ||
                        endOperationHours.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _selectTime(context, true);
                              },
                              child: Text(
                                startOperationHours.isEmpty
                                    ? 'Select Start Time'
                                    : startOperationHours,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _selectTime(context, false);
                              },
                              child: Text(
                                endOperationHours.isEmpty
                                    ? 'Select End Time'
                                    : endOperationHours,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (startOperationHours.isNotEmpty &&
                        endOperationHours.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Opening Hours: ${getOpeningHours()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Visibility(
                              visible: !hideCustomerview,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showTimeSelection = true;
                                  });
                                  _selectTime(context, true);
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Payment Methods:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      InkWell(
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'Cash',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      InkWell(
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'Card',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Location:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: addressController,
                        readOnly:
                            isShop, // Make the TextField read-only for customers
                        enabled: !isShop,
                        textAlign:
                            TextAlign.center, // Center-align the entered text
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isShop
                              ? FontWeight.bold
                              : FontWeight
                                  .normal, // Make the text bold when isShop is true
                          color: isShop
                              ? Colors.black
                              : null, // Set text color to black when isShop is true
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter location',
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          launch('https://maps.google.com?q=${location}');
                        },
                        child: Icon(
                          Icons.map,
                          color: Colors.green,
                          size: 32.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Visibility(
                  visible: !hideCustomerview,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Saved successfully!'),
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
