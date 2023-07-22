import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Mixin.dart';
import '../invoicePage.dart';
import '../widgets/invoice.dart';

class RequestSummary extends StatefulWidget {
  final String userId;
  final String requestId;
  final String shopId;
  RequestSummary({
    required this.userId,
    required this.requestId,
    required this.shopId,
  });
  @override
  _RequestSummaryState createState() => _RequestSummaryState();
}

class _RequestSummaryState extends State<RequestSummary> with MyMixin {
  final supplierNameController = TextEditingController();
  final supplierAddressController = TextEditingController();
  final supplierPaymentInfoController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerAddressController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final vatController = TextEditingController();
  final unitPriceController = TextEditingController();

  String supplierName = '';
  String supplierAddress = '';
  String supplierPaymentInfo = '';
  String customerName = '';
  String customerAddress = '';

  List<InvoiceItem> invoiceItems = [];
  void createInvoice() async {
    CollectionReference invoicesCollection =
        FirebaseFirestore.instance.collection('invoices');

    List<Map<String, dynamic>> items;
    DocumentReference documentRef = invoicesCollection.doc();
    items = [];
    /*

        DocumentReference documentRef;
        

        if (querySnapshot.docs.isEmpty) {
          // Create a new document for the shop/customer and sender
          documentRef = invoicesCollection.doc();
          items = [];
        } else {
          // Get the existing document between the shop/customer and sender
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          documentRef = documentSnapshot.reference;

          // Get the current contents of the document
          items = List<Map<String, dynamic>>.from(
              (documentSnapshot.data() as Map<String, dynamic>?)?['invoiceItems'] ??
                  []);
        
        }*/

    for (var item in invoiceItems) {
      Map<String, dynamic> newItem = {
        'description': item.description,
        'quantity': item.quantity,
        'vat': item.vat,
        'unitPrice': item.unitPrice,
      };
      items.add(newItem);
    }
    Map<String, dynamic> data = {
      'invoiceId': widget.requestId,
      'shopId': widget.shopId,
      'customerId': widget.userId,
      'invoiceItems': items,
      'supplierName': supplierName,
      'supplierAddress': supplierAddress,
      'supplierPaymentInfo': supplierPaymentInfo,
      'customerName': customerName,
      'customerAddress': customerAddress,
    };

    await documentRef.set(data, SetOptions(merge: true));

    updateRequestStatus(widget.requestId, 'Review');
    Navigator.pushReplacementNamed(
      context,
      "/shopspage",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Invoice Generator'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TitleWidget(
              icon: Icons.picture_as_pdf,
              text: 'Generate Invoice',
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Supplier Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: supplierNameController,
                      decoration: InputDecoration(
                        labelText: 'Supplier Name',
                      ),
                    ),
                    TextFormField(
                      controller: supplierAddressController,
                      decoration: InputDecoration(
                        labelText: 'Supplier Address',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Customer Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: customerNameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                      ),
                    ),
                    TextFormField(
                      controller: customerAddressController,
                      decoration: InputDecoration(
                        labelText: 'Customer Address',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Invoice Items',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        columns: [
                          DataColumn(
                            label: Text('Description'),
                          ),
                          DataColumn(
                            label: Text('Quantity'),
                          ),
                          DataColumn(
                            label: Text('VAT'),
                          ),
                          DataColumn(
                            label: Text('Unit Price'),
                          ),
                          DataColumn(
                            label: Text('Total'),
                          ),
                        ],
                        rows: invoiceItems
                            .map(
                              (item) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(item.description),
                                  ),
                                  DataCell(
                                    Text(item.quantity.toString()),
                                  ),
                                  DataCell(
                                    Text(item.vat.toStringAsFixed(2)),
                                  ),
                                  DataCell(
                                    Text(item.unitPrice.toStringAsFixed(2)),
                                  ),
                                  DataCell(
                                    Text((item.quantity * item.unitPrice)
                                        .toStringAsFixed(2)),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Add Item'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: descriptionController,
                                        decoration: InputDecoration(
                                          labelText: 'Description',
                                        ),
                                      ),
                                      TextFormField(
                                        controller: quantityController,
                                        decoration: InputDecoration(
                                          labelText: 'Quantity',
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextFormField(
                                        controller: vatController,
                                        decoration: InputDecoration(
                                          labelText: 'VAT',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                      TextFormField(
                                        controller: unitPriceController,
                                        decoration: InputDecoration(
                                          labelText: 'Unit Price',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: _addItem,
                                      child: Text('Add'),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .black), // Set the desired button color
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .black), // Set the desired button color
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Add Item'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.black), // Set the desired button color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateInvoice,
              child: Text('Generate Invoice'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.black), // Set the desired button color
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    setState(() {
      invoiceItems.add(
        InvoiceItem(
          description: descriptionController.text,
          quantity: int.parse(quantityController.text),
          vat: double.parse(vatController.text),
          unitPrice: double.parse(unitPriceController.text),
        ),
      );
      descriptionController.clear();
      quantityController.clear();
      vatController.clear();
      unitPriceController.clear();
    });
    Navigator.pop(context);
  }

  void _generateInvoice() {
    setState(() {
      supplierName = supplierNameController.text;
      supplierAddress = supplierAddressController.text;
      supplierPaymentInfo = supplierPaymentInfoController.text;
      customerName = customerNameController.text;
      customerAddress = customerAddressController.text;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePage(
            supplierName: supplierName,
            supplierAddress: supplierAddress,
            supplierPaymentInfo: supplierPaymentInfo,
            customerName: customerName,
            customerAddress: customerAddress,
            invoiceItems: invoiceItems,
            onPressed: createInvoice),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  const TitleWidget({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 32,
          color: Colors.black,
        ),
        SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
