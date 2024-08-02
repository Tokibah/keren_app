import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keren_app/frontpage/Cafe/bigpic_CP_CS.dart';
import 'package:keren_app/frontpage/ModalFront/cafe_repo.dart';
import 'package:keren_app/main.dart';
import 'package:url_launcher/url_launcher.dart';

class CafeSheet extends StatefulWidget {
  const CafeSheet({super.key, required this.cafe});

  final Cafe cafe;

  @override
  State<CafeSheet> createState() => _CafeSheetState();
}

class _CafeSheetState extends State<CafeSheet> {
  void _showBiggerImage(
      BuildContext context, int imageIndex, List<String> images) {
    showDialog(
      context: context,
      builder: (context) {
        return ShowBiggerPicture(initIndex: imageIndex, images: images);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    final promotionStart = widget.cafe.promotionTime?.start;
    final promotionEnd = widget.cafe.promotionTime?.end;

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      maxChildSize: 0.9,
      minChildSize: isPortrait ? 0.03 : 0.05,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          color: Colors.grey[isLightTheme ? 300 : 900],
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(children: [
              Container(
                margin: EdgeInsets.all(10.r),
                height: 15.h,
                width: 70.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[isLightTheme ? 700 : 100],
                ),
              ),
///////////////////////////////////////////////////////////////////
              TextButton(
                onPressed: () async {
                  final url =
                      Uri.parse('https://social.mtdv.me/giveaways/0XqgThFf20');
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  } catch (e) {
                    print('URL LAUNCH ERROR: $e');
                  }
                },
                child: const Text(
                  'Our Website',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
///////////////////////////////////////////////////////////////////
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                for (int index = 0; index < widget.cafe.images!.length; index++)
                  GestureDetector(
                    onTap: () =>
                        _showBiggerImage(context, index, widget.cafe.images!),
                    child: ClipOval(
                      child: Image.network(
                        widget.cafe.images![index],
                        fit: BoxFit.cover,
                        width: 180.sp,
                        height: 180.sp,
                        loadingBuilder: (context, child, loadingProgress) {
                          return loadingProgress == null
                              ? child
                              : const CircularProgressIndicator();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/gambar/blankcov.jpeg",
                            width: 170.sp,
                            height: 170.sp,
                          );
                        },
                      ),
                    ),
                  )
              ]),
///////////////////////////////////////////////////////////////////
              Padding(
                padding: EdgeInsets.all(10.r),
                child: SelectableText(
                  '${widget.cafe.title} (${widget.cafe.cafeType})',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              RatingBarIndicator(
                rating: widget.cafe.rating,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
              ),
///////////////////////////////////////////////////////////////////
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text(
                  "\$${widget.cafe.priceRange.start} - \$${widget.cafe.priceRange.end}",
                  style: const TextStyle(fontSize: 15),
                ),
                if (widget.cafe.hasPromotion)
                  Text(
                    "Promotion time:\n${promotionStart?.day}/${promotionStart?.month}/${promotionStart?.year} - ${promotionEnd?.day}/${promotionEnd?.month}/${promotionEnd?.year}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
              ]),
///////////////////////////////////////////////////////////////////
              SizedBox(
                  width: 200.w,
                  child: Text(
                    widget.cafe.location!,
                    textAlign: TextAlign.center,
                  )),
///////////////////////////////////////////////////////////////////
              Container(
                margin: EdgeInsets.all(10.r),
                height: 350.h,
                width: isPortrait ? 500.w : 900.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isLightTheme
                        ? ThemeProvider.darkColor
                        : ThemeProvider.lightColor,
                  ),
                ),
                child: Text(widget.cafe.description),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(widget.cafe.label),
              ),
            ]),
          ),
        );
      },
    );
  }
}
