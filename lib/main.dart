import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIFashion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  bool _isPhotoTaken = false;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
        _isPhotoTaken = true;
      } else {
        print('No image selected.');
      }
    });
  }

  void _usePhoto() {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    executePythonScript('/Users/chrislau/Documents/GitHub/CSCI4998AGJ1/lib/AI.py', ['']/*['_image!.path']*/);
  }

  void _retakePhoto() {
    setState(() {
      _image = null;
      _isPhotoTaken = false;
    });
  }

  Future<void> executePythonScript(String scriptPath, List<String> args) async {
    final url = Uri.parse('http://10.0.2.2:8000/run-python-script');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'script_path': scriptPath,
        'args': args,
      }),
    );

    if (response.statusCode == 200) {
      final result = response.body;
      print('Python script result: $result');
    } else {
      print('Error executing Python script: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AIFashion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isPhotoTaken
                ? Image.file(_image!)
                : Text('No image selected'),
            SizedBox(height: 16.0),
            if (_isPhotoTaken)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _usePhoto,
                    child: Text('Use'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _retakePhoto,
                    child: Text('Retake'),
                  ),
                ],
              ),
            if (!_isPhotoTaken)
              ElevatedButton(
                onPressed: _takePhoto,
                child: Text('Take Photo'),
              ),
          ],
        ),
      ),
    );
  }
}