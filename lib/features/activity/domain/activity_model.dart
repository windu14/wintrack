class ActivityModel {
  final int? id;
  final String title;
  final String? description;
  final String date; // YYYY-MM-DD
  final bool isCompleted;
  final String createdAt;
  final String status;

  ActivityModel({
    this.id,
    required this.title,
    this.description,
    required this.date,
    this.isCompleted = false,
    required this.createdAt,
    this.status = 'Sedang',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt,
      'status': status,
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
      status: map['status'] ?? 'Sedang',
    );
  }

  ActivityModel copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    bool? isCompleted,
    String? createdAt,
    String? status,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
