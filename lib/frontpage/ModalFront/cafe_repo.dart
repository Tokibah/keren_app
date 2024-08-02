import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Cafe {
  bool isRead;
  String? location;
  List<String>? images;
  String title;
  String description;
  RangeValues priceRange; // Price range (Slider value)
  String cafeType;
  bool hasPromotion;
  DateTimeRange? promotionTime;
  String label;
  double rating;

  Cafe({
    required this.isRead,
    required this.location,
    this.images,
    required this.title,
    required this.description,
    required this.priceRange,
    required this.cafeType,
    required this.hasPromotion,
    this.promotionTime,
    required this.label,
    required this.rating,
  });

  factory Cafe.fromMap(Map<String, dynamic> map) {
    return Cafe(
      isRead: map['isRead'] ?? false,
      location: map['location'] ?? 'Unknown',
      images: List<String>.from(map['images'] ?? []),
      title: map['title'] ?? 'unknown',
      description: map['description'] ?? '',
      priceRange: RangeValues((map['priceRange']['start'] as num).toDouble(),
          (map['priceRange']['end'] as num).toDouble()),
      cafeType: map['cafeType'] ?? 'none',
      hasPromotion: map['hasPromotion'] ?? false,
      promotionTime: map['promotionTime'] != null
          ? DateTimeRange(
              start: DateTime.parse(map['promotionTime']['start']),
              end: DateTime.parse(map['promotionTime']['end']))
          : null,
      label: map['label'] ?? '',
      rating: (map['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isRead': isRead,
      'location': location,
      'images': images,
      'title': title,
      'description': description,
      'priceRange': {'start': priceRange.start, 'end': priceRange.end},
      'cafeType': cafeType,
      'hasPromotion': hasPromotion,
      'promotionTime': promotionTime != null
          ? {
              'start': promotionTime!.start.toIso8601String(),
              'end': promotionTime!.end.toIso8601String()
            }
          : null,
      'label': label,
      'rating': rating
    };
  }

  static final firestore = FirebaseFirestore.instance;
  static const collectionName = 'Cafe';

  static Future<List<Cafe>> getAllCafes() async {
    try {
      final snapshot = await firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) => Cafe.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error GETALLCAFES: $e');
      return [];
    }
  }

  static Future<void> addCafe(Cafe cafe, List<File> imageFiles) async {
    try {
      List<String> downloadUrls = [];

      for (var image in imageFiles) {
        final uploadTask = FirebaseStorage.instance
            .ref('images/${DateTime.now().microsecondsSinceEpoch}.jpg')
            .putFile(image);

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      cafe.images = downloadUrls;
      await firestore
          .collection(collectionName)
          .doc(cafe.label)
          .set(cafe.toMap());
    } catch (e) {
      print('Error ADDCAFE $e');
    }
  }

  static Future<void> deleteCafe(String cafeId) async {
    try {
      final docSnap =
          await firestore.collection(collectionName).doc(cafeId).get();
      final cafe = Cafe.fromMap(docSnap.data() as Map<String, dynamic>);

      if (cafe.images != null && cafe.images!.isNotEmpty) {
        for (var url in cafe.images!) {
          await FirebaseStorage.instance.refFromURL(url).delete();
        }
      }

      await firestore.collection(collectionName).doc(cafeId).delete();
    } catch (e) {
      print('Error DELETECAFE: $e');
    }
  }

  static Future<void> markAsRead(String label) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(label)
          .update({'isRead': true});
    } catch (e) {
      print('Error MARKASREAD: $e');
    }
  }
}
