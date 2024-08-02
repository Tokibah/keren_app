import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keren_app/main.dart';
import 'package:share_plus/share_plus.dart';

class ShowBiggerPicture extends StatefulWidget {
  const ShowBiggerPicture(
      {super.key, required this.initIndex, required this.images});

  final int initIndex;
  final List<String> images;

  @override
  State<ShowBiggerPicture> createState() => _ShowBiggerPictureState();
}

class _ShowBiggerPictureState extends State<ShowBiggerPicture> {
  late PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initIndex;
    pageController = PageController(initialPage: widget.initIndex + 12);
  }

  Future<void> shareImages() async {
    try {
      final tempDir = Directory.systemTemp;
      List<XFile> xFiles = [];

      for (String imageUrl in widget.images) {
        final response = await Dio()
            .get(imageUrl, options: Options(responseType: ResponseType.bytes));

        if (response.statusCode == 200) {
          final filePath =
              '${tempDir.path}/temp_image${widget.images.indexOf(imageUrl)}.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.data);

          xFiles.add(XFile(filePath));
        }
      }

      if (xFiles.isNotEmpty) {
        await Share.shareXFiles(xFiles, text: 'Check out these images!');
      } else {
        print('ShareXFileError: No images to share');
      }
    } catch (e) {
      print('ShareError: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 500.sp,
        width: 600.sp,
        child: Column(children: [
          IconButton(
            onPressed: shareImages,
            icon: Icon(Icons.share, size: 30.r),
          ),
///////////////////////////////////////////////////////////////////
          Expanded(
            child: PageView.builder(
              itemCount: widget.images.length + 31,
              controller: pageController,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemBuilder: (context, index) {
                final alterIndex = index % widget.images.length;
                return InteractiveViewer(
                  child: Image.network(
                    widget.images[alterIndex],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      return loadingProgress == null
                          ? child
                          : const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("assets/gambar/blankcov.jpeg");
                    },
                  ),
                );
              },
            ),
          ),
///////////////////////////////////////////////////////////////////
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              onPressed: () {
                int previousPage = pageController.page!.round() - 1;
                pageController.jumpToPage(
                    previousPage < 0 ? widget.images.length - 1 : previousPage);
              },
              icon: const Icon(Icons.arrow_left_rounded),
            ),
///////////////////////////////////////////////////////////////////
            Row(children: [
              for (var i = 0; i < widget.images.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() => currentIndex = i);
                    pageController.jumpToPage(i);
                  },
                  child: Container(
                    margin: EdgeInsets.all(5.r),
                    height: 20.r,
                    width: 20.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex % widget.images.length ==
                              i % widget.images.length
                          ? ThemeProvider.highlightColor
                          : Colors.grey,
                    ),
                  ),
                )
            ]),
///////////////////////////////////////////////////////////////////
            IconButton(
              onPressed: () {
                int nextPage = pageController.page!.round() + 1;
                pageController.jumpToPage(
                    nextPage >= widget.images.length ? 0 : nextPage);
              },
              icon: const Icon(Icons.arrow_right_rounded),
            ),
          ]),
        ]),
      ),
    );
  }
}
