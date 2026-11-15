class Task {
  const Task({
    this.id,
    required this.title,
    this.note = '',
    required this.category,
    this.priority = 1,
    required this.dueDate,
    this.reminderMinutes,
    this.isDone = false,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String note;
  final String category;
  final int priority;
  final DateTime dueDate;
  final int? reminderMinutes;
  final bool isDone;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'category': category,
        'priority': priority,
        'due_date': dueDate.toIso8601String(),
        'reminder_minutes': reminderMinutes,
        'is_done': isDone ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory Task.fromMap(Map<String, Object?> map) => Task(
        id: map['id'] as int?,
        title: map['title'] as String,
        note: (map['note'] as String?) ?? '',
        category: map['category'] as String,
        priority: (map['priority'] as int?) ?? 1,
        dueDate: DateTime.parse(map['due_date'] as String),
        reminderMinutes: map['reminder_minutes'] as int?,
        isDone: (map['is_done'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Task copyWith({
    int? id,
    String? title,
    String? note,
    String? category,
    int? priority,
    DateTime? dueDate,
    Object? reminderMinutes = _unset,
    bool? isDone,
    DateTime? createdAt,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        note: note ?? this.note,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        reminderMinutes:
            reminderMinutes == _unset ? this.reminderMinutes : reminderMinutes as int?,
        isDone: isDone ?? this.isDone,
        createdAt: createdAt ?? this.createdAt,
      );

  static const Object _unset = Object();
}

class MoneyEntry {
  const MoneyEntry({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note = '',
    required this.date,
    required this.createdAt,
  });

  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';

  final int? id;
  final String type;
  final int amount;
  final String category;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  bool get isIncome => type == typeIncome;

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type,
        'amount': amount,
        'category': category,
        'note': note,
        'date': date.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory MoneyEntry.fromMap(Map<String, Object?> map) => MoneyEntry(
        id: map['id'] as int?,
        type: map['type'] as String,
        amount: (map['amount'] as num).toInt(),
        category: map['category'] as String,
        note: (map['note'] as String?) ?? '',
        date: DateTime.parse(map['date'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  MoneyEntry copyWith({
    int? id,
    String? type,
    int? amount,
    String? category,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) =>
      MoneyEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        note: note ?? this.note,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
      );
}

class Budget {
  const Budget({required this.month, required this.amount});

  final String month;
  final int amount;

  Map<String, Object?> toMap() => {'month': month, 'amount': amount};

  factory Budget.fromMap(Map<String, Object?> map) => Budget(
        month: map['month'] as String,
        amount: (map['amount'] as num).toInt(),
      );
}

class FinancialGoal {
  const FinancialGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    this.deadline,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final int targetAmount;
  final int savedAmount;
  final DateTime? deadline;
  final DateTime createdAt;

  double get progress => targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);
  bool get isComplete => targetAmount > 0 && savedAmount >= targetAmount;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'target_amount': targetAmount,
        'saved_amount': savedAmount,
        'deadline': deadline?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory FinancialGoal.fromMap(Map<String, Object?> map) => FinancialGoal(
        id: map['id'] as int?,
        name: map['name'] as String,
        targetAmount: (map['target_amount'] as num).toInt(),
        savedAmount: (map['saved_amount'] as num? ?? 0).toInt(),
        deadline: map['deadline'] == null ? null : DateTime.parse(map['deadline'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  FinancialGoal copyWith({
    int? id,
    String? name,
    int? targetAmount,
    int? savedAmount,
    Object? deadline = _unset,
    DateTime? createdAt,
  }) =>
      FinancialGoal(
        id: id ?? this.id,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        deadline: deadline == _unset ? this.deadline : deadline as DateTime?,
        createdAt: createdAt ?? this.createdAt,
      );

  static const Object _unset = Object();
}

class StudySession {
  const StudySession({
    this.id,
    required this.courseKey,
    required this.minutes,
    required this.date,
    required this.createdAt,
  });

  final int? id;
  final String courseKey;
  final int minutes;
  final DateTime date;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'course_key': courseKey,
        'minutes': minutes,
        'date': date.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory StudySession.fromMap(Map<String, Object?> map) => StudySession(
        id: map['id'] as int?,
        courseKey: map['course_key'] as String,
        minutes: (map['minutes'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class PersonalGoal {
  const PersonalGoal({
    this.id,
    required this.title,
    this.description = '',
    this.targetDate,
    this.progress = 0,
    this.isDone = false,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime? targetDate;
  final int progress;
  final bool isDone;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'target_date': targetDate?.toIso8601String(),
        'progress': progress,
        'is_done': isDone ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory PersonalGoal.fromMap(Map<String, Object?> map) => PersonalGoal(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: (map['description'] as String?) ?? '',
        targetDate:
            map['target_date'] == null ? null : DateTime.parse(map['target_date'] as String),
        progress: (map['progress'] as num? ?? 0).toInt(),
        isDone: (map['is_done'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  PersonalGoal copyWith({
    int? id,
    String? title,
    String? description,
    Object? targetDate = _unset,
    int? progress,
    bool? isDone,
    DateTime? createdAt,
  }) =>
      PersonalGoal(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        targetDate: targetDate == _unset ? this.targetDate : targetDate as DateTime?,
        progress: progress ?? this.progress,
        isDone: isDone ?? this.isDone,
        createdAt: createdAt ?? this.createdAt,
      );

  static const Object _unset = Object();
}

class JournalEntry {
  const JournalEntry({
    this.id,
    required this.title,
    required this.content,
    this.mood = 'neutral',
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'mood': mood,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromMap(Map<String, Object?> map) => JournalEntry(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        mood: (map['mood'] as String?) ?? 'neutral',
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
}
