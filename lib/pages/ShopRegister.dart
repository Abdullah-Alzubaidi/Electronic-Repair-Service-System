import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FixZone/Shop.dart';
import 'package:FixZone/User.dart' as MyUser;

enum UserType {
  shop,
  // add more user types if needed
}

class RegisterShop extends StatefulWidget {
  const RegisterShop({Key? key}) : super(key: key);

  @override
  _RegisterShopState createState() => _RegisterShopState();
}

class _RegisterShopState extends State<RegisterShop>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
      
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    try {
      if (_passwordController.text.trim() ==
          _confirmPasswordController.text.trim()) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final shop = Shop(
          shopName: _shopNameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          uid: userCredential.user!.uid,
          userType: MyUser.UserType.shop,
          
          imageUrl: _imageUrlController.text.trim(),
        );

        // Add the user to the "Shops" collection in Firestore
        await FirebaseFirestore.instance
            .collection('Shops')
            .doc(userCredential.user!.uid)
            .set({
          'shopName': shop.shopName,
          'fullName': shop.fullName,
          'email': shop.email,
          'address': shop.address,
          'phoneNumber': shop.phoneNumber,
          'uid': shop.uid,
          'userType': shop.userType.index,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'fullName': shop.fullName,
          'email': shop.email,
          'address': shop.address,
          'phoneNumber': shop.phoneNumber,
          'uid': shop.uid,
          'userType': shop.userType.index,
        });

        // Show successful registration message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration successful"),
            backgroundColor: Colors.green,
          ),
        );

        // Show the dialog after registration
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Registration Successful"),
            content: Text("Added to list shop!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );

        // Navigate to Shop's Page after successful registration
        Navigator.pushReplacementNamed(context, "/shopspage", arguments: shop);
      } else {
        // Show password mismatch error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Password Mismatch"),
            content: Text("Please make sure your passwords match."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle registration errors here
      print(e);
    }
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
          title: const Text("Register New Shop"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white70,
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _shopNameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.shop, color: Colors.black),
                          labelText: "Shop Name",
                          hintText: "Enter your shop name",
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.black),
                          labelText: "Full Name",
                          hintText: "Enter your full name",
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          labelText: "Email Address",
                          hintText: "Enter your email address",
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.add_location, color: Colors.black),
                          labelText: "Address",
                          hintText: "Enter your address",
                        ),
                        keyboardType: TextInputType.streetAddress,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone, color: Colors.black),
                          labelText: "Phone Number",
                          hintText: "Enter your phone number",
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          labelText: "Password",
                          hintText: "Enter your password",
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          labelText: "Confirm Password",
                          hintText: "Re-enter your password",
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Register button pressed
                          signUp(context);
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
