import 'package:flutter/material.dart';

import '../invoicePage.dart';

class InvoicePage extends StatelessWidget {
  final String supplierName;
  final String supplierAddress;
  final String supplierPaymentInfo;
  final String customerName;
  final String customerAddress;
  final List<InvoiceItem> invoiceItems;
  final VoidCallback onPressed;

  const InvoicePage({
    required this.supplierName,
    required this.supplierAddress,
    required this.supplierPaymentInfo,
    required this.customerName,
    required this.customerAddress,
    required this.invoiceItems,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Invoice'),
        ),
        body: SingleChildScrollView( // Wrap the content with SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Supplier Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(supplierName),
                        const SizedBox(height: 8),
                        Text(
                          'Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(supplierAddress),
                        const SizedBox(height: 8),
                        Text(
                          'Payment Info',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(supplierPaymentInfo),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Customer Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(customerName),
                        const SizedBox(height: 8),
                        Text(
                          'Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(customerAddress),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Invoice Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
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
                                  Text(
                                    (item.quantity * item.unitPrice)
                                        .toStringAsFixed(2),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    child: Text('Send to review'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.black), // Set the desired button color
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
