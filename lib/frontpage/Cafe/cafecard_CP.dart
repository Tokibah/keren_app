import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keren_app/frontpage/ModalFront/cafe_repo.dart';
import 'package:keren_app/main.dart';

class CafeCard extends StatefulWidget {
  const CafeCard({
    super.key,
    required this.isPromoType,
    required this.cafes,
    required this.onCardTapped,
  });

  final bool isPromoType;
  final List<Cafe> cafes;
  final Function(Cafe) onCardTapped;

  @override
  State<CafeCard> createState() => _CafeCardState();
}

class _CafeCardState extends State<CafeCard> {
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    Widget cafeCardContent(Cafe cafe) {
      return Padding(
        padding: EdgeInsets.all(10.r),
        child: Container(
          height: 200.h,
          width: isPortrait ? null : 250.w,
          decoration: BoxDecoration(
            border: Border.all(
                width: 2,
                color: isLightTheme
                    ? ThemeProvider.darkColor
                    : ThemeProvider.lightColor),
            borderRadius: BorderRadius.circular(20),
          ),
///////////////////////////////////////////////////////////////////
          child: Row(children: [
            Container(
              margin: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                  color: ThemeProvider.highlightColor,
                  borderRadius: BorderRadius.circular(10)),
              width: isPortrait ? 150.w : 100.w,
              height: double.infinity,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: cafe.images!.isNotEmpty
                      ? Image.network(
                          cafe.images![0],
                          loadingBuilder: (context, child, loadingProgress) {
                            return loadingProgress == null
                                ? child
                                : const LinearProgressIndicator();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset("assets/gambar/blankcov.jpeg");
                          },
                          fit: BoxFit.fill,
                        )
                      : Image.asset("assets/gambar/blankcov.jpeg",
                          fit: BoxFit.fill),
                ),
              ),
            ),
///////////////////////////////////////////////////////////////////
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.r),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cafe.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Expanded(
                        child: Text(
                          cafe.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
///////////////////////////////////////////////////////////////////
                      Row(children: [
                        Text(
                          cafe.isRead ? 'READ' : 'NEW',
                          style: TextStyle(
                              color: cafe.isRead ? null : Colors.black,
                              fontWeight: cafe.isRead ? null : FontWeight.bold,
                              backgroundColor: cafe.isRead
                                  ? null
                                  : ThemeProvider.highlightColor,
                              fontSize: 15),
                        ),
                        const Spacer(),
///////////////////////////////////////////////////////////////////
                        RatingBarIndicator(
                          rating: cafe.rating,
                          itemSize: isPortrait ? 25.sp : 15.sp,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                        ),
                      ])
                    ]),
              ),
            ),
          ]),
        ),
      );
    }

    return SizedBox(
      height: isPortrait ? 400.h : 300.h,
      width: isPortrait ? 450.w : null,
      child: Scrollbar(
        child: ReorderableListView.builder(
          scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
          itemCount: widget.cafes.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final cafe = widget.cafes.removeAt(oldIndex);
              widget.cafes.insert(newIndex, cafe);
            });
          },
          itemBuilder: (context, index) {
            final cafe = widget.cafes[index];
            if (cafe.hasPromotion != widget.isPromoType) {
              return SizedBox.shrink(
                key: ValueKey(cafe.label),
              );
            }

///////////////////////////////////////////////////////////////////
            return Dismissible(
              key: ValueKey(cafe.label),
              direction: isPortrait
                  ? DismissDirection.horizontal
                  : DismissDirection.vertical,
              onDismissed: (_) => Cafe.deleteCafe(cafe.label),
              child: GestureDetector(
                onTap: () async {
                  await Cafe.markAsRead(cafe.label);
                  widget.onCardTapped(cafe);
                },
                child: cafe.hasPromotion
                    ? Banner(
                        message: 'PROMO',
                        location: BannerLocation.topEnd,
                        child: cafeCardContent(cafe),
                      )
                    : cafeCardContent(cafe),
              ),
            );
          },
        ),
      ),
    );
  }
}
