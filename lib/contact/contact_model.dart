import '/components/contact_option_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'contact_widget.dart' show ContactWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContactModel extends FlutterFlowModel<ContactWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ContactOption.
  late ContactOptionModel contactOptionModel1;
  // Model for ContactOption.
  late ContactOptionModel contactOptionModel2;
  // Model for ContactOption.
  late ContactOptionModel contactOptionModel3;

  @override
  void initState(BuildContext context) {
    contactOptionModel1 = createModel(context, () => ContactOptionModel());
    contactOptionModel2 = createModel(context, () => ContactOptionModel());
    contactOptionModel3 = createModel(context, () => ContactOptionModel());
  }

  @override
  void dispose() {
    contactOptionModel1.dispose();
    contactOptionModel2.dispose();
    contactOptionModel3.dispose();
  }
}
