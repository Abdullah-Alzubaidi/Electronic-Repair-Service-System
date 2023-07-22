import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FixZone/Mixin.dart';
import 'package:intl/intl.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import 'PaymentScreen.dart';

class SummaryRequestPage extends StatefulWidget {
  final String invoiceId;
  SummaryRequestPage(this.invoiceId);

  @override
  _SummaryRequestPageState createState() => _SummaryRequestPageState();
}

class _SummaryRequestPageState extends State<SummaryRequestPage> with MyMixin {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _invoiceFuture;
  bool cashSelected = true;
  bool cardSelected = false;
  bool isReview = true;

  @override
  void initState() {
    super.initState();
    _invoiceFuture = _getInvoiceDocument();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getInvoiceDocument() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('invoices')
        .where('invoiceId', isEqualTo: widget.invoiceId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    // Handle the case when the invoice document is not found
    throw Exception('Invoice document not found.');
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getInvoiceData(
      dynamic invoiceData) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('request')
        .doc(invoiceData)
        .get();
    if (querySnapshot.exists) {
      return querySnapshot;
    }
    // Handle the case when the invoice document is not found
    throw Exception('Invoice document not found.');
  }

  String formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    final formattedDateTime = dateTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)
        : '';
    return formattedDateTime;
  }

  Future<void> addFieldToDocument(String paymentMethod, double total) async {
    final DocumentReference<Map<String, dynamic>> documentRef =
        FirebaseFirestore.instance.collection('request').doc(widget.invoiceId);

    await documentRef.update({
      'payment': paymentMethod,
      'total': total,
    });
  }

  Future<void> _saveAndPrintPdf(double total) async {
    final pdf = pw.Document();

    // Retrieve the summary request data
    final invoiceSnapshot = await _invoiceFuture;
    final invoiceData = invoiceSnapshot.data()!;
    final invoiceItems = invoiceData['invoiceItems'] as List<dynamic>;
    final requestInfo = await _getInvoiceData(invoiceData['invoiceId']);
    final requestInfoData = requestInfo.data()!;

    // Create the PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SHOP NAME: ${requestInfoData['shopName']}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Order ID: ${invoiceData['invoiceId']}'),
                pw.Text(
                  'Date: ${formatDateTime(requestInfoData['dateTime'])}',
                ),
                pw.SizedBox(height: 16),
                pw.Text('Status: ${requestInfoData['status']}'),
                pw.SizedBox(height: 24),
                pw.Text(
                  'CUSTOMER DETAILS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Name: ${invoiceData['customerName']}'),
                pw.SizedBox(height: 8),
                pw.Text('Address: ${invoiceData['customerAddress']}'),
                pw.SizedBox(height: 24),
                pw.Text(
                  'SUPPLIER DETAILS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Name: ${invoiceData['supplierName']}'),
                pw.SizedBox(height: 8),
                pw.Text('Address: ${invoiceData['supplierAddress']}'),
                pw.SizedBox(height: 24),
                pw.Text(
                  'ITEMS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table(
                  columnWidths: {
                    0: pw.IntrinsicColumnWidth(),
                    1: pw.IntrinsicColumnWidth(),
                    2: pw.IntrinsicColumnWidth(),
                    3: pw.IntrinsicColumnWidth(),
                  },
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Description'),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Qty'),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Price'),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('VAT'),
                        ),
                      ],
                    ),
                    ...invoiceItems.map(
                      (item) {
                        final quantity = item['quantity'] as int;
                        final unitPrice = item['unitPrice'] is int
                            ? (item['unitPrice'] as int).toDouble()
                            : item['unitPrice'] as double;

                        final vat = item['vat'] is int
                            ? (item['vat'] as int).toDouble()
                            : item['vat'] as double;

                        return pw.TableRow(
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text(item['description']),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text(quantity.toString()),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text(unitPrice.toString()),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text(vat.toString()),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text('total: ${total.toStringAsFixed(2)} RM'),
              ],
            ),
          );
        },
      ),
    );

    // Get the application directory path
    final appDir = await getApplicationDocumentsDirectory();
    final appDirPath = appDir.path;

    // Create the file path for the PDF file
    final filePath = '$appDirPath/summary_request.pdf';

    // Save the PDF file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Print the PDF file
    await Printing.layoutPdf(
      onLayout: (format) => file.readAsBytes(),
    );

    // Show a confirmation dialog after the PDF is printed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PDF Printed'),
        content:
            Text('The summary request has been printed as a PDF document.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Summary Request'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _invoiceFuture,
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

          final invoiceData = snapshot.data!.data();
          final invoiceItems = invoiceData!['invoiceItems'] as List<dynamic>;
          final requestInfo = _getInvoiceData(invoiceData['invoiceId']);
          double total = 0.0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: requestInfo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final requestInfoData = snapshot.data!.data();
                      isReview = 'Review' == requestInfoData!['status'];

                      return Container(
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
                              'SHOP NAME: ${requestInfoData['shopName']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text('Order ID: ${invoiceData['invoiceId']}'),
                            Text(
                                'Date: ${formatDateTime(requestInfoData['dateTime'])}'),
                            SizedBox(height: 16),
                            Text('Status: ${requestInfoData['status']}'),
                            SizedBox(height: 24),
                            Text(
                              'CUSTOMER DETAILS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Name: ${invoiceData['customerName']}'),
                            SizedBox(height: 8),
                            Text('Address: ${invoiceData['customerAddress']}'),
                            SizedBox(height: 24),
                            Text(
                              'SUPPLIER DETAILS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Name: ${invoiceData['supplierName']}'),
                            SizedBox(height: 8),
                            Text('Address: ${invoiceData['supplierAddress']}'),
                            SizedBox(height: 24),
                            Text(
                              'ITEMS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
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
                                rows: invoiceItems.map<DataRow>((item) {
                                  final quantity = item['quantity'] as int;
                                  final unitPrice = item['unitPrice'] is int
                                      ? (item['unitPrice'] as int).toDouble()
                                      : item['unitPrice'] as double;

                                  final vat = item['vat'] is int
                                      ? (item['vat'] as int).toDouble()
                                      : item['vat'] as double;

                                  final itemTotal = (quantity * unitPrice) *
                                      (1 + (vat / 100));
                                  total += itemTotal; // Add to the total price

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(item['description'].toString())),
                                      DataCell(Text(quantity.toString())),
                                      DataCell(Text(unitPrice.toString())),
                                      DataCell(Text(vat.toString())),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text('total: ${total.toStringAsFixed(2)} RM'),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (isReview == true)
                                  Text(
                                    'PAYMENT METHOD',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (isReview == true)
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
                            if (isReview == true)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          updateRequestStatus(
                                              widget.invoiceId, 'Accepted');
                                          if (cashSelected == true &&
                                              cardSelected == false) {
                                            addFieldToDocument('Cash', total);
                                            setState(() {});
                                          } else {
                                            addFieldToDocument('Card', total);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SandboxPaymentTextingApp(),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text('Accepted'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          updateRequestStatus(
                                              widget.invoiceId, 'Canceled');
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
                            SizedBox(height: 16),
                            if (!isReview)
                              ElevatedButton(
                                onPressed: () {
                                  _saveAndPrintPdf(total);
                                },
                                child: Text('Print as PDF'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
