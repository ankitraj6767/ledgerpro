import 'package:flutter/material.dart';

import 'material_operation_form.dart';

class IssueMaterialScreen extends StatelessWidget {
  const IssueMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Issue Material')),
    body: MaterialOperationForm(operation: MaterialFormOperation.issue),
  );
}
