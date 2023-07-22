
class InvoiceItem {
  final String description;
  final int quantity;
  final double vat;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}