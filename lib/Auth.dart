// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:FixZone/pages/homepage.dart';
import 'package:FixZone/pages/login.dart';
import 'package:FixZone/pages/customers_page.dart';
import 'package:FixZone/pages/shops_page.dart';
import 'package:FixZone/User.dart' as MyUser;

class Auth extends StatelessWidget {
  const Auth({Key? key, required MyUser.User user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for the auth state to resolve
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // User is authenticated, show the corresponding page based on user role
            final MyUser.User? user = snapshot.data as MyUser.User?;

            if (user != null) {
              if (user.userType == MyUser.UserType.admin) {
                return HomePage(); // Show home page for admin user
              } else if (user.userType == MyUser.UserType.customer) {
                return CustomerPage(
                  user: user,
                ); // Show customer page for regular user
              } else if (user.userType == MyUser.UserType.shop) {
                return ShopsPage(); // Show shop page for shop user
              }
            }
          }

          // User is not authenticated or no user data available, show the login page
          return Login();
        },
      ),
    );
  }
}
