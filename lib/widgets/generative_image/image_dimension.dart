import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';

class ImageStyleDimension extends StatefulWidget {
  final Function(String dimension) onSelectedStyleDimension;

  const ImageStyleDimension({Key? key, required this.onSelectedStyleDimension})
      : super(key: key);

  @override
  State<ImageStyleDimension> createState() => _ImageDimensionState();
}

class _ImageDimensionState extends State<ImageStyleDimension> {
  final List<Script> script = [];
  String _selectedDimension = "480v";
  String _selectedStyle = "sd";

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
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
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
                  color: _selectedDimension == "480v"
                      ? APP_ACCENT_COLOR
                      : Colors.grey,
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
                  color:
                      _selectedDimension == "" ? APP_ACCENT_COLOR : Colors.grey,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStyle = "sd";
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        child: const Text("stable diffusion"),
                      )),
                  const SizedBox(width: 20),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStyle = "open-journey";
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        child: const Text("cartoon"),
                      )),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStyle = "epic-realism";
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        child:
                            const Text("Epic Realism* \nmay take long to load"),
                      )),
                  const SizedBox(width: 20),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStyle = "dall-e";
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        child: const Text("Dall-E"),
                      )),
                ],
              ),
            ],
          ),
          TextButton(
              onPressed: () {
                widget.onSelectedStyleDimension(
                    "$_selectedDimension ${_selectedStyle.toLowerCase()}");
              },
              child: const Text("OK"))
        ]));
  }
}
