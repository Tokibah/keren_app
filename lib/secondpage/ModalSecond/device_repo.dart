import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  String name;
  bool isActive;
  String label;

  Device({required this.name, required this.isActive, required this.label});

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      name: map['name'],
      isActive: map['isActive'],
      label: map['label'],
    );
  }

  static final firestore = FirebaseFirestore.instance;

  static Future<List<Device>> getDevices() async {
    try {
      final deviceCollection = await firestore.collection('Device').get();
      return deviceCollection.docs
          .map((doc) => Device.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('ERROR GETDEVICES: $e');
      return [];
    }
  }

  static Future<void> updateDeviceStatus(String label, bool isActive) async {
    try {
      await firestore.collection('Device').doc(label).update({'isActive': isActive});
    } catch (e) {
      print('ERRRO UPDATEDEVICESTATUS: $e');
    }
  }

  static updateDevice(String label, bool type) {}
}
