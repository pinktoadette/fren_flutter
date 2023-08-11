import 'package:machi_app/datas/gallery.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/image/image_expand.dart';
import 'package:machi_app/widgets/story_cover.dart';

class GalleryWidget extends StatefulWidget {
  final List<Gallery> gallery;
  const GalleryWidget({Key? key, required this.gallery}) : super(key: key);

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.gallery.isEmpty) {
      return Container(
        height: 20,
        alignment: Alignment.center,
        child: const Text("Empty Gallery"),
      );
    }
    return SizedBox(
        height: size.width / 3,
        child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.gallery.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                  width: size.width / 3,
                  height: size.width / 3,
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the expanded image page
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpandedImagePage(gallery: widget.gallery[index]),
                        ),
                      );
                    },
                    child: StoryCover(
                      radius: 0,
                      photoUrl: widget.gallery[index].photoUrl,
                      title: widget.gallery[index].caption,
                    ),
                  ));
            }));
  }
}
