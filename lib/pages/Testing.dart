import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SummaryRequestPage extends StatefulWidget {
  SummaryRequestPage();

  @override
  _SummaryRequestPageState createState() => _SummaryRequestPageState();
}

class _SummaryRequestPageState extends State<SummaryRequestPage> {
  late Future<List<DocumentSnapshot>> _requestInfoFuture;

  @override
  void initState() {
    super.initState();
    _requestInfoFuture = _getRequestData();
  }

  Future<List<DocumentSnapshot>> _getRequestData() async {
    final user = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('request')
        .where('customerId', isEqualTo: user!.uid)
        .get();

    return querySnapshot.docs;
  }

  String formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    final formattedDateTime = dateTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)
        : '';
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Summary Request'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _requestInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final requestInfoList = snapshot.data!;

            return ListView.builder(
              itemCount: requestInfoList.length,
              itemBuilder: (context, index) {
                final requestInfo = requestInfoList[index];

                return SummaryRequestItem(request: requestInfo);
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class SummaryRequestItem extends StatelessWidget {
  final DocumentSnapshot request;

  SummaryRequestItem({required this.request});

  String formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    final formattedDateTime = dateTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)
        : '';
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final requestData = request.data() as Map<String, dynamic>;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHOP NAME: ${requestData['shopName'] ?? 'Unavailable'}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text('Order ID: ${requestData['id']}'),
          Text('Date: ${formatDateTime(requestData['dateTime'])}'),
          SizedBox(height: 16),
          Text('Status: ${requestData['status']}'),
          SizedBox(height: 24),
          Text(
            'CUSTOMER DETAILS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Name: ${requestData['customerName']}'),
          SizedBox(height: 8),
          Text('Address: ${requestData['customerAddress']}'),
          SizedBox(height: 24),
          Text(
            'SUPPLIER DETAILS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Name: ${requestData['supplierName']}'),
          SizedBox(height: 8),
          Text('Address: ${requestData['supplierAddress']}'),
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
                label: Text('Price'),
              ),
              DataColumn(
                label: Text('VAT'),
              ),
            ],
            rows: (requestData['invoiceItems'] as List<dynamic>).map((item) {
              final quantity = item['quantity'] as int;
              final unitPrice = item['unitPrice'] as double;
              final vat = item['vat'] as double;
              return DataRow(
                cells: [
                  DataCell(Text(item['description'])),
                  DataCell(Text(quantity.toString())),
                  DataCell(Text(unitPrice.toString())),
                  DataCell(Text(vat.toString())),
                ],
              );
            }).toList(),
          ),
          SizedBox(height: 24),
          Text(
            'Total: ${requestData['total'].toStringAsFixed(2)} RM',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                      // Handle cash payment selection
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: null,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Cash',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // Handle card payment selection
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: null,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

}
