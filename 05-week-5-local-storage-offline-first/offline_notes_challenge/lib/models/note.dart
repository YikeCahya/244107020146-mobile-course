enum NoteSyncFilter { all, pending, synced }

class Note {
  const Note({
    this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  Note copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_dirty': isDirty ? 1 : 0,
    'is_deleted': isDeleted ? 1 : 0,
  };

  factory Note.fromMap(Map<String, Object?> map) => Note(
    id: (map['id'] as num?)?.toInt(),
    title: map['title'] as String,
    body: map['body'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    isDirty: (map['is_dirty'] as num) == 1,
    isDeleted: (map['is_deleted'] as num) == 1,
  );
}
