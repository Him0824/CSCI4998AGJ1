import 'package:flutter/material.dart';
import 'dart:convert';

class ResultPage extends StatelessWidget {
  final String jsonResponse;

  ResultPage({required this.jsonResponse});

  @override
  Widget build(BuildContext context) {
    final items = jsonDecode(jsonResponse);

    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final imageData = items[index];
          final name = imageData['name'];
          final base64Data = imageData['data'];
          final decodedImage = base64Decode(base64Data);

          return Container(
            height: 80.0, // Set the desired height for the ListTile
            child: ListTile(
              title: Text(name),
              leading: Image.memory(
                decodedImage,
                fit: BoxFit.contain, // Adjust the fit property
                width: 80.0, // Set the desired width for the image
                height: 80.0,
              ),
            ),
          );
        },
      ),
    );
  }
}