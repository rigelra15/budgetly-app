import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                        'Kebijakan Privasi Budgetly',
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
                'Kebijakan Privasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Budgetly sangat menghargai privasi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat menggunakan aplikasi kami.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Informasi yang Kami Kumpulkan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '1.1',
                'Informasi Pribadi: Nama, alamat email, foto profil, dan informasi lain yang Anda masukkan saat pendaftaran.',
              ),
              buildNumberedText(
                '1.2',
                'Informasi Aktivitas: Data transaksi, pengeluaran, pemasukan, dan aktivitas lain yang Anda masukkan dalam aplikasi.',
              ),
              buildNumberedText(
                '1.3',
                'Data Perangkat: Informasi tentang perangkat Anda seperti jenis perangkat, sistem operasi, dan ID perangkat.',
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Penggunaan Informasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '2.1',
                'Kami menggunakan informasi pribadi Anda untuk menyediakan layanan seperti pengelolaan keuangan, laporan, dan fitur lainnya.',
              ),
              buildNumberedText(
                '2.2',
                'Informasi digunakan untuk meningkatkan pengalaman pengguna, termasuk mempersonalisasi fitur aplikasi.',
              ),
              buildNumberedText(
                '2.3',
                'Kami dapat menggunakan data Anda untuk komunikasi terkait layanan, pembaruan, atau promosi khusus.',
              ),
              const SizedBox(height: 16),
              const Text(
                '3. Pembagian Informasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '3.1',
                'Kami tidak akan membagikan informasi pribadi Anda kepada pihak ketiga tanpa persetujuan Anda, kecuali diwajibkan oleh hukum.',
              ),
              buildNumberedText(
                '3.2',
                'Kami dapat membagikan data anonim yang tidak dapat diidentifikasi untuk keperluan analisis atau penelitian.',
              ),
              const SizedBox(height: 16),
              const Text(
                '4. Keamanan Data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '4.1',
                'Kami menggunakan langkah-langkah keamanan teknis dan organisasi untuk melindungi informasi pribadi Anda.',
              ),
              buildNumberedText(
                '4.2',
                'Meskipun demikian, kami tidak dapat menjamin keamanan mutlak terhadap akses yang tidak sah.',
              ),
              const SizedBox(height: 16),
              const Text(
                '5. Hak Pengguna',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '5.1',
                'Anda memiliki hak untuk mengakses, memperbarui, atau menghapus informasi pribadi Anda kapan saja.',
              ),
              buildNumberedText(
                '5.2',
                'Untuk pertanyaan atau permintaan terkait data Anda, hubungi kami melalui dukungan pelanggan.',
              ),
              const SizedBox(height: 16),
              const Text(
                '6. Perubahan Kebijakan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildNumberedText(
                '6.1',
                'Kebijakan Privasi ini dapat diperbarui sewaktu-waktu untuk mencerminkan perubahan pada layanan kami.',
              ),
              buildNumberedText(
                '6.2',
                'Kami akan memberi tahu Anda tentang perubahan melalui email atau pemberitahuan dalam aplikasi.',
              ),
              const SizedBox(height: 16),
              const Text(
                '7. Hubungi Kami',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami melalui email support@budgetly.com.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
