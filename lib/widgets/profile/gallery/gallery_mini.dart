import 'package:machi_app/api/machi/gallery_api.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/story_cover.dart';

class GalleryWidget extends StatefulWidget {
  final String userId;
  const GalleryWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _GalleryWidgetState createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  final _galleryApi = GalleryApi();
  List<Gallery> galleries = [];
  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  void _fetchGallery() async {
    List<Gallery> gal =
        await _galleryApi.getUserGallery(userId: widget.userId, page: 0);
    setState(() {
      galleries = gal;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: galleries.length,
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
              width: width / 3,
              height: width / 3,
              child: StoryCover(
                photoUrl: galleries[index].photoUrl,
                title: galleries[index].caption,
              ));
        });
  }
}
