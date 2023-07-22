import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomerFeedbackPage extends StatelessWidget {
  final String shopId;

  const CustomerFeedbackPage({Key? key, required this.shopId}) : super(key: key);

  Future<String> fetchCurrentUserShopId() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return userSnapshot['uid'];
  }

  Future<List<Review>> fetchReviews() async {
  String currentUserShopId = await fetchCurrentUserShopId();
  print('Current User Shop ID: $currentUserShopId');
  print('Shop ID Parameter: $shopId');

  String modifiedShopId = shopId; // New variable to hold the modified shopId

  if (modifiedShopId.isEmpty && currentUserShopId.isNotEmpty) {
    modifiedShopId = currentUserShopId;
    print('Using currentUserShopId as Shop ID Parameter: $modifiedShopId');
  }

  QuerySnapshot snapshot;

  if (currentUserShopId.isNotEmpty && currentUserShopId == modifiedShopId) {
    // Current user is a shop owner and matches the shopId parameter
    print('Fetching reviews for shop owner...');
    snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('shopId', isEqualTo: currentUserShopId)
        .get();
  } else {
    // Current user is a customer or shop owner for a different shop
    print('Fetching reviews for customer/shop owner of a different shop...');
    snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('shopId', isEqualTo: modifiedShopId)
        .get();
  }

  List<Review> reviews = [];

  snapshot.docs.forEach((doc) {
    Review review = Review(
      fullName: doc['fullName'],
      rating: doc['rating'].toDouble(),
      date: doc['date'].toDate(),
      feedback: doc['feedback'],
      shopId: doc['shopId'],
    );

    reviews.add(review);
  });

  return reviews;
}






  double calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;

    double totalRating = 0;
    for (var review in reviews) {
      totalRating += review.rating;
    }

    return totalRating / reviews.length;
  }

  Widget buildRatingBar(double averageRating) {
    final int starCount = 5;
    final double rating = averageRating;
    final Widget halfStar = Icon(Icons.star_half, color: Colors.yellow);
    final Widget fullStar = Icon(Icons.star, color: Colors.yellow);
    final Widget emptyStar = Icon(Icons.star_border, color: Colors.yellow);

    List<Widget> starBar = [];

    for (int i = 1; i <= starCount; i++) {
      if (rating >= i) {
        starBar.add(fullStar);
      } else if (rating > i - 1 && rating < i) {
        starBar.add(halfStar);
      } else {
        starBar.add(emptyStar);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: starBar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Reviews'),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      backgroundColor: Colors.white70,
      body: FutureBuilder<List<Review>>(
        future: fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final reviews = snapshot.data!;
            final totalReviews = reviews.length;
            final averageRating = calculateAverageRating(reviews);

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '($totalReviews) reviews',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: buildRatingBar(averageRating),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ReviewCard(review: review);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// ReviewCard class
class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    review.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    '${DateFormat.yMMMMd().format(review.date)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 24.0,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    review.rating.toString(),
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(review.feedback),
            ],
          ),
        ),
      ),
    );
  }
}

// Review model class
class Review {
  final String fullName;
  final double rating;
  final DateTime date;
  final String feedback;
  final String shopId;

  Review({
    required this.fullName,
    required this.rating,
    required this.date,
    required this.feedback,
    required this.shopId,
  });
}

// Main function
void main() {
  Intl.defaultLocale = 'en_US';
  runApp(MaterialApp(home: CustomerFeedbackPage(shopId: '',)));
}
