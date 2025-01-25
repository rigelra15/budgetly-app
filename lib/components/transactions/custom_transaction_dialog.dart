import 'package:budgetly/screens/transactions/add_edit_transaction.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CustomTransactionDialog extends StatefulWidget {
  final String title;
  final String transactionId;
  final String category;
  final String date;
  final String account;
  final String mainCurrency;
  final double amount;
  final String subCurrency;
  final double subAmount;

  const CustomTransactionDialog({
    super.key,
    required this.title,
    required this.transactionId,
    required this.category,
    required this.date,
    required this.account,
    required this.mainCurrency,
    required this.amount,
    required this.subCurrency,
    required this.subAmount,
  });

  @override
  _CustomTransactionDialogState createState() =>
      _CustomTransactionDialogState();
}

class _CustomTransactionDialogState extends State<CustomTransactionDialog> {
  List<String> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://budgetly-api-pa7n.vercel.app/api/transactions/${widget.transactionId}/photos'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _photos = List<String>.from(data['signedUrls']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch photos');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteTransaction() async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://budgetly-api-pa7n.vercel.app/api/transactions/${widget.transactionId}'),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to delete transaction');
      }
    } catch (error) {
    }
  }

  String _formatCurrency(double amount, String currency) {
    final currencyFormats = {
      'IDR': NumberFormat.currency(
          locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0),
      'USD': NumberFormat.currency(
          locale: 'en_US', symbol: 'USD ', decimalDigits: 2),
      'EUR': NumberFormat.currency(
          locale: 'de_DE', symbol: 'EUR ', decimalDigits: 2),
    };

    final formatter = currencyFormats[currency] ??
        NumberFormat.currency(
            locale: 'en_US', symbol: currency, decimalDigits: 2);

    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3F8C92), Color(0xFF1F4649)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Kategori', widget.category),
                    _buildDetailRow('Tanggal', widget.date),
                    _buildDetailRow('Akun', widget.account),
                    _buildDetailRow(
                      'Jumlah (${widget.mainCurrency})',
                      _formatCurrency(widget.amount, widget.mainCurrency),
                    ),
                    _buildDetailRow(
                      'Jumlah (${widget.subCurrency})',
                      _formatCurrency(widget.subAmount, widget.subCurrency),
                    ),
                    const SizedBox(height: 4),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_photos.isNotEmpty)
                      _buildPhotoPreview(context),
                    if (!_isLoading && _photos.isEmpty)
                      const Text('Tidak ada foto yang tersedia'),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTransactionScreen(
                      transactionId: widget.transactionId,
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    Navigator.of(context).pop(true);
                  }
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 50,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Konfirmasi Hapus',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Apakah Anda yakin ingin menghapus transaksi ini? Data yang dihapus tidak dapat dikembalikan.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: deleteTransaction,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
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

  Widget _buildPhotoPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _photos.map((photo) {
            return GestureDetector(
              onTap: () => _showPhotoPreview(context, photo),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photo,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showPhotoPreview(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
