import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keren_app/secondpage/ModalSecond/photo_repo.dart';

class PhotoGrid extends StatefulWidget {
  const PhotoGrid({super.key});

  @override
  State<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  int currentPage = 1;
  int totalPages = 0;
  int itemsPerPage = 9;
  List<Photo> photos = [];
  List<dynamic> pagination = [];
  bool isDisposed = false;

  Future<void> initializePhotos() async {
    totalPages = await fetchPageCount(itemsPerPage);
    await updatePhotos(currentPage);
  }

  Future<void> updatePhotos(int page) async {
    if (isDisposed) return;

    setState(() {
      currentPage = page;
      photos = [];
    });

    photos = await fetchPhotos(itemsPerPage, page - 1);

    setState(() {
      pagination = _generatePagination(page, totalPages);
    });
  }

  List<dynamic> _generatePagination(int current, int total) {
    if (total <= 5) {
      return List.generate(total, (index) => index + 1);
    }

    if (current < 3) {
      return [1, 2, 3, '...', total];
    } else if (current <= 3) {
      return [1, 2, 3, 4, '...', total];
    } else if (current == total - 2) {
      return [1, '...', total - 3, total - 2, total - 1, total];
    } else if (current > total - 2) {
      return [1, '...', total - 2, total - 1, total];
    }

    return [1, '...', current - 1, current, current + 1, '...', total];
  }

  @override
  void initState() {
    super.initState();
    initializePhotos();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        color: Colors.grey,
        height: 450.h,
        width: 550.w,
        child: GridView.builder(
          itemCount: photos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Image.network(
                photos[index].link,
                height: 100.h,
                width: 100.w,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  return loadingProgress == null
                      ? child
                      : Center(
                          child: SizedBox(
                            height: 30.h,
                            width: 30.w,
                            child: const CircularProgressIndicator(),
                          ),
                        );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            );
          },
        ),
      ),
///////////////////////////////////////////////////////////////////
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (int i = 0; i < pagination.length; i++)
          GestureDetector(
            onTap: () {
              if (pagination[i] != '...') {
                updatePhotos(pagination[i]);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '${pagination[i]}',
                style: TextStyle(
                  fontSize: 25,
                  backgroundColor: currentPage == pagination[i]
                      ? Colors.grey
                      : Colors.transparent,
                ),
              ),
            ),
          ),
      ]),
    ]);
  }
}
