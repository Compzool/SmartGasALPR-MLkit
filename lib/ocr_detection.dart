import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:text_recognition/models/fillmodel.dart';

class OCRPage extends StatelessWidget {
   OCRPage({Key? key,required this.userID}) : super(key: key);
   String userID;
  TextEditingController _fill = TextEditingController();
  TextEditingController _station = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

 @override
  Widget build(BuildContext context) {
    return Scaffold(  
        appBar: AppBar(  
          title: Text('ADMIN SMARTGAS'),  
        ),  
        body: Padding(  
            padding: EdgeInsets.all(15),  
            child: Column(  
              children: <Widget>[  
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    controller: _station,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      labelText: 'Enter Station',  
                      hintText: 'current station',  
                    ),  
                  ),  
                ),  
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    controller: _fill, 
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      labelText: 'Enter Fill',  
                      hintText: 'Enter ammount',  
                    ),  
                  ),  
                ),  
                ElevatedButton(
                  child: Text("TA7YI LAL SHORAFA2"),
                  style: ElevatedButton.styleFrom(
                    textStyle:TextStyle(color: Colors.white),
                    primary: Colors.greenAccent
                   
                  ),
                  onPressed: (){
                    FillModel fill = FillModel(quantity: double.parse(_fill.text.trim()), station: _station.text, date: Timestamp.now());
                    addFill(fill);
                  },  
                )  
              ],  
            )  
        )  
    );  
  }

  Future addFill(FillModel fill) async {
    try {
      await _firestore
          .collection("users")
          .doc(userID)
          .collection("fills")
          .add({
        'quantity': fill.quantity,
        'station': fill.station,
        'date': fill.date,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}


  
 
