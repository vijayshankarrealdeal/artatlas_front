import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/repositories/g_bucket_image.dart';
import 'package:hack_front/services/api_service.dart';

class WoodenFrameBox extends StatelessWidget {
  final Widget child;
  final Axis orientation;
  final double borderThickness;

  const WoodenFrameBox({
    super.key,
    required this.child,
    this.orientation = Axis.vertical,
    this.borderThickness = 35.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerPadding = 4.0; // Reduced padding for inner content

        //borderThickness * 0.8; // Reduced padding
        String topBorder =
            "${ApiService.baseUrl}/image/proxy-image?url=${Uri.encodeComponent(GBucketImage.woodTop)}";
        String bottomBorder =
            "${ApiService.baseUrl}/image/proxy-image?url=${Uri.encodeComponent(GBucketImage.woodBottom)}";
        String leftBorder =
            "${ApiService.baseUrl}/image/proxy-image?url=${Uri.encodeComponent(GBucketImage.woodLeft)}";
        String rightBorder =
            "${ApiService.baseUrl}/image/proxy-image?url=${Uri.encodeComponent(GBucketImage.woodRight)}";
        return Stack(
          children: [
            // Inner content with reduced padding
            Padding(
              padding: EdgeInsets.all(innerPadding),
              child: orientation == Axis.vertical
                  ? Column(mainAxisSize: MainAxisSize.min, children: [child])
                  : Row(mainAxisSize: MainAxisSize.min, children: [child]),
            ),

            // Frame Borders
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: borderThickness,
              child: CachedNetworkImage(imageUrl: topBorder, fit: BoxFit.fill),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: borderThickness,
              child: CachedNetworkImage(
                imageUrl: bottomBorder,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: borderThickness,
              child: CachedNetworkImage(imageUrl: leftBorder, fit: BoxFit.fill),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: borderThickness,
              child: CachedNetworkImage(
                imageUrl: rightBorder,
                fit: BoxFit.fill,
              ),
            ),
          ],
        );
      },
    );
  }
}
