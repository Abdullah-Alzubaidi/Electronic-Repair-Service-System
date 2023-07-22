import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Review {
  final String fullName;
  final double rating;
  final String date;
  final String comment;
  final String shopName;
  final String imageUrl;

  Review({
    required this.fullName,
    required this.rating,
    required this.date,
    required this.comment,
    required this.shopName,
    required this.imageUrl,
  });
}

class CustomerMyReview extends StatelessWidget {
  CustomerMyReview({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text("My Reviews"),
      ),
      backgroundColor: Colors.white70,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            final currentUserData = snapshot.data!;
            final currentUserImageUrl = currentUserData['imageUrl'];

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final reviews = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullName = data['fullName'] ?? 'Unknown';
                  final rating = data['rating']?.toDouble() ?? 0.0;
                  final timestamp = data['date'] as Timestamp?;
                  final date = timestamp != null
                      ? DateFormat("MMM d, yyyy").format(timestamp.toDate())
                      : 'Unknown';
                  final comment = data['feedback'] ?? '';
                  final shopName = data['shopName'] ?? '';
                  final imageUrl = data['imageUrl'] ?? '';

                  return Review(
                    fullName: fullName,
                    rating: rating,
                    date: date,
                    comment: comment,
                    shopName: shopName,
                    imageUrl: imageUrl,
                  );
                }).toList();

                if (reviews.isEmpty) {
                  return Center(
                    child: Text('You have not made any reviews.'),
                  );
                }

                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];

                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        currentUserImageUrl.isNotEmpty
                                            ? NetworkImage(currentUserImageUrl)
                                            : null,
                                    child: currentUserImageUrl.isEmpty
                                        ? Icon(
                                            Icons.image,
                                            size: 80,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.fullName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.yellow),
                                          SizedBox(width: 4.0),
                                          Text(review.rating.toString()),
                                          SizedBox(width: 8.0),
                                          Text(review.date),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                review.comment,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'from : ${review.shopName}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return Center(
            child: Text('You are not logged in.'),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CustomerMyReview(),
  ));
}
