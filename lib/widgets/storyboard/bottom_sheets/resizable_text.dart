import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

class ResizableBox extends StatefulWidget {
  final String initialText;

  const ResizableBox({required this.initialText});

  @override
  State<ResizableBox> createState() => _ResizableBoxState();
}

class _ResizableBoxState extends State<ResizableBox> {
  double width = 100.0;
  Offset offset = Offset(0, 0);
  bool isFocused = true;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText;
  }

  void _resize(double newWidth) {
    setState(() {
      width = newWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          _baseScaleFactor = _scaleFactor;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scaleFactor = _baseScaleFactor * details.scale;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            offset = Offset(
              offset.dx + details.delta.dx,
              offset.dy + details.delta.dy,
            );
          });
        },
        onTap: () {
          setState(() {
            isFocused = true;
          });
        },
        child: Stack(
          children: [
            SizedBox(
              width: width,
              child: Container(
                decoration: BoxDecoration(
                  border: isFocused
                      ? Border.all(
                          color: APP_ACCENT_COLOR,
                          width: 1.0,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
                child: TextFormField(
                  maxLines: null,
                  textAlign: TextAlign.center,
                  controller: _textController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                      inherit: true,
                      color: APP_INVERSE_PRIMARY_COLOR,
                      shadows: [
                        Shadow(
                            // bottomLeft
                            offset: Offset(-1.0, -1.0),
                            color: APP_PRIMARY_COLOR),
                        Shadow(
                            // bottomRight
                            offset: Offset(1.0, -1.0),
                            color: APP_PRIMARY_COLOR),
                        Shadow(
                            // topRight
                            offset: Offset(1.0, 1.0),
                            color: APP_PRIMARY_COLOR),
                        Shadow(
                            // topLeft
                            offset: Offset(-1.0, 1.0),
                            color: APP_PRIMARY_COLOR),
                      ]),
                ),
              ),
            ),
            if (isFocused)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isFocused = false;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
