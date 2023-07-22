// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Mixin.dart';

class AcceptRequest extends StatefulWidget {
  const AcceptRequest({Key? key}) : super(key: key);

  @override
  _AcceptRequestState createState() => _AcceptRequestState();
}

class _AcceptRequestState extends State<AcceptRequest> with MyMixin {
  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection('request');
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  /*Future<void> completeRequest(String requestId) {
    return requestCollection.doc(requestId).update({'status': 'Completed'});
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Accept Request"),
      ),
      backgroundColor:  Colors.white70,
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: requestCollection
              .where('status', isEqualTo: 'Accepted')
              .where('shopId', isEqualTo: _currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No accept requests available.'),
              );
            }

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final document = snapshot.data!.docs[index];
                    final data = document.data() as Map<String, dynamic>;

                    final fullName = data['fullName'].toString();
                    final description = data['description'].toString();
                    final address = data['address'].toString();
                    final typeOfServices = data['services'].toString();
                    final paymentmethod=data['payment'].toString();
                    final phoneNumber = data['phoneNumber'].toString();
                    final feeCharge = data['total'] != null
                        ? data['total'].toDouble()
                        : 0.0;
                    final status = data['status'].toString();
                    final timestamp = data['dateTime'] as Timestamp?;
                    final dateTime = timestamp != null
                        ? DateFormat('yyyy-MM-dd hh:mm a')
                            .format(timestamp.toDate())
                        : '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        child: GestureDetector(
                          onTap: () {
                            // Add your toggle details functionality here
                          },
                          child: Container(
                            height: 440.0,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.list_alt_rounded),
                                    const SizedBox(width: 15.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('$status'),
                                        Text(
                                          'Order Date: $dateTime',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Payment: $paymentmethod',
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    'Fee Charge: ${feeCharge.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                const Divider(),
                                const SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Customer Name: $fullName'),
                                          Text('Address: $address'),
                                          Text('Type of service: $typeOfServices'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                GestureDetector(
                                  onTap: () {
                                    // Add your toggle details functionality here
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Request Details:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                const Text('Details:'),
                                const SizedBox(height: 8.0),
                                Text(description),
                                const SizedBox(height: 16.0),
                                GestureDetector(
                                  onTap: () {
                                    // Add your toggle details functionality here
                                  },
                                  child: Text(
                                    'Hide Details',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  height: 2.0,
                                  color: Colors.black,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Customer Name: $fullName',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            launch('tel:$phoneNumber');
                                          },
                                          child: Icon(
                                            Icons.call,
                                            color: Colors.green,
                                            size: 32.0,
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        GestureDetector(
                                          onTap: () {
                                            launch(
                                                'https://maps.google.com?q=$address');
                                          },
                                          child: Icon(
                                            Icons.map,
                                            color: Colors.green,
                                            size: 32.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3.0),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                            updateRequestStatus(document.id, 'Completed');

                                    },
                                    child: Text('Complete'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 100.0),
              ],
            );
          },
        ),
      ),
    );
  }
}
