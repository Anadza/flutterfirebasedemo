import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _namaKucingController = TextEditingController();
  final _vaksinController = TextEditingController();
  final _tanggalController = TextEditingController();
  void _addData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        _namaKucingController.text.isNotEmpty &&
        _vaksinController.text.isNotEmpty &&
        _tanggalController.text.isNotEmpty) {
      await _firestore.collection('vaksin_kucing').add({
        'namaKucing': _namaKucingController.text,
        'jenisVaksin': _vaksinController.text,
        'tanggal': _tanggalController.text,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'userEmail': user.email,
      });
      _namaKucingController.clear();
      _vaksinController.clear();
      _tanggalController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catsin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Selamat datang, ${user?.email ?? 'Pengguna'}!'),
            const SizedBox(height: 20),
            // Masukan nama kucing
            TextField(
              controller: _namaKucingController,
              decoration: const InputDecoration(
                labelText: 'Masukkan nama kucing',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Masukan jenis vaksin
            TextField(
              controller: _vaksinController,
              decoration: const InputDecoration(
                labelText: 'Masukkan jenis vaksin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Masukan tanggal vaksin
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(
                labelText: 'Masukkan tanggal vaksin',
                hintText: '07/06/2026',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addData,
              child: const Text('Simpan Data Vaksin'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Data Tersimpan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('vaksin_kucing')
                    // .where('userId', isEqualTo: user?.uid)
                    // .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada data.'));
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (ctx, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(data['namaKucing']),
                          subtitle: Text(
                            'Vaksin: ${data['jenisVaksin']}\n'
                            'Tanggal: ${data['tanggal']}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
