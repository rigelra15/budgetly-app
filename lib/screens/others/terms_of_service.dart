import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  Widget buildNumberedText(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3F8C92),
                  Color(0xFF1F4649),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Ketentuan Layanan Budgetly',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat datang di Budgetly! Sebelum menggunakan aplikasi kami, harap membaca dan memahami Ketentuan Layanan berikut dengan seksama. Dengan menggunakan aplikasi ini, Anda dianggap telah menyetujui semua ketentuan yang berlaku.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Definisi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '1.1',
                '"Aplikasi" merujuk pada platform digital Budgetly yang dapat diakses melalui perangkat seluler.',
              ),
              buildNumberedText(
                '1.2',
                '"Pengguna" adalah individu yang menggunakan aplikasi Budgetly.',
              ),
              buildNumberedText(
                '1.3',
                '"Layanan" adalah fitur yang disediakan dalam aplikasi Budgetly, termasuk pengelolaan anggaran, pelacakan transaksi, dan lainnya.',
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Akun Pengguna',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '2.1',
                'Pengguna diwajibkan untuk mendaftar dan menyediakan informasi yang benar, lengkap, dan terkini.',
              ),
              buildNumberedText(
                '2.2',
                'Pengguna bertanggung jawab atas keamanan akun dan kata sandi mereka.',
              ),
              buildNumberedText(
                '2.3',
                'Budgetly berhak menonaktifkan akun yang melanggar Ketentuan Layanan atau yang dicurigai terlibat dalam aktivitas mencurigakan.',
              ),
              const SizedBox(height: 16),
              const Text(
                '3. Privasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '3.1',
                'Kami mengumpulkan dan memproses data pribadi Anda sesuai dengan Kebijakan Privasi.',
              ),
              buildNumberedText(
                '3.2',
                'Data yang Anda masukkan dalam aplikasi akan digunakan untuk menyediakan layanan yang lebih baik.',
              ),
              buildNumberedText(
                '3.3',
                'Kami tidak akan membagikan data pribadi Anda kepada pihak ketiga tanpa persetujuan Anda, kecuali diatur oleh hukum.',
              ),
              const SizedBox(height: 16),
              const Text(
                '4. Kewajiban Pengguna',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '4.1',
                'Pengguna wajib menggunakan aplikasi dengan cara yang sesuai hukum dan etika.',
              ),
              buildNumberedText(
                '4.2',
                'Pengguna tidak diperbolehkan:\n- Mengunggah konten ilegal, menyesatkan, atau merugikan pihak lain.\n- Melakukan aktivitas yang merusak sistem aplikasi.\n- Mengakses layanan tanpa izin.',
              ),
              buildNumberedText(
                '4.3',
                'Pengguna bertanggung jawab atas semua aktivitas yang dilakukan melalui akun mereka.',
              ),
              const SizedBox(height: 16),
              const Text(
                '5. Pembatasan Tanggung Jawab',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '5.1',
                'Budgetly tidak bertanggung jawab atas kerugian yang timbul akibat:\n- Kesalahan penggunaan aplikasi.\n- Gangguan teknis atau koneksi internet.\n- Kehilangan data yang disebabkan oleh kelalaian pengguna.',
              ),
              const SizedBox(height: 16),
              const Text(
                '6. Perubahan Ketentuan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '6.1',
                'Budgetly berhak untuk mengubah Ketentuan Layanan kapan saja.',
              ),
              buildNumberedText(
                '6.2',
                'Pengguna akan diberitahu tentang perubahan melalui email atau pemberitahuan dalam aplikasi.',
              ),
              buildNumberedText(
                '6.3',
                'Pengguna yang terus menggunakan aplikasi setelah perubahan dianggap menerima Ketentuan Layanan yang diperbarui.',
              ),
              const SizedBox(height: 16),
              const Text(
                '7. Penutup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Terima kasih telah menggunakan Budgetly. Dengan mematuhi Ketentuan Layanan ini, Anda membantu menciptakan komunitas yang aman dan nyaman.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
