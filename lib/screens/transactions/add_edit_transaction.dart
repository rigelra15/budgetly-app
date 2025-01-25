import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AddEditTransactionScreen extends StatefulWidget {
  String? transactionId;

  AddEditTransactionScreen({super.key, this.transactionId});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  bool _isLoading = false;
  bool isLoadingAddorEdit = false;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final List<Map<String, String>> _incomeCategories = [
    {'label': 'Uang Saku', 'value': 'allowance'},
    {'label': 'Gaji', 'value': 'salary'},
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
  final List<String> _currencies = [
    'IDR',
  ];
  final List<Map<String, String>> _transactionTypes = [
    {'label': 'Pemasukan', 'value': 'income'},
    {'label': 'Pengeluaran', 'value': 'expense'},
  ];

  String? _selectedCategory = 'allowance';
  String? _selectedAccount;
  String? _selectedCurrency = 'IDR';
  String? _selectedTransactionType;
  DateTime? _selectedDate;
  List<String> _existingPhotos = [];
  final List<String> _existingPhotosToDelete = [];
  final List<File> _newPhotos = [];

  final ImagePicker _picker = ImagePicker();

  List<Map<String, String>> get _currentCategories {
    if (_selectedTransactionType == 'income') {
      return _incomeCategories;
    } else if (_selectedTransactionType == 'expense') {
      return _expenseCategories;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      fetchTransactionData();
      _fetchPhotos();
    }
  }

  Future<void> fetchTransactionData() async {
    setState(() {
      _isLoading = true;
    });

    final String transactionUrl =
        'https://budgetly-api-pa7n.vercel.app/api/transactions/${widget.transactionId}';

    try {
      final transactionResponse = await http.get(Uri.parse(transactionUrl));
      if (transactionResponse.statusCode == 200) {
        final transactionData = json.decode(transactionResponse.body);

        setState(() {
          _amountController.text = transactionData['amount'].toString();
          _selectedCurrency = transactionData['currency'];
          _selectedTransactionType = transactionData['type'];
          _selectedCategory = transactionData['category'];
          _selectedAccount = transactionData['account'];
          _selectedDate = DateTime.fromMillisecondsSinceEpoch(
            (transactionData['date']['_seconds'] as int) * 1000,
          );
          _descriptionController.text = transactionData['description'] ?? '';
          _noteController.text = transactionData['note'] ?? '';
        });
      } else {
        debugPrint(
            'Failed to fetch transaction data: ${transactionResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching transaction data or photos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          _existingPhotos = List<String>.from(data['signedUrls']);
        });
      } else {
        debugPrint('Failed to fetch photos: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching photos: $error');
    }
  }

  Future<void> _submitTransaction() async {
    setState(() {
      isLoadingAddorEdit = true;
    });

    if (_formKey.currentState!.validate()) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      try {
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
        request.fields['date'] = _selectedDate
                ?.subtract(const Duration(hours: 7))
                .toIso8601String() ??
            '';
        request.fields['description'] = _descriptionController.text;
        request.fields['note'] = _noteController.text;

        for (var photo in _newPhotos) {
          if (photo.existsSync()) {
            request.files.add(await http.MultipartFile.fromPath(
              'photos',
              photo.path,
            ));
          } else {
            debugPrint('Photo file does not exist: ${photo.path}');
          }
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
            _newPhotos.clear();
            isLoadingAddorEdit = false;
          });

          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan transaksi: $e')),
        );
      } finally {
        setState(() {
          isLoadingAddorEdit = false;
        });
      }
    }
  }

  Future<void> updateTransaction() async {
    setState(() {
      isLoadingAddorEdit = true;
    });

    if (_formKey.currentState!.validate()) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      try {
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse(
              'https://budgetly-api-pa7n.vercel.app/api/transactions/${widget.transactionId}'),
        );

        request.fields['userId'] = userId.toString();
        request.fields['type'] = _selectedTransactionType ?? '';
        request.fields['amount'] = _amountController.text;
        request.fields['category'] = _selectedCategory ?? '';
        request.fields['account'] = _selectedAccount ?? '';
        request.fields['currency'] = _selectedCurrency ?? '';
        request.fields['date'] = _selectedDate
                ?.subtract(const Duration(hours: 7))
                .toIso8601String() ??
            '';
        request.fields['description'] = _descriptionController.text;
        request.fields['note'] = _noteController.text;

        for (var photo in _newPhotos) {
          request.files.add(await http.MultipartFile.fromPath(
            'photos',
            photo.path,
          ));
        }

        request.fields['deletedPhotos'] = jsonEncode(_existingPhotosToDelete);

        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil diperbarui!')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui transaksi: $e')),
        );
      } finally {
        setState(() {
          isLoadingAddorEdit = false;
        });
      }
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
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
      _newPhotos.addAll(pickedImages.map((e) => File(e.path)).toList());
    });

    for (var photo in _newPhotos) {
      debugPrint('Picked photo: ${photo.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.transactionId == null
                ? 'Tambah Transaksi'
                : 'Edit Transaksi',
          ),
          backgroundColor: const Color(0xFF3F8C92),
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Nama Transaksi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          width: 100,
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
                    DropdownButtonFormField<String>(
                      value: _selectedTransactionType,
                      hint: const Text('Pilih tipe transaksi'),
                      items: _transactionTypes
                          .map((type) => DropdownMenuItem<String>(
                                value: type['value'],
                                child: Text(capitalize(type['label']!)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTransactionType = value;
                          _selectedCategory = null;
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
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategory = value;
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Pilih Tanggal dan Waktu'
                              : DateFormat('dd/MM/yyyy HH:mm')
                                  .format(_selectedDate!),
                          style: const TextStyle(fontSize: 16),
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
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        ..._existingPhotos.map((photoUrl) {
                          return SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: photoUrl.startsWith('https')
                                      ? Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                          width: 80,
                                          height: 80,
                                        )
                                      : Image.file(
                                          File(photoUrl),
                                          fit: BoxFit.cover,
                                          width: 80,
                                          height: 80,
                                        ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showPreview(photoUrl);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _existingPhotosToDelete.add(photoUrl);
                                        _existingPhotos.remove(photoUrl);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        ..._newPhotos.map((photo) {
                          return SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    photo,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showPreview(photo.path);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _newPhotos.remove(photo);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (_existingPhotos.length + _newPhotos.length < 10)
                          GestureDetector(
                            onTap: _pickPhotos,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(
                                  color: Colors.grey,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: widget.transactionId == null
                          ? _submitTransaction
                          : updateTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F8C92),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Center(
                        child: isLoadingAddorEdit
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  size: 24,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.transactionId == null
                                    ? 'Tambah Transaksi'
                                    : 'Perbarui Transaksi',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Memuat transaksi...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }

  void _showPreview(String photoPath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: photoPath.startsWith('https')
                    ? Image.network(
                        photoPath,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(photoPath),
                        fit: BoxFit.contain,
                      ),
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
