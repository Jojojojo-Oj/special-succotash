import 'dart:io';
import 'package:flutter/material.dart';

Widget buildImageGrid(BuildContext context, List<dynamic> images) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: images.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemBuilder: (context, index) {
      final image = images[index];
      final isFile = image is File;

      return GestureDetector(
        onTap: () => _openImagePreview(context, image),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isFile
              ? Image.file(image, fit: BoxFit.cover)
              : Image.network(image, fit: BoxFit.cover),
        ),
      );
    },
  );
}

void _openImagePreview(BuildContext context, dynamic image) {
  final isFile = image is File;

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.9),
    builder: (_) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isFile
                  ? Image.file(image, fit: BoxFit.contain)
                  : Image.network(image, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    ),
  );
}
