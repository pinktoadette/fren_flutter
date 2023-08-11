import 'package:dio/dio.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/gallery_api.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/image/image_expand.dart';
import 'package:machi_app/widgets/story_cover.dart';

class LatestGallery extends StatefulWidget {
  final Function(String)? onFileTap;

  const LatestGallery({
    Key? key,
    this.onFileTap,
  }) : super(key: key);

  @override
  State<LatestGallery> createState() => _LatestGalleryWidgetState();
}

class _LatestGalleryWidgetState extends State<LatestGallery> {
  final _galleryApi = GalleryApi();
  final PagingController<int, Gallery> _pagingController =
      PagingController(firstPageKey: 0);

  List<Gallery> galleries = [];
  final _cancelToken = CancelToken();

  final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    childAspectRatio: 100 / 150,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    crossAxisCount: 3,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchGallery(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
    _cancelToken.cancel();
  }

  Future<void> _fetchGallery(int pageKey) async {
    try {
      final List<Gallery> gal = await _galleryApi.allGallery(
        page: pageKey,
        cancelToken: _cancelToken,
      );
      final isLastPage = gal.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(gal);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(gal, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations i18n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            i18n.translate("gallery"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: PagedGridView<int, Gallery>(
          showNewPageProgressIndicatorAsGridChild: false,
          showNewPageErrorIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: _pagingController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            crossAxisCount: 3,
          ),
          builderDelegate: PagedChildBuilderDelegate<Gallery>(
              itemBuilder: (context, item, index) => InkWell(
                    onTap: () {
                      if (widget.onFileTap != null) {
                        widget.onFileTap!(item.photoUrl);
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ExpandedImagePage(gallery: item),
                          ),
                        );
                      }
                    },
                    child: StoryCover(
                      radius: 0,
                      photoUrl: item.photoUrl,
                      title: item.caption,
                    ),
                  )),
        ));
  }
}
