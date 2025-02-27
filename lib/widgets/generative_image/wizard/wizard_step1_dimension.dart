import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/helpers/app_localizations.dart';

enum Dimension {
  vertical,
  square,
}

extension DimensionExtension on Dimension {
  String get value {
    switch (this) {
      case Dimension.vertical:
        return "480v";
      case Dimension.square:
        return "";
    }
  }
}

class WizardImageDimension extends StatefulWidget {
  /// disable content image
  final bool? disableContentImage;

  final Function(String dimension) onSelectedDimension;

  const WizardImageDimension(
      {Key? key,
      this.disableContentImage = false,
      required this.onSelectedDimension})
      : super(key: key);

  @override
  State<WizardImageDimension> createState() => _WizardImageDimensionState();
}

class _WizardImageDimensionState extends State<WizardImageDimension> {
  final List<Script> script = [];
  late String _selectedDimension;

  @override
  void initState() {
    super.initState();
    _setSelection();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(WizardImageDimension oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disableContentImage != oldWidget.disableContentImage) {
      _setSelection();
    }
  }

  void _setSelection() {
    if (widget.disableContentImage == true) {
      _selectedDimension = Dimension.vertical.value;
    } else {
      _selectedDimension = Dimension.square.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);

    return Column(children: [
      Text(i18n.translate("creative_mix_ai_select_dimension")),
      if (widget.disableContentImage == true)
        const Text(
          "In content image disabled in caption mode",
          style: TextStyle(fontSize: 14),
        ),
      const SizedBox(
        height: 20,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _setDimension(Dimension.vertical);
            },
            child: Container(
              width: 120,
              height: 240,
              padding: const EdgeInsets.all(10),
              color: _selectedDimension == Dimension.vertical.value
                  ? APP_ACCENT_COLOR
                  : Colors.grey,
              child: Center(
                  child: Text(
                i18n.translate("creative_mix_aiselect_dimension_background"),
                style: const TextStyle(color: Colors.black),
              )),
            ),
          ),
          const SizedBox(
            height: 20,
            width: 20,
          ),
          GestureDetector(
            onTap: () {
              if (widget.disableContentImage == true) {
                return;
              } else {
                _setDimension(Dimension.square);
              }
            },
            child: Container(
              width: 120,
              height: 120,
              color: _selectedDimension == Dimension.square.value
                  ? APP_ACCENT_COLOR
                  : Colors.grey,
              child: Center(
                  child: Text(
                i18n.translate("creative_mix_aiselect_dimension_in_content"),
                style: const TextStyle(color: Colors.black),
              )),
            ),
          ),
        ],
      ),
    ]);
  }

  void _setDimension(Dimension dim) {
    setState(() {
      _selectedDimension = dim.value;
    });
    widget.onSelectedDimension(dim.value);
  }
}
