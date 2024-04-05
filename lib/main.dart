import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


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
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();


  final FocusNode _nameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();


  @override
  void dispose() {
    _nameFocus.dispose();
    _ageFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

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
            _buildInputFields(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addDataToFirestore,
              child: Text('Enviar Dados ao Firestore'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _buildFirestoreList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          focusNode: _nameFocus,
          onTap: () => _nameFocus.requestFocus(),
          decoration: InputDecoration(labelText: 'Nome'),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: _lastNameController,
          focusNode: _lastNameFocus,
          onTap: () => _lastNameFocus.requestFocus(),
          decoration: InputDecoration(labelText: 'Sobre nome'),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: _ageController,
          focusNode: _ageFocus,
          onTap: () => _ageFocus.requestFocus(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Idade'),
        ),
      ],
    );
  }

  Future<void> _addDataToFirestore() async {
    String nome = _nameController.text;
    String lastName = _lastNameController.text;
    int idade = int.tryParse(_ageController.text) ?? 0;

    await _writeDataToFirestore(nome,lastName, idade);

    // Limpar os campos após adicionar os dados
    _nameController.clear();
    _lastNameController.clear();
    _ageController.clear();
  }

  Future<void> _writeDataToFirestore(String nome,String lastname, int idade) async {
    try {
      await _firestore.collection('usuarios').add({
        'nome': nome,
         'sobrenome': lastname,
        'idade': idade,
      });
      print('Dados gravados no Firestore com sucesso');
    } catch (e) {
      print('Erro ao gravar dados no Firestore: $e');
    }
  }

  Widget _buildFirestoreList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(data['nome']),
              subtitle: Text('Sobrenome: ${data['sobrenome']} Idade: ${data['idade']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(document.id, data['nome'],data['sobrenome'], data['idade']);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteDataFromFirestore(document.id);
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _deleteDataFromFirestore(String documentId) async {
    try {
      await _firestore.collection('usuarios').doc(documentId).delete();
      print('Documento deletado do Firestore com sucesso');
    } catch (e) {
      print('Erro ao deletar documento do Firestore: $e');
    }
  }

  Future<void> _showEditDialog(String documentId, String currentName,String lastName, int currentAge) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController ageController = TextEditingController(text: currentAge.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Idade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text;
                int newAge = int.tryParse(ageController.text) ?? 0;

                await _updateDataInFirestore(documentId, newName, newAge);

                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDataInFirestore(String documentId, String newName, int newAge) async {
    try {
      await _firestore.collection('usuarios').doc(documentId).update({
        'nome': newName,
        'idade': newAge,
      });
      print('Documento atualizado no Firestore com sucesso');
    } catch (e) {
      print('Erro ao atualizar documento no Firestore: $e');
    }
  }
}
