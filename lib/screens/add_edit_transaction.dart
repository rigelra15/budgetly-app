import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final List<Map<String, String>> _incomeCategories = [
    {'label': 'Uang Saku', 'value': 'allowance'},
    {'label': 'Gaji', 'value': 'salary'},
    {'label': 'Uang Tunai Kecil', 'value': 'petty_cash'},
    {'label': 'Bonus', 'value': 'bonus'},
    {'label': 'Lainnya', 'value': 'other'},
  ];

  final List<Map<String, String>> _expenseCategories = [
    {'label': 'Makanan', 'value': 'food'},
    {'label': 'Kehidupan Sosial', 'value': 'social_life'},
    {'label': 'Hewan Peliharaan', 'value': 'pets'},
    {'label': 'Transportasi', 'value': 'transport'},
    {'label': 'Budaya', 'value': 'culture'},
    {'label': 'Rumah Tangga', 'value': 'household'},
    {'label': 'Pakaian', 'value': 'apparel'},
    {'label': 'Kecantikan', 'value': 'beauty'},
    {'label': 'Kesehatan', 'value': 'health'},
    {'label': 'Pendidikan', 'value': 'education'},
    {'label': 'Hadiah', 'value': 'gift'},
    {'label': 'Lainnya', 'value': 'other'},
  ];

  final List<Map<String, String>> _accounts = [
    {'label': 'Tunai', 'value': 'cash'},
    {'label': 'Kartu', 'value': 'card'},
    {'label': 'E-Wallet', 'value': 'e-wallet'},
  ];
  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'JPY', 'GBP'];
  final List<Map<String, String>> _transactionTypes = [
    {'label': 'Pemasukan', 'value': 'income'},
    {'label': 'Pengeluaran', 'value': 'expense'},
  ];

  String? _selectedCategory;
  String? _selectedAccount;
  String? _selectedCurrency = 'IDR';
  String? _selectedTransactionType;
  DateTime? _selectedDate;
  List<File> _selectedPhotos = [];

  final ImagePicker _picker = ImagePicker();

  List<Map<String, String>> get _currentCategories {
    if (_selectedTransactionType == 'income') {
      return _incomeCategories;
    } else if (_selectedTransactionType == 'expense') {
      return _expenseCategories;
    }
    return []; // Kembalikan list kosong jika tipe transaksi belum dipilih
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      try {
        // Buat request dengan foto
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://budgetly-api-pa7n.vercel.app/api/transactions/add'),
        );
        request.fields['userId'] = userId.toString();
        request.fields['type'] = _selectedTransactionType ?? '';
        request.fields['amount'] = _amountController.text;
        request.fields['category'] = _selectedCategory ?? '';
        request.fields['account'] = _selectedAccount ?? '';
        request.fields['currency'] = _selectedCurrency ?? '';
        request.fields['date'] = _selectedDate?.toIso8601String() ?? '';
        request.fields['description'] = _descriptionController.text;
        request.fields['note'] = _noteController.text;

        for (var photo in _selectedPhotos) {
          request.files.add(await http.MultipartFile.fromPath(
            'photos',
            photo.path,
          ));
        }

        final response = await request.send();

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
          );

          setState(() {
            _formKey.currentState!.reset();
            _selectedCategory = null;
            _selectedAccount = null;
            _selectedCurrency = 'IDR';
            _selectedTransactionType = null;
            _selectedDate = null;
            _selectedPhotos = [];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan transaksi: $e')),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    // Pilih tanggal
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Jika tanggal dipilih, pilih waktu
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Gabungkan tanggal dan waktu yang dipilih
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _pickPhotos() async {
    final pickedImages = await _picker.pickMultiImage();
    setState(() {
      _selectedPhotos = pickedImages.map((e) => File(e.path)).toList();
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: const Color(0xFF3F8C92),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap masukkan jumlah.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100, // Berikan ukuran tetap pada dropdown
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      items: _currencies
                          .map((currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Mata Uang',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickPhotos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tambah Foto'),
              ),
              const SizedBox(height: 8),
              // if (_selectedPhotos.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedPhotos
                    .map((photo) => SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  photo,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedPhotos.remove(photo);
                                  });
                                },
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTransactionType,
                hint: const Text('Pilih tipe transaksi'), // Tambahkan hint text
                items: _transactionTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type['value'],
                          child: Text(capitalize(type['label']!)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTransactionType = value;
                    _selectedCategory =
                        null; // Reset kategori saat tipe transaksi berubah
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Tipe Transaksi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Mohon pilih tipe transaksi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Pilih kategori'),
                items: _currentCategories
                    .map((category) => DropdownMenuItem<String>(
                          value: category['value'],
                          child: Text(category['label']!),
                        ))
                    .toList(),
                onChanged: _selectedTransactionType == null
                    ? null // Nonaktifkan dropdown jika tipe transaksi belum dipilih
                    : (value) {
                        setState(() {
                          _selectedCategory =
                              value; // Simpan value dalam bahasa Inggris
                        });
                      },
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (_selectedTransactionType == null) {
                    return 'Mohon pilih tipe transaksi terlebih dahulu.';
                  }
                  if (value == null) {
                    return 'Mohon pilih kategori.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAccount,
                hint: const Text('Pilih akun'),
                items: _accounts
                    .map((account) => DropdownMenuItem(
                          value: account['value'],
                          child: Text(account['label']!),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccount = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Akun',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Mohon pilih akun.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih Tanggal dan Waktu'
                        : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  hintText: 'Deskripsi transaksi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Catatan transaksi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F8C92),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Center(
                  child: Text('Tambah Transaksi',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
