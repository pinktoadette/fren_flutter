import 'package:machi_app/constants/constants.dart';

class InteractiveBoardPrompt {
  final String mainText;
  final List<String> options;

  InteractiveBoardPrompt({required this.mainText, required this.options});

  InteractiveBoardPrompt copyWith({String? mainText, List<String>? options}) {
    return InteractiveBoardPrompt(
        mainText: mainText ?? this.mainText, options: options ?? this.options);
  }

  factory InteractiveBoardPrompt.fromJson(Map<String, dynamic> doc) {
    print(doc);
    return InteractiveBoardPrompt(
        mainText: doc[INTERACTIVE_CURRENT_PROMPT],
        options: doc[INTERACTIVE_CURRENT_CHOICES].cast<String>());
  }
}

class InteractiveBoard {
  final String interactiveId;
  final String prompt;
  final int sequence;
  final bool hidePrompt;
  final String? category;
  final String? summary;
  final String? photoUrl;
  final int? createdAt;
  final int? updatedAt;

  InteractiveBoard(
      {required this.interactiveId,
      required this.prompt,
      required this.sequence,
      required this.hidePrompt,
      this.category,
      this.summary,
      this.photoUrl,
      this.createdAt,
      this.updatedAt});

  InteractiveBoard copyWith(
      {String? photoUrl,
      String? prompt,
      bool? hidePrompt,
      int? sequence,
      String? category,
      String? summary,
      int? updatedAt}) {
    return InteractiveBoard(
        interactiveId: interactiveId,
        prompt: prompt ?? this.prompt,
        hidePrompt: hidePrompt ?? this.hidePrompt,
        sequence: sequence ?? this.sequence,
        photoUrl: photoUrl ?? this.photoUrl,
        category: category ?? this.category,
        summary: summary ?? this.summary,
        createdAt: createdAt,
        updatedAt: updatedAt ?? updatedAt);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      INTERACTIVE_ID: interactiveId,
      INTERACTIVE_PROMPT: prompt,
      INTERACTIVE_CATEGORY: category,
      INTERACTIVE_INITIAL_SUMMARY: summary,
      INTERACTIVE_NUM_SEQ: sequence,
      INTERACTIVE_PHOTO_URL: photoUrl,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt
    };
  }

  factory InteractiveBoard.fromJson(Map<String, dynamic> doc) {
    return InteractiveBoard(
        interactiveId: doc[INTERACTIVE_ID],
        prompt: doc[INTERACTIVE_PROMPT],
        hidePrompt: doc[INTERACTIVE_HIDE_PROMPT],
        sequence: doc[INTERACTIVE_NUM_SEQ],
        category: doc[INTERACTIVE_CATEGORY],
        summary: doc[INTERACTIVE_INITIAL_SUMMARY],
        photoUrl: doc[INTERACTIVE_PHOTO_URL],
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[CREATED_AT].toInt());
  }
}
