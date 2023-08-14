import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

class ResizableBox extends StatefulWidget {
  final String initialText;

  const ResizableBox({super.key, required this.initialText});

  @override
  State<ResizableBox> createState() => _ResizableBoxState();
}

class _ResizableBoxState extends State<ResizableBox> {
  double width = 100.0;
  Offset offset = const Offset(0, 0);
  bool isFocused = true;

  final FocusNode _focusNode = FocusNode();

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text =
        widget.initialText == "" ? "No drag and drop yet" : widget.initialText;
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width - 10,
      margin: const EdgeInsets.all(16.0),
      child: Transform.translate(
        offset: offset,
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
            onTap: () => setState(() {
              isFocused = true;
            }),
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                isFocused = false;
              });
            },
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
    );
  }
}
