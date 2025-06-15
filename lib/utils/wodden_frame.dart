import 'package:flutter/material.dart';

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
              child: Image.asset("assets/images/top.png", fit: BoxFit.fill),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: borderThickness,
              child: Image.asset("assets/images/bottom.png", fit: BoxFit.fill),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: borderThickness,
              child: Image.asset("assets/images/left.png", fit: BoxFit.fill),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: borderThickness,
              child: Image.asset("assets/images/right.png", fit: BoxFit.fill),
            ),
          ],
        );
      },
    );
  }
}
