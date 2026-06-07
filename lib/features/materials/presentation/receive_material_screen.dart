import 'package:flutter/material.dart';

import 'material_operation_form.dart';

class ReceiveMaterialScreen extends StatelessWidget {
  const ReceiveMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Receive Material')),
    body: MaterialOperationForm(operation: MaterialFormOperation.receive),
  );
}
