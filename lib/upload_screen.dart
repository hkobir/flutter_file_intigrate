import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_file_intigrate/file_model.dart';

class AddFile extends StatefulWidget {
  @override
  _AddFileState createState() => _AddFileState();
}

class _AddFileState extends State<AddFile> {
  String fileName, fileTitle = "";
  String fileLink;
  File _file;
  BuildContext dialogContext;

  Future<bool> insertFile(final file) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var result = await firestore.collection("files").add(file).catchError((e) {
      Fluttertoast.showToast(
          msg: e.toString(), toastLength: Toast.LENGTH_SHORT);
      dismissProgress();
      print(e);
      return false;
    });
    if (result != null) {
      return true;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Upload File"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 25),
                  child: Column(
                    children: [
                      fileName == null
                          ? Icon(
                              Icons.insert_drive_file,
                              color: Colors.grey,
                              size: 80,
                            )
                          : Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.attach_file,
                                      color: Colors.grey,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        fileName,
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              color: Colors.grey[100],
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          _getFile(context);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Choose file",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                onChanged: (value) {
                  fileTitle = value;
                },
                decoration: InputDecoration(
                  labelText: "File Title",
                  filled: true,
                  fillColor: Colors.grey[150],
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey[200], width: 0.5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey[200], width: 0.5)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: double.infinity,
                  color: Theme.of(context).primaryColor,
                  child: FlatButton(
                    onPressed: () async {
                      if (fileTitle.isEmpty) {
                        Fluttertoast.showToast(msg: "empty title");
                      } else if (fileName.isEmpty) {
                        Fluttertoast.showToast(msg: "empty file");
                      } else {
                        showProgress(context, "Saving...");
                        //save file
                        var date = DateTime.now().millisecondsSinceEpoch;
                        final fileFormat =
                            FileFormat(fileName, fileTitle, fileLink, date);
                        bool result = await insertFile(fileFormat.fileToMap());
                        if (result) {
                          dismissProgress();

                          Fluttertoast.showToast(
                              msg: "File added",
                              toastLength: Toast.LENGTH_SHORT);
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text(
                      "Save File",
                      style: TextStyle(color: Colors.white),
                    ),
                  ))
            ],
          ),
        ));
  }

  Future _getFile(BuildContext context) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _file = File(result.files.single.path);
      PlatformFile fileInfo = result.files.first;

      print("fileName: ${fileInfo.name}");
      setState(() {
        fileName = fileInfo.name;
      });
    }

    showProgress(context, "Uploading...");
    //upload to fireStorage
    FirebaseStorage fs = FirebaseStorage.instance;
    StorageReference storageReference = fs.ref();

    storageReference
        .child("files")
        .child(fileName)
        .putFile(_file)
        .onComplete
        .then((task) async {
      fileLink = await task.ref.getDownloadURL();

      dismissProgress();
    });
  }
}
