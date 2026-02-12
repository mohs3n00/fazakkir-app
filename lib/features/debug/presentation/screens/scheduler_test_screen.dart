import 'package:flutter/material.dart';
import 'package:fazakkir/core/services/native_scheduler_service.dart';
import 'package:intl/intl.dart';

class SchedulerTestScreen extends StatefulWidget {
  const SchedulerTestScreen({super.key});

  @override
  State<SchedulerTestScreen> createState() => _SchedulerTestScreenState();
}

class _SchedulerTestScreenState extends State<SchedulerTestScreen> {
  final NativeSchedulerService _scheduler = NativeSchedulerService();
  String _logs = "Ready to test.";
  bool _canSchedule = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final can = await _scheduler.canScheduleExactAlarms();
    setState(() {
      _canSchedule = can;
      _logs += "\nPermission status: $can";
    });
  }

  void _log(String msg) {
    setState(() {
      _logs = "${DateFormat('HH:mm:ss').format(DateTime.now())}: $msg\n$_logs";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Native Scheduler Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_canSchedule)
              ListTile(
                title: const Text("Permission Denied"),
                subtitle: const Text("Exact Alarms required"),
                tileColor: Colors.red[100],
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _scheduler.requestExactAlarmPermission();
                    _checkPermission();
                  },
                  child: const Text("Fix"),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final trigger = now.add(const Duration(seconds: 60)); // +60s

                _log("Scheduling Adhan ID 123 for $trigger");

                await _scheduler.scheduleAdhan(
                  id: 123,
                  triggerAt: trigger,
                  title: "Native Adhan Test",
                  body: "This should play audio!",
                  audioAssetPath:
                      "adhan_notification", // Using resource name if possible, or null
                );

                _log("Scheduled.");
              },
              child: const Text("Schedule Native Adhan (+60s)"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                _log("Cancelling ID 123");
                await _scheduler.cancelAdhan(123);
              },
              child: const Text("Cancel Test Adhan"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                _checkPermission();
                _log("Refreshed permissions.");
              },
              child: const Text("Refresh Info"),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () async {
                final alarms = await _scheduler.getScheduledAlarms();
                String formatted = "";
                alarms.forEach((key, value) {
                  final map = Map<String, dynamic>.from(value);
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    map['triggerAtMillis'],
                  );
                  formatted +=
                      "ID: $key\nTime: $date\nPayload: ${map['payload']}\n---\n";
                });
                if (formatted.isEmpty) formatted = "No alarms found.";
                _log("Alarms:\n$formatted");
              },
              child: const Text("List Native Alarms"),
            ),
            Expanded(child: SingleChildScrollView(child: Text(_logs))),
          ],
        ),
      ),
    );
  }
}
