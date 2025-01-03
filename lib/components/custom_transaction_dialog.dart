import 'package:flutter/material.dart';

class CustomTransactionDialog extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String account;
  final String mainCurrency;
  final double amount;
  final String subCurrency;
  final double subAmount;
  final List<String>? photos;

  const CustomTransactionDialog({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.account,
    required this.mainCurrency,
    required this.amount,
    required this.subCurrency,
    required this.subAmount,
    this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header dengan gradient
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Isi detail transaksi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Category', category),
                _buildDetailRow('Date', date),
                _buildDetailRow('Account', account),
                _buildDetailRow(
                    'Amount', '$mainCurrency ${amount.toStringAsFixed(2)}'),
                _buildDetailRow('Converted',
                    '$subCurrency ${subAmount.toStringAsFixed(2)}'),
                if (photos != null && photos!.isNotEmpty)
                  _buildPhotoPreview(photos!),
              ],
            ),
          ),

          // Tombol close
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(List<String> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: photos.map((photo) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photo,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
