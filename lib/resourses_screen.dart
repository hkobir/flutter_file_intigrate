import 'dart:isolate';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Resources extends StatefulWidget {
  @override
  _ResourcesState createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  int progress = 0;
  ReceivePort _receivePort = ReceivePort();
  BuildContext dialogContext;

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort.send([id, status, progress]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");

    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progress = message[2]; //index2 from sendPort
      });

      print(progress);

    });

    FlutterDownloader.registerCallback(downloadingCallback);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("files").snapshots(),
      builder: (context, querySnapshot) {
        if (querySnapshot.hasError) {
          Fluttertoast.showToast(msg: "Some error!");
          print("error: " + querySnapshot.error.toString());
          return Text("Some snapshot  Error");
        }
        if (querySnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (querySnapshot.data.docs.length <= 0 ||
            querySnapshot.data.docs == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 28,
                  color: Colors.red,
                ),
                Text(
                  "Empty File!",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          );
        }
        if (querySnapshot.hasData) {
          return buildData(context, querySnapshot.data.docs);
        }
      },
    );
  }

  Widget buildData(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView.separated(
      itemCount: snapshot.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot[index].data()['title'],
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    snapshot[index].data()['name'],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            (snapshot[index].data()['timeMillis']))),
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  )
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  size: 30,
                  color: Colors.deepOrange,
                ),
                onPressed: () async {
                  String fileLink = snapshot[index].data()['fileLink'];
                  final status = await Permission.storage.request();
                  if (status.isGranted) {
                    final externalDir = await getExternalStorageDirectory();
                    final id = await FlutterDownloader.enqueue(
                      url: fileLink,
                      savedDir: externalDir.path,
                      fileName: snapshot[index].data()['name'],
                      showNotification: true,
                      openFileFromNotification: true,
                    );

                  } else {
                    print("Permission denied");
                  }
                },
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          thickness: 1,
        );
      },
    );
  }




}
