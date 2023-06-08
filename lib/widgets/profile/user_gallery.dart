import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/gallery_api.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/story_cover.dart';

class UserGallery extends StatefulWidget {
  final String userId;
  final Function(String)? onFileTap;

  const UserGallery({Key? key, required this.userId, this.onFileTap})
      : super(key: key);

  @override
  _GalleryWidgetState createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<UserGallery> {
  final _galleryApi = GalleryApi();
  final PagingController<int, Gallery> _pagingController =
      PagingController(firstPageKey: 0);

  List<Gallery> galleries = [];
  static const int _pageSize = 30;

  final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    childAspectRatio: 100 / 150,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    crossAxisCount: 3,
  );

  @override
  void initState() {
    super.initState();
    _fetchGallery(0);
  }

  void _fetchGallery(int pageKey) async {
    try {
      List<Gallery> newItems = await _galleryApi.getUserGallery(
          userId: widget.userId, page: pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
    List<Gallery> gal =
        await _galleryApi.getUserGallery(userId: widget.userId, page: 0);
    setState(() {
      galleries = gal;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("gallery"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: PagedGridView<int, Gallery>(
          showNewPageProgressIndicatorAsGridChild: false,
          showNewPageErrorIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: _pagingController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 100 / 150,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
          ),
          builderDelegate: PagedChildBuilderDelegate<Gallery>(
              itemBuilder: (context, item, index) => InkWell(
                    onTap: () {
                      if (widget.onFileTap != null) {
                        widget.onFileTap!(item.photoUrl);
                        Navigator.pop(context);
                      }
                    },
                    child: StoryCover(
                        photoUrl: item.photoUrl, title: item.caption),
                  )),
        ));
  }
}
