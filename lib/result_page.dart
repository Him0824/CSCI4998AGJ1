import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final List<Map<String, dynamic>> jsonList;

  ResultPage({required this.jsonList});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<String> names = [];

  @override
  void initState() {
    super.initState();
    extractNames();
  }

  void extractNames() {
    names = widget.jsonList.map((json) => json['name'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
      ),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(names[index]),
          );
        },
      ),
    );
  }
}