import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Summary Requests',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ViewSummaryRequest(),
    );
  }
}

class ViewSummaryRequest extends StatefulWidget {
  @override
  _ViewSummaryRequestState createState() => _ViewSummaryRequestState();
}

class _ViewSummaryRequestState extends State<ViewSummaryRequest> {
  bool cashSelected = true;
  bool cardSelected = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> getOrderList(
      {bool ascending = true}) {
    final CollectionReference<Map<String, dynamic>> ordersCollection =
        FirebaseFirestore.instance.collection('request');

    return ordersCollection
        .orderBy('dateTime', descending: !ascending)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Summary Request'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getOrderList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final requests = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var request in requests)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.only(bottom: 16.0),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SHOP NAME : ${request['shopName']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Order ID:      XXXXXXXXXXX'),
                              Text(
                                  'Date: ${formatDateTime(request['dateTime'])}'),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('Status:        ${request['status']}'),
                          SizedBox(height: 24),
                          Text(
                            'CUSTOMER DETAILS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Name:            XXXXXXXXXXX'),
                          SizedBox(height: 8),
                          Text('Address:         XXXXXXXXXXX'),
                          SizedBox(height: 24),
                          Text(
                            'SUPPLIER DETAILS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Name:            XXXXXXXXXXX'),
                          SizedBox(height: 8),
                          Text('Address:         XXXXXXXXXXX'),
                          SizedBox(height: 24),
                          Text(
                            'ITEMS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          DataTable(
                            columns: [
                              DataColumn(
                                label: Text('Description'),
                              ),
                              DataColumn(
                                label: Text('Qty'),
                              ),
                              DataColumn(
                                label: Text('Unit Price'),
                              ),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Text('XXXXXXXXXXXX')),
                                DataCell(Text('XX')),
                                DataCell(Text('XXXXXXXX')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('XXXXXXXXXXXX')),
                                DataCell(Text('XX')),
                                DataCell(Text('XXXXXXXX')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('XXXXXXXXXXXX')),
                                DataCell(Text('XX')),
                                DataCell(Text('XXXXXXXX')),
                              ]),
                            ],
                          ),
                          SizedBox(height: 24),
                          Text('VAT:   XXXXXXXX'),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PAYMENT METHOD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        cashSelected = true;
                                        cardSelected = false;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: cashSelected
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: cashSelected
                                              ? Center(
                                                  child: Icon(Icons.check,
                                                      size: 16))
                                              : null,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Cash',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        cashSelected = false;
                                        cardSelected = true;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: cardSelected
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: cardSelected
                                              ? Center(
                                                  child: Icon(Icons.check,
                                                      size: 16))
                                              : null,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Card',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ACTIONS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle accepted action
                                    },
                                    child: Text('Accepted'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle canceled action
                                    },
                                    child: Text('Canceled'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    final formattedDateTime = dateTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)
        : '';
    return formattedDateTime;
  }
}
