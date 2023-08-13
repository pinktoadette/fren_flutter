import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';

class ImageDimension extends StatefulWidget {
  final Function(String dimention) onSelectedDimention;

  const ImageDimension({Key? key, required this.onSelectedDimention})
      : super(key: key);

  @override
  State<ImageDimension> createState() => _ImageDimensionState();
}

class _ImageDimensionState extends State<ImageDimension> {
  final List<Script> script = [];
  String _selectedDimension = "480v";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startCarousel() {
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Select dimension "),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDimension = "480v";
              });
            },
            child: Container(
              width: 120,
              height: 240,
              color:
                  _selectedDimension == "480v" ? APP_ACCENT_COLOR : Colors.grey,
              child: const Center(
                  child: Text(
                "background",
                style: TextStyle(color: Colors.black),
              )),
            ),
          ),
          const SizedBox(
            height: 20,
            width: 20,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDimension = ""; // Square selected
              });
            },
            child: Container(
              width: 120,
              height: 120,
              color: _selectedDimension == "" ? APP_ACCENT_COLOR : Colors.grey,
              child: const Center(
                  child: Text(
                "In story",
                style: TextStyle(color: Colors.black),
              )),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      TextButton(
          onPressed: () {
            widget.onSelectedDimention(_selectedDimension);
          },
          child: const Text("OK"))
    ]);
  }
}
