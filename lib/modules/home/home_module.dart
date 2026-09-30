import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/parser/parser.dart';
import 'package:schedule/core/parser/students_parser.dart';
import 'package:schedule/core/parser/teachers_parser.dart';
import 'package:schedule/core/time/bloc/week_number_bloc.dart';
import 'package:schedule/core/time/week_number_repository.dart';
import 'package:schedule/modules/classrooms/classrooms_module.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_module.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';
import 'package:schedule/modules/home/home_page.dart';
import 'package:schedule/modules/search/search_module.dart';
import 'package:schedule/modules/settings/settings_module.dart';
import 'package:schedule/modules/students/students_module.dart';
import 'package:schedule/modules/teachers/teachers_module.dart';
import 'package:schedule/modules/zo_classrooms/zo_classrooms_module.dart';
import 'package:schedule/modules/zo_teachers/zo_teachers_module.dart';

final homeModule = createModule(
    path: '/',
    register: (c) {
      c.addSingleton(WeekNumberRepository.new);
      c.addSingleton(WeekNumberBloc.new);
      c.addSingleton(FavoriteButtonBloc.new);
      c.addSingleton(FavoriteScheduleBloc.new);
      c.addSingleton(FavoriteRepository.new);
      c.addSingleton(MainRepository.new);
      c.addSingleton(TeachersParser.new);
      c.addSingleton(StudentsParser.new);
      c.addSingleton(Parser.new);

      c.route('/', child: (context, rs) => const HomePage());

      c.module(studentsModule);
      c.module(settingsModule);
      c.module(teachersModule);
      c.module(classroomsModule);
      c.module(favoriteModule);
      c.module(searchModule);
      c.module(zoClassroomsModule);
      c.module(zoTeachersModule);
    });
