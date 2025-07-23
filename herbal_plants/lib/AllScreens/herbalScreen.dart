import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HerbalScreen extends StatefulWidget {
  static const String idScreen = "HerbalScreen";

  @override
  _HerbalScreen createState() => _HerbalScreen();
}

class _HerbalScreen extends State<HerbalScreen> {

  File? _imageFile=null;
  bool _loading = false;
  String diseases="",treatments="",herbal="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
  }

  ImagePicker imagePicker = ImagePicker();

  Future<void> _chooseImage() async {
    PickedFile? pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future<void> _getFromCamera() async {
    PickedFile? pickedFile = await imagePicker.getImage(
      source: ImageSource.camera,
    );

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  void _uploadImage(context) {
    if(_imageFile!=null){
      setState(() {
        _loading = true;
      });
      //create a unique file name for image
      String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
      final Reference storageReference =FirebaseStorage.instance.ref().child('Herbal').child(imageFileName);

      final UploadTask uploadTask = storageReference.putFile(_imageFile!);

      uploadTask.then((TaskSnapshot taskSnapshot) {
        taskSnapshot.ref.getDownloadURL().then((imageUrl) async {
          //save info to firebase
          print(imageUrl);
            var url ='http://192.168.1.101:5000/herbal';
          Map<String,String> data = {
            "Content-Type": "application/json"
          };
          //encode Map to JSON
          var body = data;
          var response = await http.post( Uri.parse(url),
                body: json.encode({'url': imageUrl}) );
          var decoded = json.decode(response.body) as Map<String, dynamic>;
          print(decoded['herbal']);
          print(decoded['diseases']);
          print(decoded['treatments']);
          setState(() {
            _loading = false;
            herbal = decoded['herbal'];
            diseases = decoded['diseases'];
            treatments = decoded['treatments'];
          });
        });
      }).catchError((error) {
        setState(() {
          _loading = false;
        });
        Fluttertoast.showToast(
          msg: error.toString(),
        );
      });
    }else{
      displayToastMessage(
          "Choose Image!",
          context);
    }

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
              "Herbal",
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
                      height: 250.0,
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
                              height: 40.0,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  _chooseImage();
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
                            SizedBox(
                              height: 30.0,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  _getFromCamera();
                                },
                                child: Text(
                                  'Open Camera',
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
                      _chooseImage();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 250.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Upload",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _uploadImage(context);
                    },
                  ),
                ],
              ),
            ),

        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Text(
                herbal,
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.left,
              ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              diseases,
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              treatments,
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.left,
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
        title: Text("Herbal"),
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
