// ignore_for_file: must_be_immutable

import 'package:FixZone/pages/customers_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Feedbackandrating extends StatefulWidget {
  Map<String, dynamic>? routeArguments; // Add routeArguments property
  
  Feedbackandrating({Key? key, this.routeArguments}) : super(key: key);

  @override
  _FeedbackandratingState createState() => _FeedbackandratingState();
}

class _FeedbackandratingState extends State<Feedbackandrating> {
  double _rating = 0;
  String _feedbackComment = "";
  String _fullName = "";
  late User _currentUser;
  String _shopName = ""; // Add shopName variable

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    initializeFirebase();

    // Retrieve routeArguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeArguments = ModalRoute.of(context)?.settings.arguments;
      if (routeArguments != null) {
        setState(() {
          widget.routeArguments = routeArguments as Map<String, dynamic>;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
        await fetchUserFullName(user.uid);
      }
    });
  }

  Future<void> fetchUserFullName(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    setState(() {
      _fullName = userSnapshot['fullName'];
    });
  }

  Future<String?> fetchShopName(String shopId) async {
    DocumentSnapshot shopSnapshot =
        await FirebaseFirestore.instance.collection('Shops').doc(shopId).get();

    return shopSnapshot['shopName'];
  }

  Future<void> saveRatingAndFeedback(String? shopId, String? orderId) async {
    if (shopId == null) {
      // Handle the case when shopId is null
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Shop ID is null.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    try {
      
      CollectionReference reviewsCollection =
          FirebaseFirestore.instance.collection('reviews');

      // Save rating in the "Shops" collection
      

      // Save feedback, fullName, rating, and date in the "reviews" collection
      await reviewsCollection.add({
        'feedback': _feedbackComment,
        'fullName': _fullName,
        'shopName': _shopName,
        'orderId':orderId,
        'status':'rated',
        'rating': _rating,
        'shopId': shopId,
        'userId': _currentUser.uid,
        'date': DateTime.now(),
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Feedback and rating recorded successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CustomerPage()),
        (route) => false,
      );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to record feedback and rating.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text("Feedback and Rating"),
      ),
      backgroundColor: Colors.blueGrey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          SizedBox(height: 20),
          Container(
  margin: EdgeInsets.symmetric(horizontal: 20),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black,
        width: 1.0,
      ),
    ),
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextField(
          focusNode: _focusNode,
          maxLines: 10,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: "Enter your feedback comment",
          ),
          onChanged: (value) {
            setState(() {
              _feedbackComment = value;
            });
          },
        ),
      ),
    ),
  ),
),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
  final shopId = widget.routeArguments?['shopId'] as String?;
  final orderId = widget.routeArguments?['orderId'] as String?;

  if (shopId != null) {
    final shopName = await fetchShopName(shopId);

    if (shopName != null) {
      setState(() {
        _shopName = shopName;
      });
      await saveRatingAndFeedback(shopId, orderId);
      
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch shop name.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Shop ID is null.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
},

            style: ElevatedButton.styleFrom(
              primary: Colors.black,
            ),
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }
}
