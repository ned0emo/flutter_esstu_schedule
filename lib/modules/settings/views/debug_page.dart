import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/logger/logger.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<StatefulWidget> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  List<String> _logList = [];
  late final Logger _logger;

  @override
  void initState() {
    _logger = Modular.get<Logger>();
    _loadLog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Логи')),
      body: _logList.isEmpty
          ? const Center(child: Text('Пусто...'))
          : SingleChildScrollView(
              child: Column(
                children: List.generate(
                  _logList.length,
                  (index) => _logTile(_logList[index]),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _logger.clearLog();
            _loadLog();
          },
          child: const Icon(Icons.delete)),
    );
  }

  Widget _logTile(String logMessage) {
    if (!logMessage.contains('|')) return const SizedBox();

    final message = logMessage.split('|');

    MaterialColor logColor() {
      return message[1] == 'error'
          ? Colors.red
          : message[1] == 'warning'
              ? Colors.yellow
              : Colors.grey;
    }

    return ListTile(
      titleAlignment: ListTileTitleAlignment.center,
      leading: Text(message[0]),
      title: Text(message[2]),
      trailing: Icon(Icons.circle, color: logColor()),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(message[3], textAlign: TextAlign.center),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadLog() async {
    final list = await _logger.getLog();
    setState(() {
      _logList = list;
    });
  }
}
