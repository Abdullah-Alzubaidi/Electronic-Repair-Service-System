// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:FixZone/pages/registerion.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  String? _imageUrl;
  bool isShopNameVisible = false;
  late String currentUserId;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Upload image to Firebase Storage and get download URL
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('files/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = firebaseStorageRef.putFile(_image!);
      final storageSnapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await storageSnapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
      });

      // Save profile data to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userType = userDoc.data()?['userType'];

          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'uid': userId,
            'userType': userType,
            'fullName': _fullNameController.text,
            'address': _addressController.text,
            'phoneNumber': _phoneNumberController.text,
            'email': _emailController.text,
            'imageUrl': _imageUrl ?? '',
          });

          print('Profile saved successfully!');
        } else {
          print('User document does not exist');
        }
      } else {
        print('User not authenticated');
      }
    }
  }

  bool isObscurePassword = true;

  TextEditingController _addressController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _shopNameController = TextEditingController();

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase
    initializeFirebase();
    fetchUserData();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _shopNameController.dispose();

    super.dispose();
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
          _fullNameController.text = data?['fullName'] ?? '';
          _addressController.text = data?['address'] ?? '';
          _phoneNumberController.text = data?['phoneNumber'] ?? '';
          _emailController.text = data?['email'] ?? '';
          _imageUrl = data?['imageUrl'] ?? '';
          // Check user type and set the visibility flag
          dynamic userType = data?['userType'];
          if (userType is int && userType == 2) {
            isShopNameVisible = true;
          }
        });

        final shopData = await FirebaseFirestore.instance
            .collection('Shops')
            .doc(
                userId) // Assuming the document ID in the "Shops" collection is the same as the user ID
            .get();

        if (shopData.exists) {
          final shopName = shopData.data()?['shopName'];
          _shopNameController.text = shopName ?? '';
        } else {
          print('Shop document does not exist');
        }
      } else {
        print('Document does not exist');
      }
    }
  }

  void showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Successful'),
          content: Text('Profile saved successfully!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
  Future<bool> isShop(userId) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
  
  if (userSnapshot.exists) {
    int userTypeIndex = userSnapshot['userType'];

    // Ensure userTypeIndex is within the valid range
    if (userTypeIndex >= 0 && userTypeIndex < UserType.values.length) {
      return UserType.values[userTypeIndex] == UserType.shop;
    }
  }

  // Default case when userSnapshot doesn't exist or userTypeIndex is invalid
  return false;
}


  String extractImagePathFromUrl(String imageUrl) {
    const String baseUrl = 'https://firebasestorage.googleapis.com/v0/b/';

    // Find the index where the path starts after the base URL
    final int startIndex = imageUrl.indexOf(baseUrl) + baseUrl.length;

    // Find the index where the query parameters start
    final int queryParamsIndex = imageUrl.indexOf('?');

    // Extract the path by removing the base URL and any query parameters
    final String pathWithEncodedChars = queryParamsIndex != -1
        ? imageUrl.substring(startIndex, queryParamsIndex)
        : imageUrl.substring(startIndex);

    // Decode the URL component to get the actual path
    final String path = Uri.decodeComponent(pathWithEncodedChars);

    return path;
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          prefixStyle: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Profile "),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white70,
        body: Container(
          padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
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
                        image: _image != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(_image!),
                              )
                            : _imageUrl != null
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(_imageUrl!),
                                  )
                                : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Colors.white,
                          ),
                          color: Colors.blue,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Take a photo'),
                                      onTap: () {
                                        _pickImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Choose from gallery'),
                                      onTap: () {
                                        _pickImage(ImageSource.gallery);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Remove'),
                                      onTap: () {
                                        _removeImage();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                  labelText: "Full Name",
                  hintText: "Enter your full name",
                ),
                keyboardType: TextInputType.text,
              ),
              Visibility(
                visible:
                    isShopNameVisible, // Function to determine the visibility based on user type
                maintainState:
                    true, // Preserve the state of the widget even when it's hidden
                child: TextFormField(
                  controller: _shopNameController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.store, color: Colors.black),
                    labelText: "Shop Name",
                    hintText: "Enter your Shop Name",
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on, color: Colors.black),
                  labelText: "Location",
                  hintText: "Enter your location",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.map, color: Colors.black),
                    onPressed: () {
                      String address = _addressController.text;
                      String mapsUrl = 'https://maps.google.com?q=$address';
                      launch(mapsUrl);
                    },
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.black),
                  labelText: "Phone Number",
                  hintText: "Enter your phone number",
                ),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _emailController,
                enabled: false, // Disable the text field
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.black),
                  labelText: "Email",
                  hintText: "Enter your email address",
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black54), // Set underline color to black
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                    color: Colors.black), // Set input text color to black
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/Change Password");
                  },
                  child: Text(
                    "Change Password",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final userId = user.uid;

                        // Update the shop name in the Shops collection
                        if(isShop(userId)==true)
                        await FirebaseFirestore.instance
                            .collection('Shops')
                            .doc(userId)
                            .update({'shopName': _shopNameController.text});

                        // Update the profile data in the Users collection
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get();

                        if (userDoc.exists) {
                          final userType = userDoc.data()?['userType'];

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .set({
                            'uid': userId,
                            'userType': userType,
                            'fullName': _fullNameController.text,
                            'address': _addressController.text,
                            'phoneNumber': _phoneNumberController.text,
                            'email': _emailController.text,
                            'imageUrl': _imageUrl ?? '',
                          });

                          print('Profile saved successfully!');
                          showSaveSuccessDialog();
                        } else {
                          print('User document does not exist');
                        }
                      } else {
                        print('User not authenticated');
                      }
                    },
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 9, 9, 9),
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
