import 'package:budgetly/components/shared/custom_confirmation_dialog.dart';
import 'package:budgetly/components/shared/custom_info_dialog.dart';
import 'package:budgetly/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profilePicUrl = 'https://via.placeholder.com/150';
  Map<String, dynamic> userDatas = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await Future.wait([
        fetchUserData(),
        fetchProfilePic(),
      ]);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final String url =
        'https://budgetly-api-pa7n.vercel.app/api/users/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userDatas = data;
        });
      } else {
        debugPrint('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> fetchProfilePic() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final String url =
        'https://budgetly-api-pa7n.vercel.app/api/users/user/$userId/profile-pic';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profilePicUrl = data['signedUrl'] ?? profilePicUrl;
        });
      } else {
        debugPrint('Failed to fetch profile picture: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching profile picture: $e');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          title: 'Konfirmasi Keluar',
          message: 'Apakah Anda yakin ingin keluar dari akun?',
          confirmText: 'Keluar',
          cancelText: 'Batal',
          onConfirm: () async {
            Navigator.of(context).pop();
            await _logoutUser(context);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomInfoDialog(
          title: 'Fitur Belum Tersedia',
          messages: const [
            'Fitur ini akan segera hadir dalam waktu dekat.',
          ],
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _logoutUser(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.clearUserId();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final accountSettings = [
      {
        'icon': Icons.edit,
        'title': 'Edit Profil',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.lock,
        'title': 'Keamanan (PIN/Biometrik)',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.password,
        'title': 'Ubah Password',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.shield,
        'title': 'Autentikasi 2FA',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.logout,
        'title': 'Keluar Akun',
        'onTap': () {
          _showLogoutDialog(context);
        },
        'color': Colors.red,
      },
    ];

    final appSettings = [
      {
        'icon': Icons.cloud,
        'title': 'Backup & Restore',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.color_lens,
        'title': 'Tema Aplikasi',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.attach_money,
        'title': 'Atur Main Currency',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.monetization_on,
        'title': 'Atur Sub Currency',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
      {
        'icon': Icons.language,
        'title': 'Bahasa',
        'onTap': () {
          _showComingSoonDialog(context);
        },
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F8C92), Color(0xFF1F4649)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profilePicUrl),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userDatas['displayName'] ?? 'John Doe',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            userDatas['email'] ?? 'johndoe@gmail.com',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Pengaturan Akun"),
                  _buildCard(accountSettings),
                  _buildSectionTitle("Pengaturan Aplikasi"),
                  _buildCard(appSettings),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: Icon(
              item['icon'],
              color: item['color'] ?? Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              item['title'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: item['color'] ?? Colors.black,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: item['color'] ?? Colors.black,
            ),
            onTap: item['onTap'],
          );
        }).toList(),
      ),
    );
  }
}
