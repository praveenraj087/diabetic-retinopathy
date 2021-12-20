import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _outputs;
  var _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Diabetic Retinopathy Diagnosis'),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? Container(
                          child: Text("No Image found"),
                        )
                      : Column(
                          children: [
                            Image.file(_image),
                            SizedBox(height: 30),
                            _outputs[0]["label"].toString().substring(
                                        2,
                                        _outputs[0]["label"]
                                            .toString()
                                            .length) !=
                                    'Yes'
                                ? Column(
                                    children: [
                                      Text(
                                        "No, the given image doesn't show signs of Diabetic Retinopathy",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          background: Paint()
                                            ..color = Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        "Confidence : ${_outputs[0]["confidence"].toStringAsFixed(4)}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          background: Paint()
                                            ..color = Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        "Yes, the given image shows signs of Diabetic Retinopathy",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          background: Paint()
                                            ..color = Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        "Confidence : ${_outputs[0]["confidence"].toStringAsFixed(4)}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          background: Paint()
                                            ..color = Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        backgroundColor: Colors.red,
        child: Icon(Icons.image),
      ),
    );
  }

  pickImage() async {
    final picker = ImagePicker();
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
