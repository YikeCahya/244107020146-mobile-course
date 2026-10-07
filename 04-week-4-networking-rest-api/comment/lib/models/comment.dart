/// Model data satu komentar dari JSONPlaceholder.
/// Semua field non-nullable di sisi aplikasi agar UI tidak perlu
/// mengecek null; nilai default diberikan di fromJson.
class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;
 
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });
 
  /// fromJson aman null: TIDAK memakai cast langsung seperti `json["id"] as int`
  /// (akan crash jika field hilang / null / tipe berbeda).
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: _toInt(json["postId"]),
      id: _toInt(json["id"]),
      name: _toStr(json["name"]),
      email: _toStr(json["email"]),
      body: _toStr(json["body"]),
    );
  }
 
  /// Mengubah nilai dinamis menjadi int. Mendukung num dan String angka,
  /// selain itu kembali ke 0.
  static int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
 
  /// Mengubah nilai dinamis menjadi String; null menjadi string kosong.
  static String _toStr(dynamic v) => v?.toString() ?? "";
}
 