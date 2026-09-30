import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/students/students_module.dart';

final appModule = createModule(register: (c) {
  c.module(homeModule);
  c.module(studentsModule);
});
