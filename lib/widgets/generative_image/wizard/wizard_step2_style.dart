import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/helpers/app_localizations.dart';

class WizardImageStyle extends StatefulWidget {
  final Function(String dimension) onSelectedStyle;

  const WizardImageStyle({Key? key, required this.onSelectedStyle})
      : super(key: key);

  @override
  State<WizardImageStyle> createState() => _WizardImageStyleState();
}

class _WizardImageStyleState extends State<WizardImageStyle> {
  final List<Script> script = [];
  String _selectedStyle = "sdxl";

  List<Map<String, dynamic>> imageKeyLookup = [
    {
      "model": "sdxl",
      "name": "",
      "imagePath": "assets/images/ai_style/sd.png",
    },
    {
      "model": "anime", // anythingv3
      "name": "anime*",
      "imagePath": "assets/images/ai_style/anime.png",
    },
    {
      "model": "dall-e",
      "name": "Dall-E",
      "imagePath": "assets/images/ai_style/dall-e.png",
    },
    {
      "model": "",
      "name": "None. Input manually.",
      "imagePath": "",
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setStyle(String styleInfo) {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedStyle = styleInfo;
    });
    widget.onSelectedStyle(styleInfo);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Text(i18n.translate("creative_mix_ai_select_style")),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Example prompt: close up, girl with pink sundress walking in the green fields, detailed eyes",
                style: TextStyle(fontSize: 14),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: imageKeyLookup.length,
                shrinkWrap:
                    true, // Allow the grid to take only the space it needs
                itemBuilder: (context, index) {
                  var styleInfo = imageKeyLookup[index];
                  if (index == imageKeyLookup.length - 1) {
                    return OutlinedButton(
                      onPressed: () {
                        widget.onSelectedStyle("");
                        setState(() {
                          _selectedStyle = "";
                        });
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                          (Set<MaterialState> states) {
                            if (_selectedStyle == "") {
                              return const BorderSide(
                                color: APP_ACCENT_COLOR,
                                width: 2.0,
                              );
                            }
                            return const BorderSide(
                              color: Colors.transparent,
                              width: 2.0,
                            );
                          },
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      child: const Text("None. I'll input it manually"),
                    );
                  }
                  return _imageSelect(styleInfo: styleInfo);
                },
              ),
              Text(
                "* ${i18n.translate("take_time_to_load")}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageSelect({required Map<String, dynamic> styleInfo}) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: () {
          _setStyle(styleInfo["model"]);
        },
        child: Card(
          elevation: _selectedStyle == styleInfo["model"] ? 8 : 0,
          color: Colors.black, // Set the card color to transparent
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8.0), // Add border radius to the card
            side: BorderSide(
              color: _selectedStyle == styleInfo["model"]
                  ? APP_ACCENT_COLOR
                  : Colors.transparent,
              width: 3.0, // Set the width of the outline
            ),
          ),
          child: Container(
            width: size.width * 0.5 - 60,
            height: size.width * 0.5 - 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(styleInfo["imagePath"]),
                fit: BoxFit.cover, // You can adjust the fit as needed
              ),
            ),
            child: Center(
              child: Text(
                styleInfo["name"],
                style: const TextStyle(
                  color: Colors.white, // Text color for better visibility
                ),
              ),
            ),
          ),
        ));
  }
}
