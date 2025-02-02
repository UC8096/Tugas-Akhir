import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/Screen/mainscreen.dart';
import 'package:rider_app/Screen/registerScreen.dart';
import 'package:rider_app/main.dart';

class LoginScreen extends StatelessWidget
{
  static const String idScreen = "login";
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 35.0,),
              Image(
                image: AssetImage("images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),

              SizedBox(height: 1.0,),
              Text(
                "Login",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),

              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [

                    SizedBox(height: 1.0,),
                    TextField(
                      controller: emailtextEditingController,
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

                    SizedBox(height: 1.0,),
                    TextField(
                      controller: passwordtextEditingController,
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

                    SizedBox(height: 20.0,),
                    RaisedButton(
                      color: Colors.brown,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "login",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: ()
                      {
                        if(!emailtextEditingController.text.contains("@"))
                        {
                          displayToastMessage("Email address is not Valid", context);
                        }
                        else if(passwordtextEditingController.text.isEmpty)
                        {
                          displayToastMessage("Please fill the password", context);
                        }
                        else
                          {
                            loginAndAuthenticateUser(context);
                          }
                      },
                    ),
                  ],
                ),
              ),

              FlatButton(
                onPressed: ()
                {
                  Navigator.pushNamedAndRemoveUntil(context, RegisterScreen.idScreen, (route) => false);
                },
                child: Text(
                  "Do not have an Account? Register Here",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAndAuthenticateUser(BuildContext context) async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)
     {
      return ProgressDialog(message: "Authenticating, please wait...",);
     }
    );



    final User firebaseUser = ( await _firebaseAuth
        .signInWithEmailAndPassword(
        email: emailtextEditingController.text,
        password: passwordtextEditingController.text
    ).catchError((errMsg){
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
    })).user;

    if(firebaseUser != null)//user created
    {
      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap){
        if(snap.value !=null)
        {
          Navigator.pushNamedAndRemoveUntil(context,MainScreen.idScreen, (route) => false);
          displayToastMessage("Your are logged-in", context);
        }
        else
          {
            Navigator.pop(context);
            _firebaseAuth.signOut();
            displayToastMessage("No Account exists. Please Create new account", context);
          }
      });
    }
    else
    {
      Navigator.pop(context);
      displayToastMessage("Error, Cannot Sign in", context);
    }
  }
}
