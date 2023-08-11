import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';

class MultiPageBottomSheet extends StatefulWidget {
  final List<Widget> pages;
  final Function(dynamic data) onNextPage;

  const MultiPageBottomSheet(
      {Key? key, required this.pages, required this.onNextPage})
      : super(key: key);

  @override
  State<MultiPageBottomSheet> createState() => _MultiPageBottomSheetState();
}

class _MultiPageBottomSheetState extends State<MultiPageBottomSheet> {
  int _currentPage = 0;
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: widget.pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) => widget.pages[index],
              ),
            ),
            _buildBottomSheetControls(),
          ],
        ));
  }

  Widget _buildBottomSheetControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            if (_currentPage > 0) {
              setState(() {
                _currentPage--;
              });
            }
          },
          child: Text(_i18n.translate("previous_step")),
        ),
        ElevatedButton(
          onPressed: () {
            if (_currentPage < widget.pages.length - 1) {
              setState(() {
                _currentPage++;
              });
            }
          },
          child: Text(_i18n.translate("next_step")),
        ),
      ],
    );
  }
}
