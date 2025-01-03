import 'package:budgetly/screens/onboarding.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bagian atas dengan foto header
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3F8C92), Color(0xFF1F4649)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profilePicUrl),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              userDatas['displayName'] ?? 'John Doe',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              userDatas['email'] ?? 'johndoe@gmail.com',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Tambahkan fungsi edit profil
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Edit Profil"),
            ),
            const SizedBox(height: 20),

            // Menu utama
            _buildSectionTitle("Pengaturan Akun"),
            _buildCard([
              _buildMenuItem(
                context,
                icon: Icons.edit,
                title: "Edit Profil",
                onTap: () {
                  // Tambahkan fungsi edit profil
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.lock,
                title: "Keamanan (PIN/Biometrik)",
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.password,
                title: "Ubah Password",
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.shield,
                title: "Autentikasi 2FA",
                onTap: () {},
              ),
              _buildMenuItem(context,
                  icon: Icons.logout,
                  title: 'Keluar Akun',
                  onTap: () {},
                  color: Colors.red)
            ]),

            // Menu pengaturan aplikasi
            _buildSectionTitle("Pengaturan Aplikasi"),
            _buildCard([
              _buildMenuItem(
                context,
                icon: Icons.cloud,
                title: "Backup & Restore",
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.color_lens,
                title: "Tema Aplikasi",
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.attach_money,
                title: "Atur Main Currency",
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.monetization_on,
                title: "Atur Sub Currency",
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.language,
                title: "Bahasa",
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 20)
          ],
        ),
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

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar belakang
        borderRadius: BorderRadius.circular(16), // Rounded border
        border: Border.all(
          color: Colors.grey.shade300, // Warna border
          width: 1, // Ketebalan border
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      VoidCallback? onTap,
      Color? color}) {
    return ListTile(
      leading:
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color ?? Colors.black),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: color ?? Colors.black),
      onTap: onTap,
    );
  }
}
