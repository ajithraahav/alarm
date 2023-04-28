import 'dart:convert';
import 'package:alarm/service/storage.dart';
import 'package:alarm_example/provider.dart/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class ExampleAlarmEditScreen extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  const ExampleAlarmEditScreen({
    Key? key,
    this.alarmSettings,
  }) : super(key: key);

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  late bool creating;
  late TimeOfDay selectedTime;
  late bool loopAudio;
  late bool vibrate;
  late bool showNotification;

  TextEditingController _controller = TextEditingController();
  late String assetAudio;
  late List<String> alarmFileName;
  late List<String> alarmFilePath;
  final player = AudioPlayer();

  Future<void> playAudio(alarmTonePath) async {
    await player.play(AssetSource(alarmTonePath));
  }

  Future<void> stopAudio() async {
    await player.stop();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AlarmProvider>(context, listen: false)
          .updateSelectedPath('assets/alarm_tone/Auratone.mp3');
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AlarmProvider>(context, listen: false)
          .updateSelectedValue('Auratone');
    });

    creating = widget.alarmSettings == null;

    if (creating) {
      final dt = DateTime.now().add(const Duration(minutes: 1));
      final hour = DateFormat('hh').format(dt);
      final minute = DateFormat('mm').format(dt);
      selectedTime =
          TimeOfDay(hour: int.parse(hour), minute: int.parse(minute));
      loopAudio = true;
      vibrate = true;
      showNotification = true;
      assetAudio = Provider.of<AlarmProvider>(context, listen: false).alarmPath;
    } else {
      selectedTime = TimeOfDay(
        hour: widget.alarmSettings!.dateTime.hour,
        minute: widget.alarmSettings!.dateTime.minute,
      );
      _controller =
          TextEditingController(text: widget.alarmSettings!.notificationTitle);
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      showNotification = widget.alarmSettings!.notificationTitle != null &&
          widget.alarmSettings!.notificationTitle!.isNotEmpty &&
          widget.alarmSettings!.notificationBody != null &&
          widget.alarmSettings!.notificationBody!.isNotEmpty;
      assetAudio = Provider.of<AlarmProvider>(context, listen: false).alarmPath;
    }
    getAlarmFromAsset();
  }

  getAlarmFromAsset() async {
    alarmFilePath = await getAssetFiles('assets/alarm_tone/');
    alarmFileName = alarmFilePath
        .map((e) => e.split('/').last.replaceAll('.mp3', ''))
        .toList();
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: selectedTime,
      context: context,
    );
    if (res != null) setState(() => selectedTime = res);
  }

  Future<List<String>> getAssetFiles(String path) async {
    List<String> assetFiles = [];
    final directory = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> assetsMap = json.decode(directory);

    for (var key in assetsMap.keys) {
      if (key.startsWith(path)) {
        assetFiles.add(key);
      }
    }

    return assetFiles;
  }

  AlarmSettings buildAlarmSettings() {
    final now = DateTime.now();
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 100000
        : widget.alarmSettings!.id;

    DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
      0,
      0,
    );
    if (dateTime.isBefore(DateTime.now())) {
      dateTime = dateTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
        id: id,
        dateTime: dateTime,
        loopAudio: loopAudio,
        vibrate: vibrate,
        notificationTitle: showNotification ? _controller.text : '',
        notificationBody: showNotification
            ? 'Your alarm for ${_controller.text} is ringing'
            : null,
        assetAudioPath:
            Provider.of<AlarmProvider>(context, listen: false).alarmPath,
        enableNotificationOnKill: true);
    AlarmStorage.saveAlarm(alarmSettings);
    AlarmStorage.getSavedAlarms();
    return alarmSettings;
  }

  void saveAlarm() {
    Alarm.set(alarmSettings: buildAlarmSettings())
        .then((_) => Navigator.pop(context, true));
  }

  Future<void> deleteAlarm() async {
    Alarm.stop(widget.alarmSettings!.id)
        .then((_) => Navigator.pop(context, true));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RawMaterialButton(
            elevation: 0,
            onPressed: pickTime,
            fillColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                selectedTime.format(context),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(color: Colors.blueAccent),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Alarm Title',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              hintText: 'Alarm title',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show notification',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: showNotification,
                onChanged: (value) => setState(() => showNotification = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sound',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                  onPressed: () {
                    alarmToneList();
                  },
                  icon: const Icon(Icons.arrow_forward_ios))
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              Provider.of<AlarmProvider>(context).alarmTone,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: !creating
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (!creating)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                    ),
                    onPressed: () => deleteAlarm(),
                    icon: const Icon(Icons.alarm),
                    label: const Text(
                      'Delete',
                    ),
                  ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                  ),
                  onPressed: saveAlarm,
                  icon: const Icon(Icons.alarm),
                  label: const Text(
                    'Save',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(),
        ],
      ),
    );
  }

  alarmToneList() async {
    await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        builder: (context) {
          return Consumer<AlarmProvider>(
            builder: (context, value, child) => FractionallySizedBox(
              heightFactor: 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Default Value ${value.alarmTone}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.blueAccent),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Done',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.blueAccent),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: alarmFileName.length,
                      itemBuilder: (BuildContext context, int index) {
                        return RadioListTile(
                          value: alarmFileName[index],
                          groupValue: value.alarmTone,
                          onChanged: (newValue) {
                            stopAudio();
                            value.updateSelectedValue(newValue!);
                            playAudio(
                                alarmFilePath[index].replaceAll('assets/', ''));
                            value.updateSelectedPath(alarmFilePath[index]);
                          },
                          title: Text(alarmFileName[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).then((value) => stopAudio());
  }
}
