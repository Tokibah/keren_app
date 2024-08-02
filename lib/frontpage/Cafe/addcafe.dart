import 'dart:io';
import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keren_app/frontpage/ModalFront/cafe_repo.dart';
import 'package:permission_handler/permission_handler.dart';

class AddCafe extends StatefulWidget {
  const AddCafe({super.key});

  @override
  State<AddCafe> createState() => _AddCafeState();
}

class _AddCafeState extends State<AddCafe> {
  final _formKey = GlobalKey<FormState>();
  final _cafeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<File> _selectedImages = [];
  String? _selectedCafeType;
  RangeValues _priceRange = const RangeValues(20, 50);
  bool _hasPromotion = false;
  DateTimeRange? _promotionTime;
  double _rating = 0.0;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.mediaLibrary,
      Permission.camera,
    ].request();
  }

  Future<void>? _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    setState(() {
      _promotionTime = pickedRange;
    });
  }

  Future<String>? _getLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final placemark = placemarks.first;

    return "${placemark.country}/${placemark.administrativeArea}/${placemark.locality}/${placemark.street}";
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(imageQuality: 50);

    if (pickedFiles.isNotEmpty && _selectedImages.length + pickedFiles.length <= 3) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    } else {
      _showSnackBar("Please select up to 3 images only.");
    }
  }

  Future<void> _captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null && _selectedImages.length < 3) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    } else {
      _showSnackBar("Please select up to 3 images only.");
    }
  }

  String _generateLabel() {
    final wordPair = WordPair.random();
    final middleChar = String.fromCharCode(Random().nextInt(26) + 65);
    final endNum = Random().nextInt(100);
    return "C-${wordPair.asPascalCase}$middleChar$endNum";
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _getLocation();

      final newCafe = Cafe(
        isRead: false,
        location: await _getLocation(),
        title: _cafeNameController.text,
        description: _descriptionController.text,
        priceRange: _priceRange,
        cafeType: _selectedCafeType!,
        hasPromotion: _hasPromotion,
        promotionTime: _promotionTime,
        label: _generateLabel(),
        rating: _rating,
      );

      await Cafe.addCafe(newCafe, _selectedImages);
      _showSnackBar("Cafe Added");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 450.w, //everything size
              child: Column(children: [
                SizedBox(height: 10.h),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select cafe type',
                  ),
                  value: _selectedCafeType,
                  items: const [
                    DropdownMenuItem(value: 'Maid', child: Text('Maid')),
                    DropdownMenuItem(
                        value: 'Ice Cream', child: Text('Ice Cream')),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCafeType = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please choose cafe type' : null,
                ),
///////////////////////////////////////////////////////////////////
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: TextFormField(
                      controller: _cafeNameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.coffee),
                        hintText: 'Cafe name...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please fill cafe name...' : null,
                    )),
///////////////////////////////////////////////////////////////////
                const Text('Price Range:'),
                RangeSlider(
                  min: 0,
                  max: 500,
                  divisions: 100,
                  values: _priceRange,
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                  labels: RangeLabels(
                    _priceRange.start.round().toString(),
                    _priceRange.end.round().toString(),
                  ),
                ),
///////////////////////////////////////////////////////////////////
                RadioListTile(
                  value: true,
                  groupValue: _hasPromotion,
                  onChanged: (_) {
                    setState(() {
                      _hasPromotion = !_hasPromotion;
                    });
                  },
                  title: const Text('Promotion'),
                ),
                if (_hasPromotion)
                  ElevatedButton(
                    onPressed: _selectDateRange,
                    child: const Text('Choose promo time'),
                  ),
                SizedBox(height: 20.h),
///////////////////////////////////////////////////////////////////
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text("Upload photo"),
                  ),
                  ElevatedButton(
                    onPressed: _captureImage,
                    child: const Text('Camera'),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_selectedImages.length, (index) {
                    return GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(5.r),
                        height: 130.r,
                        width: 130.r,
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
                ),
///////////////////////////////////////////////////////////////////
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: RatingBar.builder(
                    allowHalfRating: true,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                ),
///////////////////////////////////////////////////////////////////
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Cafe description...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
                ),
///////////////////////////////////////////////////////////////////
                Padding(
                  padding: EdgeInsets.all(8.r),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Icon(Icons.add),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
