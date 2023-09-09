library giphy_picker;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giphy_picker/src/model/giphy_client.dart';
import 'package:giphy_picker/src/model/giphy_preview_types.dart';
import 'package:giphy_picker/src/widgets/giphy_context.dart';
import 'package:giphy_picker/src/widgets/giphy_search_page.dart';

export 'package:giphy_picker/src/model/giphy_client.dart';
export 'package:giphy_picker/src/model/giphy_preview_types.dart';
export 'package:giphy_picker/src/widgets/giphy_image.dart';

typedef ErrorListener = void Function(GiphyError error);

/// Provides Giphy picker functionality.
class GiphyPicker {
  /// Renders a full screen modal dialog for searching, and selecting a Giphy image.
  static Future<GiphyGif?> pickGif({
    required BuildContext context,
    required String apiKey,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    bool sticker = false,
    Widget? title,
    ErrorListener? onError,
    bool showPreviewPage = true,
    bool showGiphyAttribution = true,
    bool fullScreenDialog = true,
    String searchHintText = 'Search GIPHY',
    GiphyPreviewType previewType = GiphyPreviewType.previewWebp,
    SearchTextBuilder? searchTextBuilder,
    WidgetBuilder? loadingBuilder,
    ResultsBuilder? resultsBuilder,
    WidgetBuilder? noResultsBuilder,
    SearchErrorBuilder? errorBuilder,
  }) async {
    GiphyGif? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => GiphyContext(
          previewType: previewType,
          apiKey: apiKey,
          rating: rating,
          language: lang,
          sticker: sticker,
          onError: onError ?? (error) => _showErrorDialog(context, error),
          onSelected: (gif) {
            result = gif;
            // pop preview page if necessary
            if (showPreviewPage) {
              Navigator.pop(context);
            }
            // pop giphy_picker
            Navigator.pop(context);
          },
          showPreviewPage: showPreviewPage,
          showGiphyAttribution: showGiphyAttribution,
          searchHintText: searchHintText,
          searchTextBuilder: searchTextBuilder,
          loadingBuilder: loadingBuilder,
          resultsBuilder: resultsBuilder,
          noResultsBuilder: noResultsBuilder,
          errorBuilder: errorBuilder,
          child: GiphySearchPage(
            title: title,
          ),
        ),
        fullscreenDialog: fullScreenDialog,
      ),
    );

    return result;
  }

  static Future<GiphyGif?> showModalPickGif({
    required BuildContext context,
    required String apiKey,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    bool sticker = false,
    Widget? title,
    ErrorListener? onError,
    bool showPreviewPage = true,
    bool showGiphyAttribution = true,
    String searchHintText = 'Search GIPHY',
    GiphyPreviewType previewType = GiphyPreviewType.previewWebp,
    SearchTextBuilder? searchTextBuilder,
    WidgetBuilder? loadingBuilder,
    ResultsBuilder? resultsBuilder,
    WidgetBuilder? noResultsBuilder,
    SearchErrorBuilder? errorBuilder,
  }) async {
    GiphyGif? result;
    final content = GiphyContext(
      previewType: previewType,
      apiKey: apiKey,
      rating: rating,
      language: lang,
      sticker: sticker,
      onError: onError ?? (error) => _showErrorDialog(context, error),
      onSelected: (gif) {
        result = gif;
        // pop preview page if necessary
        if (showPreviewPage) {
          Navigator.pop(context);
        }
        // pop giphy_picker
        Navigator.pop(context);
      },
      showPreviewPage: showPreviewPage,
      showGiphyAttribution: showGiphyAttribution,
      searchHintText: searchHintText,
      searchTextBuilder: searchTextBuilder,
      loadingBuilder: loadingBuilder,
      resultsBuilder: resultsBuilder,
      noResultsBuilder: noResultsBuilder,
      errorBuilder: errorBuilder,
      child: GiphySearchPage(
        title: title,
      ),
    );

    if (Platform.isIOS) {
      await showCupertinoModalPopup<GiphyGif?>(
        context: context,
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
          tileMode: TileMode.decal,
        ),
        builder: (context) {
          return CupertinoActionSheet(
            actions: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .6),
                child: content,
              ),
            ],
          );
        },
      );
    } else {
      await showModalBottomSheet<GiphyGif?>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return content;
        },
      );
    }

    return result;
  }

  static void _showErrorDialog(BuildContext context, GiphyError error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Giphy error'),
          content: Text(error.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
