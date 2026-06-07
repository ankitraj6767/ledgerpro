import 'package:flutter/material.dart';

import 'material_operation_form.dart';

class SchoolRequirementFormScreen extends StatelessWidget {
  const SchoolRequirementFormScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Add Requirement')),
    body: MaterialOperationForm(operation: MaterialFormOperation.requirement),
  );
}
