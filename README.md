# PlanApp - Ứng Dụng Quản Lý Dự Án & Công Việc

**PlanApp** là một ứng dụng di động mạnh mẽ được xây dựng trên nền tảng **Flutter**, thiết kế chuyên biệt để hỗ trợ cá nhân và đội nhóm quản lý dự án, theo dõi đầu việc (tasks), và giao tiếp làm việc một cách hiệu quả.

## ✨ Tính Năng Nổi Bật

- 🔐 **Xác thực An Toàn:** Hỗ trợ đăng nhập/đăng ký thông qua Email & Mật khẩu hoặc tài khoản Google.
- 📁 **Quản Lý Dự Án:** Khởi tạo, theo dõi trạng thái và quản lý các dự án với đầy đủ cấu trúc nhóm và mô tả chi tiết.
- ✅ **Giám Sát Công Việc (Tasks):** Chia nhỏ dự án, phân loại tác vụ theo độ ưu tiên (Task Priority) và theo dõi tiến độ một cách minh bạch.
- 💬 **Giao Tiếp & Thảo Luận:** Kết hợp nhắn tin (Chat) thời gian thực và bình luận (Comment) chuyên sâu ngay trên từng tác vụ.
- 🔔 **Hệ Thống Thông Báo:** Thông báo đẩy (Push Notifications) và thông báo trong ứng dụng giúp người dùng không bỏ lỡ luồng công việc.
- 👤 **Quản Lý Hồ Sơ:** Tùy chỉnh thông tin và quản lý tải khoản cá nhân dễ dàng.

## 🛠️ Công Nghệ Nền Tảng (Tech Stack)

- **UI Framework:** Flutter (SDK 3.7.2+) & Dart
- **State Management:** BLoC (flutter_bloc) kết hợp cùng Equatable & Freezed
- **Architecture Pattern:** Clean Architecture
- **Backend Services:** Firebase (Authentication, Cloud Firestore, Storage, Cloud Messaging)
- **Dependency Injection:** GetIt

## 🏗️ Cấu Trúc Kiến Trúc (Clean Architecture)

Dự án được tổ chức theo tiêu chuẩn cấu trúc **Clean Architecture** để tối ưu hóa khả năng mở rộng, bảo trì và dễ dàng viết Test:

- 🎨 **`presentation/`**: Tầng giao diện người dùng, bao gồm các Màn hình (Screens), Component tái sử dụng (Widgets) và khối xử lý trạng thái (Blocs).
- 🧠 **`domain/`**: Tầng nghiệp vụ cốt lõi, lưu trữ các Thực thể (Entities), Logic nghiệp vụ (UseCases) và Giao diện kết nối (Repositories).
- 💾 **`data/`**: Tầng tiếp xúc dữ liệu, chịu trách nhiệm gọi Firebase (DataSources), chuyển đổi DTOs (Models) và triển khai Repositories cụ thể.
- ⚙️ **`core/`**: Tầng cơ sở chứa các tiện ích dùng chung (Utils), cơ chế xử lý ngoại lệ và định nghĩa hằng số hệ thống.
