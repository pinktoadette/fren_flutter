import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/widgets/animations/loader.dart';

// ignore: must_be_immutable
class ThemePrompt extends StatelessWidget {
  InteractiveTheme? selectedTheme;
  List<InteractiveTheme>? themes;
  final Function(dynamic data) onThemeSelected;

  ThemePrompt(
      {Key? key,
      required this.onThemeSelected,
      this.themes,
      this.selectedTheme})
      : super(key: key);

  bool isLoading = false;
  double padding = 20;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (themes == null) {
      return const Center(
        child: Frankloader(),
      );
    }

    return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(left: padding, right: padding),
                child: const Text("Select a theme")),
            ...themes!.map((theme) {
              return InkWell(
                  onTap: () {
                    onThemeSelected(theme);
                  },
                  child: Card(
                    shape: selectedTheme == theme
                        ? RoundedRectangleBorder(
                            side: const BorderSide(
                                color: APP_ACCENT_COLOR, width: 2.0),
                            borderRadius: BorderRadius.circular(20.0),
                          )
                        : RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.transparent, width: 0.0),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(padding / 2),
                      child: Column(
                        children: [
                          Text(
                            theme.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          Row(
                            children: [
                              _buildBox(
                                  theme: theme.backgroundColor,
                                  width: width,
                                  showText: theme),
                              _buildBox(theme: theme.titleColor, width: width),
                              _buildBox(theme: theme.textColor, width: width),
                            ],
                          )
                        ],
                      ),
                    ),
                  ));
            })
          ],
        ));
  }

  Widget _buildBox(
      {required String theme,
      required double width,
      InteractiveTheme? showText}) {
    double w = (showText != null ? width / 2 : width / 4) - padding * 1.5;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(10),
      width: w,
      height: showText != null ? w / 2 : w,
      decoration: BoxDecoration(
        color: Color(int.parse("0xFF$theme")),
        borderRadius: BorderRadius.circular(10),
      ),
      child: showText != null
          ? Center(
              child: Column(
                children: [
                  Text("A Brown Fox Pangram",
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Color(int.parse("0xFF${showText.titleColor}")))),
                  Text("A brown fox jumps over the lazy dog.",
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(int.parse("0xFF${showText.textColor}"))))
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
