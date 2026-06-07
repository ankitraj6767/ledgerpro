import 'package:flutter/material.dart';

import 'material_operation_form.dart';

class ReturnMaterialScreen extends StatelessWidget {
  const ReturnMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Return Material')),
    body: MaterialOperationForm(
      operation: MaterialFormOperation.materialReturn,
    ),
  );
}
