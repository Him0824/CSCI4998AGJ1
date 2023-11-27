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

          return Column(
            children: [
              Container(
                height: 300.0, // Set the desired height for the image
                child: Image.memory(
                  decodedImage,
                  fit: BoxFit.cover, // Adjust the fit property
                ),
              ),
              SizedBox(height: 8.0), // Add spacing between the image and name
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}