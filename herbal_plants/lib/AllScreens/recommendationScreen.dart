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
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

class RecommendationScreen extends StatefulWidget {
  static const String idScreen = "RecommendationScreen";

  @override
  _RecommendationScreen createState() => _RecommendationScreen();
}

class _RecommendationScreen extends State<RecommendationScreen> {
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
  }

  Future<void> _apiRecommendation(context) async {
    var url ='http://192.168.1.101:5000/recommndation';

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
              "Recommendation",
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
                  SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Check",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _apiRecommendation(context);
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
