import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = 'https://api.hgbrasil.com/finance?format=json&key=';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearForm() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  void _onChangedReal(String text) {
    if(text.isEmpty) {
      _clearForm();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _onChangedDolar(String text) {
    if(text.isEmpty) {
      _clearForm();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _onChangedEuro(String text) {
    if(text.isEmpty) {
      _clearForm();
      return;
    }

    double euro = double.parse(text);
    euroController.text = (euro * this.euro).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: const Text('Conversor de moedas'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
          future: _getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              dolar = snapshot.data!['results']['currencies']['USD']['buy'];
              euro = snapshot.data!['results']['currencies']['EUR']['buy'];

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField('Reais', 'R\$ ', realController, _onChangedReal),
                      const Divider(),
                      buildTextField('Dólares', 'USD ', dolarController, _onChangedDolar),
                      const Divider(),
                      buildTextField('Euros ', '€ ', euroController, _onChangedEuro),
                    ],
                  ),
                ),
              );
            } else {
              print(snapshot.error);
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text('Loading data'),
                ],
              ),
            );
          }),
    );
  }

  Widget buildTextField(String label, String prefix, TextEditingController controller, Function onChanged) {
    return TextField(
      controller: controller,
      onChanged: (_) {
        setState(() {
          onChanged(controller.text);
        });
      },
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        border: const OutlineInputBorder(),
        prefixText: prefix,
      ),
      style: const TextStyle(
        color: Colors.amber,
        fontSize: 25.0,
      ),
    );
  }

  Future<Map> _getData() async {
    http.Response response = await http.get(Uri.parse(request));
    return json.decode(response.body);
  }
}