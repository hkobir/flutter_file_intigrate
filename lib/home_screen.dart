import 'package:flutter/material.dart';
import 'package:flutter_file_intigrate/resourses_screen.dart';
import 'package:flutter_file_intigrate/upload_screen.dart';

class Home extends StatefulWidget {
  String phoneNo;

  Home({this.phoneNo});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User: ${widget.phoneNo}"),
      ),
      body: Resources(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.amberAccent,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddFile()));
        },
      ),
    );
  }
}
