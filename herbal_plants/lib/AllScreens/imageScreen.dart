import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

class ImageScreen extends StatefulWidget {
  static const String idScreen = "ImageScreen";

  @override
  _ImageScreen createState() => _ImageScreen();
}

class _ImageScreen extends State<ImageScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');

  File? _imageFile=null;
  bool _loading = false;
  String diseases="",treatments="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
    _download("http://192.168.1.101:5000/visualization/pie_chart.png");
  }

  Future<void> _download(String url) async {
    final response = await http.get(Uri.parse(url));

    // Get the image name
    final imageName = path.basename(url);
    // Get the document directory path
    final appDir = await pathProvider.getApplicationDocumentsDirectory();

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);

    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _apiRecommendation(context) async {
    var url ='http://192.168.1.101:5000/recommndation';
    Map<String,String> data = {
      "Content-Type": "application/json"
    };
    //encode Map to JSON
    var body = data;
    var response = await http.post( Uri.parse(url),
        body: json.encode({'userid': storage.getItem("userid"),'postid': storage.getItem("postid")}) );
    var decoded = json.decode(response.body) as Map<String, dynamic>;
    print(decoded['m1_json']);
    print(decoded['m2_json']);
    setState(() {
      _loading = false;
      diseases = decoded['m1_json'];
      treatments = decoded['m2_json'];
    });

  }

  @override
  Widget build(BuildContext context) {

    var body = new SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 35.0,
            ),
            Image(
              image: AssetImage("images/logo.png"),
              width: 250.0,
              height: 250.0,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 1.0,
            ),
            Text(
              "Distribution Image",
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  _imageFile == null
                      ? Container(
                      width: double.infinity,
                      height: 600.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child:
                                Text('Herbal Image'),
                              ),
                            ),
                            SizedBox(
                              height: 90.0,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                },
                                child: Text(
                                  'Choose Image',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ]
                      )
                  )
                      : GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      width: double.infinity,
                      height: 450.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    var bodyProgress = new Container(
      child: new Stack(
        children: <Widget>[
          body,
          new Container(
            alignment: AlignmentDirectional.center,
            decoration: new BoxDecoration(
              color: Colors.white70,
            ),
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: new BorderRadius.circular(10.0)
              ),
              width: 300.0,
              height: 200.0,
              alignment: AlignmentDirectional.center,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: new Center(
                      child: new Text(
                        "Plase Wait...",
                        style: new TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Recommendation"),
      ),
      backgroundColor: Colors.white,
      body:new Container(
          child: _loading ? bodyProgress : body
      )
    );
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
