// ignore_for_file: unused_import, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:FixZone/pages/ChatList.dart';
import 'package:FixZone/pages/ChatListShop.dart';
import 'package:FixZone/pages/ShopInfo.dart';
import 'package:FixZone/pages/VSR.dart';
import 'package:FixZone/pages/change%20password.dart';
import 'package:FixZone/pages/customers_page.dart' ;
import 'package:FixZone/pages/feedback%20and%20rating.dart';
import 'package:FixZone/pages/ForgetPassword.dart';
import 'package:FixZone/pages/homepage.dart';
import 'package:FixZone/pages/profile.dart';
import 'package:FixZone/pages/ShopRegister.dart';
import 'package:FixZone/pages/registerion.dart';
import 'package:FixZone/pages/shops_page.dart';
import 'package:FixZone/pages/sign%20up.dart';
import 'package:FixZone/pages/login.dart';
import 'package:FixZone/pages/submit%20request.dart';
import 'package:FixZone/pages/welcome.dart';
import 'package:FixZone/pages/CustomerListShop.dart';
import 'package:FixZone/pages/test.dart';
import 'package:FixZone/pages/Shop Profile.dart';
import 'package:FixZone/pages/CustomerFeedbackPage.dart';
import 'package:FixZone/pages/ShopRequestPage.dart';
import 'package:FixZone/pages/CustomerRequestPage.dart';
import 'package:FixZone/pages/ResetPassword.dart';
import 'package:FixZone/pages/CreateNewPassword.dart';
import 'package:FixZone/pages/AdminListShop.dart';
import 'package:FixZone/pages/SuggestFeatures.dart';
import 'package:FixZone/pages/CustomerMyReview.dart';
import 'package:FixZone/pages/AcceptRequest.dart';
import 'package:FixZone/pages/RequestSummary.dart';
import 'package:FixZone/Auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:FixZone/pages/AdminListCustomers.dart';
import 'package:FixZone/pages/ChatPage.dart';
import 'package:FixZone/pages/ChatPageShop.dart';
import 'package:FixZone/pages/PaymentScreen.dart';
import 'package:FixZone/pages/history.dart';
import 'package:FixZone/pages/customer_suggestion.dart';
import 'package:FixZone/pages/complaint.dart';
import 'package:FixZone/pages/view_complaint.dart';
import 'package:FixZone/widgets/invoice.dart';
import 'User.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
      User? initialUser = await getUserData();

    runApp( MyApp(initialUser: initialUser));
  }
  

Future<User?> getUserData() async {

  return null; // Return null if the user is not authenticated
}


  class MyApp extends StatelessWidget {
      final User? initialUser; // Add a nullable User object as an argument

    const MyApp({Key? key, this.initialUser}) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:   initialUser != null ? Auth(user: initialUser!) : Welcome(),
        initialRoute: "/welcome",
        routes: {
          "/welcome" : (context) => const Welcome(),
          "/register" : (context) =>  Registration(),
          "/login" : (context) => const Login(),
          "/ForgetPassword":(context) => const ForgetPassword(),
          "/CreateAshop": (context) => const RegisterShop(),
          "/profile" : (context)=> const Profile(),
          "/Change Password": (context)=> const Changepassword(),
          "/homepage" : (context) =>  HomePage(),
          "/feedback" :(context) =>  Feedbackandrating(),
          "/Customerpage": (context) =>  CustomerPage(user: initialUser),
          "/shopspage" :(context) =>  ShopsPage(),
          "/submit request":(context)=>  Submit(shopId: '',typeServices: '', shopName: '', phoneNumberShop: '', shopImage: '', services: const [],),
          "/CustomerListShop":(context)=> CustomerListShop(),
          "/HotelListScreen":(context)=> HotelListScreen(),
          "/ShopProfile":(context)=> ShopProfile(shopId: '',),
          "/CustomerFeedbackPage":(context)=> CustomerFeedbackPage(shopId: '',),
          "/ShopRequestPage":(context) => ShopRequestPage(),
          "/CustomerRequestPage":(context)=> MyTabBar(),
          "/AdminListCustomers": (context) => AdminListCustomers(),
          "/ResetPassword": (context) => ResetPassword(),
          "/CreateNewPassword": (context) => CreateNewPassword(),
          "/adminListShop": (context) => AdminListShop(),
          "/SuggestFeatures": (context) => SuggestFeatures(),
          "/CustomerMyReview": (context) => CustomerMyReview(),
          "/AcceptRequest": (context) => AcceptRequest(),
          "/InvoicePage": (context) => InvoicePage(customerAddress: '', customerName: '', invoiceItems: const [], onPressed: () {  }, supplierAddress: '', supplierName: '', supplierPaymentInfo: '',),
          "/ChatPage": (context) => ChatPage(shopId: '', userId: '',),
          "/ChatList": (context) => ChatList(),
          "/ChatListShop": (context) => ChatListShop(),
          "/PaymentScreen": (context) => SandboxPaymentTextingApp(),
          "/ShopInfo": (context) => ShopInfo( shopId: '',),
          "/HistoryPage": (context) => HistoryPage(),
          "/FeatureListPage": (context) => FeatureListPage(),
          "/ComplaintCardPage": (context) => ComplaintCardPage(),
          "/ComplaintListPage": (context) => ComplaintListPage(),
          
          
          
          
          
        },
      );
    }
  }