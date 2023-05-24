import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';

class FacultiesPage extends StatefulWidget {
  const FacultiesPage({super.key});

  @override
  State<StatefulWidget> createState() => _FacultiesState();
}

class _FacultiesState extends State<FacultiesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Факультет')),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  Modular.get<FacultyBloc>()..add(LoadFaculties())),
        ],
        child: SingleChildScrollView(
          child: BlocListener<FacultyBloc, FacultyState>(
            listener: (context, state) {
              if (state is CurrentFacultyState) {
                Modular.to.pushReplacementNamed(
                    AppRoutes.teachersRoute + AppRoutes.departmentsRoute);
              }
            },
            child: BlocBuilder<FacultyBloc, FacultyState>(
              builder: (context, state) {
                if (state is FacultiesLoadingState) {
                  return const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
                }

                if (state is FacultiesLoadedState) {
                  final map = state.facultyDepartmentLinkMap;
                  return Center(
                    child: Column(
                      children: List.generate(
                          map.keys.length,
                          (index) => _facultyButton(map.keys.elementAt(index),
                              map[map.keys.elementAt(index)]!, context)),
                    ),
                  );
                }

                if (state is FacultiesErrorState) {
                  return Center(
                      child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Text(state.message),
                    ],
                  ));
                }

                return const Center(
                    child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text('Неизвестная ошибка'),
                  ],
                ));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _facultyButton(String facultyName,
      Map<String, List<String>> departmentsMap, BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            BlocProvider.of<FacultyBloc>(context).add(ChooseFaculty(
                facultyName: facultyName, departmentsMap: departmentsMap));
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(350, 50),
              maximumSize: const Size(350, double.infinity)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(facultyName, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
