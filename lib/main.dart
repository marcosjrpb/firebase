import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Test',
      home: TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sobreNomeController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Test'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome: '),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _sobreNomeController,
              decoration: InputDecoration(labelText: 'Sobrenome: '),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Idade'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String nome = _nameController.text;
                String sobrenome = _sobreNomeController.text;
                int idade = int.tryParse(_ageController.text) ?? 0;

                await _writeDataToFirestore(nome, sobrenome, idade);
              },
              child: Text('Enviar Dados ao Firestore'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _writeDataToFirestore(String nome, String sobrenome, int idade) async {
    try {
      // Escrever dados no Firestore
      await _firestore.collection('usuarios').add({
        'nome': nome,
        'sobrenome':sobrenome,
        'idade': idade,
      });
      print('Dados gravados no Firestore com sucesso');
    } catch (e) {
      print('Erro ao gravar dados no Firestore: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sobreNomeController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
