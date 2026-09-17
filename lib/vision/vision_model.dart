import '/components/vision_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'vision_widget.dart' show VisionWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VisionModel extends FlutterFlowModel<VisionWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for VisionCard.
  late VisionCardModel visionCardModel1;
  // Model for VisionCard.
  late VisionCardModel visionCardModel2;
  // Model for VisionCard.
  late VisionCardModel visionCardModel3;

  @override
  void initState(BuildContext context) {
    visionCardModel1 = createModel(context, () => VisionCardModel());
    visionCardModel2 = createModel(context, () => VisionCardModel());
    visionCardModel3 = createModel(context, () => VisionCardModel());
  }

  @override
  void dispose() {
    visionCardModel1.dispose();
    visionCardModel2.dispose();
    visionCardModel3.dispose();
  }
}
