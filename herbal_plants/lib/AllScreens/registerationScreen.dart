import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:herbal_plants/AllScreens/loginScreen.dart';

class RegisterationScreen extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _Registeration createState() => _Registeration();
}

class _Registeration extends State<RegisterationScreen> {
  late final double lat, lng;

  File? _imageFile=null;
  bool _loading = false;

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

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


  void _uploadImage(context) {
    if(_imageFile!=null){
      setState(() {
        _loading = true;
      });
      //create a unique file name for image
      String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
      final Reference storageReference =FirebaseStorage.instance.ref().child('Images').child(imageFileName);

      final UploadTask uploadTask = storageReference.putFile(_imageFile!);

      uploadTask.then((TaskSnapshot taskSnapshot) {
        taskSnapshot.ref.getDownloadURL().then((imageUrl) {
          //save info to firebase
          registerNewUser(context,imageUrl);
          print(imageUrl);
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
              "Register Form",
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
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
                                Text('Profile Picture'),
                              ),
                            ),
                            SizedBox(
                              height: 90.0,
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
                          "Create Account",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (nameTextEditingController.text.length < 3) {
                        displayToastMessage(
                            "name must be atleast 3 characters", context);
                      } else if (!emailTextEditingController.text.contains("@")) {
                        displayToastMessage("Email address is not valid", context);
                      }else if (passwordTextEditingController.text.length <
                          6) {
                        displayToastMessage(
                            "Password must be at least 6 characters",
                            context);
                      }else {
                        _uploadImage(context);
                      }
                    },
                  ),

                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              child: Text(
                "Already have an Account? Login Here.",
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
        title: Text("Register"),
      ),
      backgroundColor: Colors.white,
      body:new Container(
          child: _loading ? bodyProgress : body
      )
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void registerNewUser(BuildContext context,String imageUrl) async {
    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) //user created
    {
      try {
        await firestore.collection("users").doc(firebaseUser.uid).set({
          'name': nameTextEditingController.text,
          'pic': imageUrl,
          'email': emailTextEditingController.text,
          'admin': 0,
          'postid': '356042511',
          'userid': '5eece14ffc13ae66090001bd',
        });
      } catch (e) {
        print(e);
      }

      displayToastMessage("Account Created Successful!", context);
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.idScreen, (route) => true);
    } else {
      //error occured - display error msg
      Navigator.pop(context);
      displayToastMessage("New user account has not been Created.", context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
