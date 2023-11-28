import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIFashion',
      theme: ThemeData(
        primaryColor: Colors.indigo[800],
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          color: Colors.indigo[800],
        ),
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

  void _usePhoto() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    print(_image);

    final items = await executePythonScript('AI.py', ['']);
    final jsonResponse = jsonEncode(items);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(jsonResponse: jsonResponse),
      ),
    );
  }

  void _retakePhoto() {
    setState(() {
      _image = null;
      _isPhotoTaken = false;
    });
  }

  Future<List<Map<String, dynamic>>> executePythonScript(
      String scriptPath, List<String> args) async {
    final url = Uri.parse('http://34.83.20.127:3389/run-python-script');
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
      final temp = jsonDecode(result);
      final parsedResult = jsonDecode(temp['result']);
      final items = List<Map<String, dynamic>>.from(parsedResult['result']);
      return items;
    } else {
      print('Error executing Python script: ${response.statusCode}');
      return []; // Return an empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AIFashion',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isPhotoTaken
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.indigo,
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Image.file(
                    _image!,
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.cover,
                  ),
                )
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