// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'VSR.dart';

class CustomerRequestPageThree extends StatelessWidget {
  const CustomerRequestPageThree({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getOrderList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.size == 0) {
                    return Center(child: Text('No requests available'));
                  } else {
                    final orders = snapshot.data!.docs.map((doc) {
                      final data = doc.data();
                      final shopName = data['shopName'] as String? ?? '';
                      final orderId = doc.id;
                      final timestamp = data['dateTime'] as Timestamp?;
                      final dateTime = timestamp != null
                          ? DateFormat('yyyy-MM-dd hh:mm a')
                              .format(timestamp.toDate())
                          : '';
                      final status = data['status'] as String? ?? '';
                      final shopId = data['shopId'] as String? ??
                          ''; // Get the shopId from the data map
                      final phoneNumberShop =
                          data['phoneNumberShop'] as String? ??
                              ''; // Add this line
                      final shopImage =
                          data['shopImage'] as String? ?? ''; // Add this line

                      return Order(
                        shopName: shopName,
                        orderId: orderId,
                        dateTime: dateTime,
                        status: status,
                        shopId: shopId,
                        phoneNumberShop: phoneNumberShop,
                        shopImage: shopImage, // Add this line
                      );
                    }).toList();

                    return Column(
                      children: orders.map((order) {
                        return OrderCard(
                          order: order,
                          onCancel: () => showCancelDialog(context, order),
                          shopId: order
                              .shopId, // Pass the shopId to the OrderCard widget
                          phoneNumberShop: order.phoneNumberShop,
                          // Pass the phoneNumberShop
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCancel;
  final String phoneNumberShop;

  const OrderCard({
    required this.order,
    required this.onCancel,
    required this.phoneNumberShop, required String shopId,
  });

  Future<bool> checkOrderRating(String orderId) async {
    final CollectionReference<Map<String, dynamic>> reviewsCollection =
        FirebaseFirestore.instance.collection('reviews');

    final querySnapshot = await reviewsCollection
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty &&
        querySnapshot.docs.first.data()['status'] == 'rated';
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'Review':
        statusColor = Colors.cyan;
        statusIcon = Icons.check_circle;
        break;
      case 'Accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      case 'Canceled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    bool canCancel = order.status != 'Accepted' &&
        order.status != 'Completed' &&
        order.status != 'Canceled';
        

    if (order.status == 'Accepted' ) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SummaryRequestPage(order.orderId)),
          );
        },
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: order.shopImage.isEmpty ? Colors.grey : null,
                  ),
                  child: order.shopImage.isEmpty
                      ? Icon(Icons.image, size: 80, color: Colors.white)
                      : Image.network(
                          order.shopImage,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shopName,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Order ID: ${order.orderId}',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        order.dateTime,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 18.0,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            order.status,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () {
                        final phoneNumber = order.phoneNumberShop;
                        launch('tel:$phoneNumber');
                      },
                    ),
                    SizedBox(height: 8.0),
                    
                    if (canCancel)
                      ElevatedButton(
                        onPressed: onCancel,
                        child: Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}


class Order {
  final String shopName;
  final String orderId;
  final String dateTime;
  String status;
  final String shopId;
  final String phoneNumberShop; // Add this field
  final String shopImage; // Add this field

  Order({
    required this.shopName,
    required this.orderId,
    required this.dateTime,
    required this.status,
    required this.shopId,
    required this.phoneNumberShop,
    required this.shopImage, // Initialize this field in the constructor
  });
}

Stream<QuerySnapshot<Map<String, dynamic>>> getOrderList(
    {bool ascending = true}) {

  final CollectionReference<Map<String, dynamic>> ordersCollection =
      FirebaseFirestore.instance.collection('request');
          final user = FirebaseAuth.instance.currentUser?.uid;
print('this is a not for the $user');
  return ordersCollection
      .where('customerId', isEqualTo: user)
      .orderBy('dateTime', descending: !ascending)
      .snapshots();
}

void cancelOrder(Order order) {
  // Update the status of the order to "Cancel"
  order.status = "Canceled";

  // Upload the updated order status to the Firestore collection
  FirebaseFirestore.instance
      .collection('request')
      .doc(order.orderId)
      .update({'status': 'Canceled'}).then((value) {
    // Order status updated successfully
  }).catchError((error) {
    // Error occurred while updating order status
  });
}

void showCancelDialog(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Cancellation'),
        content: Text('Are you sure you want to cancel this request?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              cancelOrder(order);
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
        ],
      );
    },
  );
  
}
