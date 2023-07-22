import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintCard {
  final String fullName;
  final String phoneNumber;
  final String shopName;
  final String description;

  ComplaintCard({
    required this.fullName,
    required this.phoneNumber,
    required this.shopName,
    required this.description,
  });

  factory ComplaintCard.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    return ComplaintCard(
      fullName: data?['fullName'] ?? '',
      phoneNumber: data?['phoneNumber'] ?? '',
      shopName: data?['shopName'] ?? '',
      description: data?['description'] ?? '',
    );
  }
}

class ComplaintListPage extends StatelessWidget {
  final CollectionReference complaintsCollection =
      FirebaseFirestore.instance.collection('complaints');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Complaint List'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: complaintsCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<ComplaintCard> complaintCards = snapshot.data!.docs
              .map((DocumentSnapshot document) =>
                  ComplaintCard.fromDocument(document))
              .toList();

          return ListView.builder(
            itemCount: complaintCards.length,
            itemBuilder: (context, index) {
              final complaint = complaintCards[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Customer: ${complaint.fullName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.black, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Phone : ${complaint.phoneNumber}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.store, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Complaint on: ${complaint.shopName}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Divider(color: Colors.grey[400]),
                    SizedBox(height: 20),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      complaint.description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ComplaintListPage(),
  ));
}
