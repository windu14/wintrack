class ActivityModel {
  final int? id;
  final String title;
  final String? description;
  final String date; // YYYY-MM-DD
  final bool isCompleted;
  final String createdAt;

  ActivityModel({
    this.id,
    required this.title,
    this.description,
    required this.date,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: map['createdAt'],
    );
  }

  ActivityModel copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    bool? isCompleted,
    String? createdAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
