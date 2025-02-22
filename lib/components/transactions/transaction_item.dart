import 'package:budgetly/components/transactions/custom_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final String transactionId;
  final String title;
  final String mainCurrency;
  final double amount;
  final double subAmount;
  final String subCurrency;
  final String date;
  final String account;
  final String category;
  final List<String>? photos;
  final Color color;
  final VoidCallback onTransactionDeleted;

  TransactionItem({
    super.key,
    required this.icon,
    required this.transactionId,
    required this.title,
    required this.mainCurrency,
    required this.amount,
    required this.subAmount,
    required this.subCurrency,
    required this.date,
    required this.account,
    required this.category,
    this.photos,
    required this.color,
    required this.onTransactionDeleted,
  });

  final Map<String, String> _categoryTranslations = {
    'allowance': 'Uang Saku',
    'salary': 'Gaji',
    'bonus': 'Bonus',
    'other': 'Lainnya',
    'food': 'Makanan',
    'social_life': 'Kehidupan Sosial',
    'pets': 'Hewan Peliharaan',
    'transport': 'Transportasi',
    'culture': 'Budaya',
    'household': 'Rumah Tangga',
    'apparel': 'Pakaian',
    'beauty': 'Kecantikan',
    'health': 'Kesehatan',
    'education': 'Pendidikan',
    'gift': 'Hadiah',
  };

  String _getTranslatedCategory(String category) {
    return _categoryTranslations[category] ?? category;
  }

  final Map<String, String> _accountTranslations = {
    'card': 'Kartu Kredit',
    'cash': 'Tunai',
    'e-wallet': 'Dompet Digital',
    'bonus': 'Bonus',
    'other': 'Lainnya',
  };

  String _getTranslatedAccount(String account) {
    return _accountTranslations[account] ?? account;
  }

  Color _getCategoryColor(String category) {
    final incomeColors = {
      'allowance': Colors.blue,
      'salary': Colors.green,
      'bonus': Colors.orange,
      'other': Colors.teal,
    };

    final expenseColors = {
      'food': Colors.red,
      'social_life': Colors.pink,
      'pets': Colors.brown,
      'transport': Colors.indigo,
      'culture': Colors.deepPurple,
      'household': Colors.cyan,
      'apparel': Colors.amber,
      'beauty': Colors.lime,
      'health': Colors.lightGreen,
      'education': Colors.blueAccent,
      'gift': Colors.deepOrange,
      'other': Colors.grey,
    };

    return incomeColors[category] ?? expenseColors[category] ?? Colors.black;
  }

  IconData _getAccountIcon(String account) {
    switch (account) {
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.attach_money;
      case 'e-wallet':
        return Icons.account_balance_wallet;
      case 'bonus':
        return Icons.card_giftcard;
      default:
        return Icons.help;
    }
  }

  String _formatShortCurrency(double amount, String currency) {
    if (amount >= 1000000000) {
      return '$currency ${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount >= 1000000) {
      return '$currency ${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '$currency ${(amount / 1000).toStringAsFixed(2)}K';
    } else if (amount <= -1000000000) {
      return '$currency ${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount <= -1000000) {
      return '$currency ${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount <= -1000) {
      return '$currency ${(amount / 1000).toStringAsFixed(2)}K';
    }

    return '$currency ${NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    ).format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return GestureDetector(
      onTap: () {
        _showTransactionDetails(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                              if (photos != null && photos!.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6.0),
                                  child: Icon(
                                    Icons.photo,
                                    color: Colors.blueGrey,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildCategoryBadge(category),
                              _buildAccountIcon(account),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 90 : 120,
                          ),
                          child: Text(
                            _formatShortCurrency(amount, mainCurrency),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 90 : 120,
                          ),
                          child: Text(
                            _formatShortCurrency(subAmount, subCurrency),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getCategoryColor(category),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getTranslatedCategory(category),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountIcon(String account) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        _getAccountIcon(account),
        size: 16,
        color: Colors.grey.shade700,
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomTransactionDialog(
          title: title,
          transactionId: transactionId,
          category: _getTranslatedCategory(category),
          date: date,
          account: _getTranslatedAccount(account),
          mainCurrency: mainCurrency,
          amount: amount,
          subCurrency: subCurrency,
          subAmount: subAmount,
        );
      },
    ).then((result) {
      if (result == true) {
        onTransactionDeleted();
      }
    });
  }
}
