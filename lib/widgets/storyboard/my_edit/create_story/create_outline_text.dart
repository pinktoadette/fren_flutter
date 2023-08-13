import 'package:cached_network_image/cached_network_image.dart';
import 'package:machi_app/datas/script.dart';
import 'package:flutter/material.dart';

class TextUpdate {
  final String selection;
  final int indexStart;
  final int indexEnd;
  final Script original;
  final int pageNum;

  TextUpdate(
      {required this.selection,
      required this.indexStart,
      required this.indexEnd,
      required this.original,
      required this.pageNum});
}

// ignore: must_be_immutable
class CreateOutlineText extends StatefulWidget {
  Script script;
  int pageNum;
  Function(Script update) onUpdatedScript;
  Function(TextUpdate selectText) onSelectedText;
  CreateOutlineText(
      {Key? key,
      required this.script,
      required this.pageNum,
      required this.onUpdatedScript,
      required this.onSelectedText})
      : super(key: key);

  @override
  State<CreateOutlineText> createState() => _CreateOutlineTextState();
}

class _CreateOutlineTextState extends State<CreateOutlineText> {
  final TextEditingController _newTextController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _newTextController.text = widget.script.text ?? "";
    _newTextController.addListener(() {
      _handleFocusChange();
    });
  }

  @override
  void dispose() {
    _newTextController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CreateOutlineText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.script != widget.script) {
      _newTextController.text = widget.script.text ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.script.type == "text")
          Container(
            constraints: const BoxConstraints(
              minHeight: 100.0,
            ),
            child: TextField(
              controller: _newTextController,
              focusNode: _textFocusNode,
              onChanged: (value) {
                _handleFocusChange();
              },
              maxLines: null,
            ),
          ),
        if (widget.script.type == "image")
          CachedNetworkImage(imageUrl: widget.script.image!.uri),
        const Row(
          children: [
            Text("Helper"),
            Text("Add background image"),
          ],
        )
      ],
    );
  }

  void _handleFocusChange() {
    if (_textFocusNode.hasFocus) {
      TextSelection selection = _newTextController.selection;
      if (selection.baseOffset != selection.extentOffset) {
        int startIndex = selection.baseOffset;
        int endIndex = selection.extentOffset;
        TextUpdate update = TextUpdate(
            selection: selection.textInside(_newTextController.text),
            indexStart: startIndex,
            indexEnd: endIndex,
            original: widget.script,
            pageNum: widget.pageNum);
        widget.onSelectedText(update);
      } else {
        Script updated = widget.script.copyWith(text: _newTextController.text);
        widget.onUpdatedScript(updated);
      }
    }
  }
}
