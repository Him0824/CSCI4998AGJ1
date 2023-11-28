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
        title: Text(
          'Search Result',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final imageData = items[index];
          final name = imageData['name'];
          final base64Data = imageData['data'];
          final decodedImage = base64Decode(base64Data);

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(name),
                  content: Image.memory(decodedImage),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.indigo,
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  height: 300.0, // Set the desired height for the image
                  width: 300.0, // Set the desired width for the image
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
            ),
          );
        },
      ),
    );
  }
}