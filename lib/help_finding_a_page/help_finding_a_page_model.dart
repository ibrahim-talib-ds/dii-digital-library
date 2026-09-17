import '/components/contact_method_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'help_finding_a_page_widget.dart' show HelpFindingAPageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HelpFindingAPageModel extends FlutterFlowModel<HelpFindingAPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ContactMethod.
  late ContactMethodModel contactMethodModel1;
  // Model for ContactMethod.
  late ContactMethodModel contactMethodModel2;

  @override
  void initState(BuildContext context) {
    contactMethodModel1 = createModel(context, () => ContactMethodModel());
    contactMethodModel2 = createModel(context, () => ContactMethodModel());
  }

  @override
  void dispose() {
    contactMethodModel1.dispose();
    contactMethodModel2.dispose();
  }
}
