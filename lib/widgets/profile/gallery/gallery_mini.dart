import 'package:dio/dio.dart';
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
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken.cancel();
  }

  void _fetchGallery() async {
    if (!mounted) {
      return;
    }
    List<Gallery> gal = await _galleryApi.getUserGallery(
        userId: widget.userId, page: 0, cancelToken: _cancelToken);
    setState(() {
      galleries = gal;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (galleries.isEmpty) {
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
            itemCount: galleries.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                  width: size.width / 3,
                  height: size.width / 3,
                  child: StoryCover(
                    photoUrl: galleries[index].photoUrl,
                    title: galleries[index].caption,
                  ));
            }));
  }
}
