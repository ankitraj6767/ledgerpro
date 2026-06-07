import 'package:flutter/material.dart';

import 'material_operation_form.dart';

class MaterialItemFormScreen extends StatelessWidget {
  const MaterialItemFormScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Add Material Item')),
    body: MaterialOperationForm(operation: MaterialFormOperation.item),
  );
}
