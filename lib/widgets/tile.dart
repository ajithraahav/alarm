import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:alarm_example/data/theme_data.dart';
import 'package:intl/intl.dart';

class ExampleAlarmTile extends StatefulWidget {
  final BuildContext context;
  final DateTime time;
  final String? title;
  final void Function() onPressed;
  final void Function()? onDismissed;
  final int index;
  final int alarmId;

  const ExampleAlarmTile({
    Key? key,
    required this.context,
    required this.time,
    required this.title,
    required this.onPressed,
    this.onDismissed,
    required this.index,
    required this.alarmId,
  }) : super(key: key);

  @override
  State<ExampleAlarmTile> createState() => _ExampleAlarmTileState();
}

class _ExampleAlarmTileState extends State<ExampleAlarmTile> {
  late List<AlarmSettings> alarms;
  bool alarmState = true;

  Future<void> stopAlarm(bool val) async {
      Alarm.stop(widget.alarmId);
  }

  @override
  Widget build(BuildContext context) {
    final String alarmTitle = widget.title.toString();
    final int randomNumber = Random().nextInt(5);
    var gradientColor = GradientTemplate.gradientTemplate[randomNumber].colors;
    return RawMaterialButton(
        onPressed: widget.onPressed,
        child: Container(
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColor,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColor.last.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.label,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        alarmTitle,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'avenir'),
                      ),
                    ],
                  ),
                  Switch(
                    value: alarmState,
                    onChanged: (bool alarmVal) {
                      setState(() {
                        alarmState = alarmVal;
                        if (!alarmState) {
                          stopAlarm;
                        }
                      });
                    },
                    activeColor: Colors.white,
                  ),
                ],
              ),
              const Text(
                'Mon-Fri',
                style: TextStyle(color: Colors.white, fontFamily: 'avenir'),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    DateFormat('hh:mm aa').format(widget.time),
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'avenir',
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ));
  }
}
