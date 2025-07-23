import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:herbal_plants/AllScreens/herbalScreen.dart';
import 'package:herbal_plants/AllScreens/recommendationScreen.dart';
import 'package:localstorage/localstorage.dart';
import '../Drawer/Drawer.dart';
import 'chatBotScreen.dart';
import 'distributionScreen.dart';
import 'imageScreen.dart';
import 'loginScreen.dart';

class UserDashboard extends StatefulWidget {
  static const String idScreen = "UserDashboard";

  @override
  _UserDashboard createState() => _UserDashboard();
}

class _UserDashboard extends State<UserDashboard> {
  final LocalStorage storage = new LocalStorage('localstorage_app');

  String name="",email="",imgUrl="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
    setState(() {
      name=storage.getItem('name');
      email=storage.getItem('email');
      imgUrl=storage.getItem('pic');
    });
  }

  void logout(context) async {

    CoolAlert.show(
      context: context,
      type: CoolAlertType.confirm,
      text: 'Do you want to Logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        Navigator.pop(context);
        storage.clear();
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.idScreen, (route) => false);
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(name:name,email:email,imgUrl:imgUrl),
      appBar: AppBar(
        title: Text("User Dashboard"),
        actions: [
          Container(
            padding: EdgeInsets.only(top: 5,right: 5),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(imgUrl),
                )
              ],
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 35.0,),
              Image(
                image: AssetImage("images/logo.png"),
                width: 250.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 10.0,),
              Text(
                "User",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),

              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [

                    SizedBox(height: 30.0,),
                    ElevatedButton(
                      child: Container(
                        height: 50.0 ,
                        child: Center(
                          child: Text(
                            "Indentify Herbal ",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold" ,color: Colors.white),
                          ),
                        ),
                      ),
                      onPressed: ()
                      {
                        Navigator.pushNamedAndRemoveUntil(
                            context, HerbalScreen.idScreen, (route) => true);
                      },
                    ),
                    SizedBox(height: 30.0,),
                    ElevatedButton(
                      child: Container(
                        height: 50.0 ,
                        child: Center(
                          child: Text(
                            "Distribution Map",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold" ,color: Colors.white),
                          ),
                        ),
                      ),
                      onPressed: ()
                      {

                        Navigator.pushNamedAndRemoveUntil(
                            context, DistributionScreen.idScreen, (route) => true);

                      },
                    ),
                    SizedBox(height: 30.0,),
                    ElevatedButton(
                      child: Container(
                        height: 50.0 ,
                        child: Center(
                          child: Text(
                            "Distribution Image",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold" ,color: Colors.white),
                          ),
                        ),
                      ),
                      onPressed: ()
                      {

                        Navigator.pushNamedAndRemoveUntil(
                            context, ImageScreen.idScreen, (route) => true);

                      },
                    ),
                    SizedBox(height: 30.0,),
                    ElevatedButton(
                      child: Container(
                        height: 50.0 ,
                        child: Center(
                          child: Text(
                            "Recommendation",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold" ,color: Colors.white),
                          ),
                        ),
                      ),
                      onPressed: ()
                      {

                        Navigator.pushNamedAndRemoveUntil(
                            context, RecommendationScreen.idScreen, (route) => true);

                      },
                    ),
                    SizedBox(height: 30.0,),
                    ElevatedButton(
                      child: Container(
                        height: 50.0 ,
                        child: Center(
                          child: Text(
                            "Chat Bot",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold" ,color: Colors.white),
                          ),
                        ),
                      ),
                      onPressed: ()
                      {

                        Navigator.pushNamedAndRemoveUntil(
                            context, ChatBotScreen.idScreen, (route) => true);

                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      )
    );
  }

}
