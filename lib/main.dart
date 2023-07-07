import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Gunung Berapi di Indonesia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Daftar Gunung Berapi di Indonesia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<dynamic>> _volcanoes;

  Future<List<dynamic>> fetchVolcanoes() async {
    final response = await http.get(Uri.parse(
        'https://indonesia-public-static-api.vercel.app/api/volcanoes'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _volcanoes = fetchVolcanoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
          future: _volcanoes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> data = snapshot.data!;
              return SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Bentuk')),
                    DataColumn(label: Text('Tinggi (Meter)')),
                    DataColumn(label: Text('Estimasi Letusan Terakhir')),
                    DataColumn(label: Text('Geolokasi')),
                  ],
                  rows: data
                      .map((item) => DataRow(cells: [
                            DataCell(Text(item['nama'].toString())),
                            DataCell(Text(item['bentuk'].toString())),
                            DataCell(Text(item['tinggi_meter'].toString())),
                            DataCell(Text(
                                item['estimasi_letusan_terakhir'].toString())),
                            DataCell(Text(item['geolokasi'].toString())),
                          ]))
                      .toList(),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
