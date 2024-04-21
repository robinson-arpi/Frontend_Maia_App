import 'dart:convert';

ClassSchedule classScheduleFromJson(String str) =>
    ClassSchedule.fromJson(json.decode(str));

String classScheduleToJson(ClassSchedule data) => json.encode(data.toJson());

class ClassSchedule {
  List<Schedule>? schedule;

  ClassSchedule({
    this.schedule,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) => ClassSchedule(
        schedule: json["schedule"] == null
            ? []
            : List<Schedule>.from(
                json["schedule"]!.map((x) => Schedule.fromJson(x))),
      );

  String get startTime => "";

  get className => null;

  Map<String, dynamic> toJson() => {
        "schedule": schedule == null
            ? []
            : List<dynamic>.from(schedule!.map((x) => x.toJson())),
      };
}

class Schedule {
  int? scheduleId;
  String? className;
  String? professorFirstName;
  String? professorLastName;
  String? classroomName;
  String? day;
  String? startTime;
  String? endTime;

  Schedule({
    this.scheduleId,
    this.className,
    this.professorFirstName,
    this.professorLastName,
    this.classroomName,
    this.day,
    this.startTime,
    this.endTime,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        scheduleId: json["scheduleId"],
        className: utf8.decode(json["className"].runes.toList()),
        professorFirstName: json["professorFirstName"],
        professorLastName: json["professorLastName"],
        classroomName: json["classroomName"],
        day: json["day"],
        startTime: json["startTime"], // Parsea la cadena a DateTime
        endTime: json["endTime"],
      );

  Map<String, dynamic> toJson() => {
        "scheduleId": scheduleId,
        "className": className,
        "professorFirstName": professorFirstName,
        "professorLastName": professorLastName,
        "classroomName": classroomName,
        "day": day,
        "startTime": startTime, // Convierte DateTime
        "endTime": endTime,
      };
}
