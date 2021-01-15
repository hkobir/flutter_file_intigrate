import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_intigrate/home_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  BuildContext dialogContext;

  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    showProgress(context, "Please wait...");

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          dismissProgress();

          print("CodeAuth: "+credential.hashCode.toString());
          setState(() {
            _codeController.text = credential.hashCode.toString();
          });
          Navigator.of(context).pop();

          var result = await _auth.signInWithCredential(credential);

          if (result != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Home(
                          phoneNo: result.user.phoneNumber,
                        )));
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (exception) {
          dismissProgress();
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          dismissProgress();

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give the code?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async {
                        final code = _codeController.text.trim();

                        showProgress(context, "Please wait...");

                        AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId, smsCode: code);

                        var result =
                            await _auth.signInWithCredential(credential);

                        if (result != null) {
                          dismissProgress();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                        phoneNo: result.user.phoneNumber,
                                      )));
                        } else {
                          dismissProgress();
                          print("Error");
                        }
                      },
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Sign In With Phone No",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[200])),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300])),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: "Mobile Number"),
                  controller: _phoneController,
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text("LOGIN"),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      final phone = "+88"+_phoneController.text.trim();

                      loginUser(phone, context);
                    },
                    color: Colors.blue,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showProgress(BuildContext context, String title) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: (Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  Text(title),
                ],
              )),
            ),
          );
        });
  }

  dismissProgress() {
    Fluttertoast.showToast(msg: "Done!", toastLength: Toast.LENGTH_SHORT);
    Navigator.of(dialogContext).pop();
  }
}
