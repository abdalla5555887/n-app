
class Worker {
  String name;
  Worker({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
  factory Worker.fromJson(Map<String, dynamic> json) => Worker(name: json['name']);
}

class ShiftAssignment {
  String date; // ISO format
  String dayName;
  List<String> morningWorkers;
  List<String> eveningWorkers;
  List<String> nightWorkers;

  ShiftAssignment({
    required this.date,
    required this.dayName,
    this.morningWorkers = const [],
    this.eveningWorkers = const [],
    this.nightWorkers = const [],
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'dayName': dayName,
    'morningWorkers': morningWorkers,
    'eveningWorkers': eveningWorkers,
    'nightWorkers': nightWorkers,
  };

  factory ShiftAssignment.fromJson(Map<String, dynamic> json) => ShiftAssignment(
    date: json['date'],
    dayName: json['dayName'],
    morningWorkers: List<String>.from(json['morningWorkers'] ?? []),
    eveningWorkers: List<String>.from(json['eveningWorkers'] ?? []),
    nightWorkers: List<String>.from(json['nightWorkers'] ?? []),
  );
}
