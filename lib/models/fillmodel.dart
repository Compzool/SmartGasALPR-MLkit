import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FillModel {
  String? fillId;
  final double quantity;
  final String station;
  final Timestamp date;
  FillModel(
      {required this.quantity,
      required this.station,
      required this.date,
      this.fillId});

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'station': station,
        'date': date,
        'fillId': fillId,
      };

  static FillModel fromJson(Map<String, dynamic> json, String id) => FillModel(
        quantity: json['quantity'],
        station: json['station'],
        date: json['date'],
        fillId: id,
      );
}