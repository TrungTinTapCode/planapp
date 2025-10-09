/// Mục đích: Định nghĩa các mức độ ưu tiên cho task
/// Vị trí: lib/domain/entities/task_priority.dart

/// Enum đại diện cho mức độ ưu tiên của task
enum TaskPriority {
  /// Khẩn cấp (màu đỏ)
  urgent,

  /// Cao (màu cam)
  high,

  /// Trung bình (màu vàng)
  medium,

  /// Thấp (màu xanh dương)
  low,
}

extension TaskPriorityX on TaskPriority {
  /// Chuyển từ string (lưu trong Firestore) thành TaskPriority
  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.name == value,
      orElse: () => TaskPriority.medium,
    );
  }

  /// Lấy tên hiển thị (Tiếng Việt)
  String get displayName {
    switch (this) {
      case TaskPriority.urgent:
        return 'Khẩn cấp';
      case TaskPriority.high:
        return 'Cao';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.low:
        return 'Thấp';
    }
  }

  /// Màu hex để hiển thị UI
  String get colorHex {
    switch (this) {
      case TaskPriority.urgent:
        return '#FF3B30'; // đỏ
      case TaskPriority.high:
        return '#FF9500'; // cam
      case TaskPriority.medium:
        return '#FFD60A'; // vàng
      case TaskPriority.low:
        return '#007AFF'; // xanh dương
    }
  }
}
