import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:FixZone/pages/registerion.dart';
import 'package:FixZone/User.dart' as MyUser;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> signIn(BuildContext context) async {
    try {
      await Firebase.initializeApp();
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (userSnapshot.exists) {
        if (MyUser.UserType.values[userSnapshot['userType']] ==
            MyUser.UserType.customer) {
          final user = MyUser.User(
            fullName: userSnapshot['fullName'],
            email: userSnapshot['email'],
            address: userSnapshot['address'],
            phoneNumber: userSnapshot['phoneNumber'],
            uid: userSnapshot['uid'],
            userType: MyUser.UserType.values[userSnapshot['userType']],
            imageUrl: userSnapshot['imageUrl'],
          );
          Navigator.pushReplacementNamed(context, "/Customerpage",
              arguments: user);
        } else if (MyUser.UserType.values[userSnapshot['userType']] ==
            MyUser.UserType.shop) {
          Navigator.pushReplacementNamed(
            context,
            "/shopspage",
          );
        }else if(MyUser.UserType.values[userSnapshot['userType']] ==
            MyUser.UserType.banned){
      String errorMessage = 'You have been banned by the admin, please contact us through 1191302364@student.mmu.edu.my';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
        }
         else {
          Navigator.pushReplacementNamed(context, "/homepage");
        }
      }
    } catch (e) {
      print("Failed to sign in: $e");
      String errorMessage = 'Invalid email or password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            return SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 35,
                        ),
                        Text(
                          "Log in",
                          style: TextStyle(
                              fontSize: 33,
                              fontFamily: "myfont",
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Image.asset(
                          "assets/icons/istockphoto-111.png",
                          width: 288,
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(66),
                          ),
                          width: 266,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _emailController,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              hintText: "Your Email:",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 23,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(66),
                          ),
                          width: 266,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _passwordController,
                            onChanged: (value) {},
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _togglePasswordVisibility();
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              icon: Icon(
                                Icons.lock,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 19,
                              ),
                              hintText: "Password:",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/ForgetPassword");
                          },
                          child: Text(
                            "Forgot password",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => signIn(context),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 0, 0, 0)),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.symmetric(
                              horizontal: 106,
                              vertical: 10,
                            )),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            )),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Registration(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
