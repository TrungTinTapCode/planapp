# PlanApp - Tài liệu Dự án

## 1. Tổng quan Dự án

**PlanApp** là một ứng dụng di động được xây dựng bằng **Flutter**, được thiết kế để quản lý dự án và công việc. Ứng dụng cho phép người dùng tạo dự án, quản lý các đầu việc (task), giao tiếp thông qua bình luận/trò chuyện và nhận thông báo.

## 2. Công nghệ sử dụng (Tech Stack)

### Core Framework (Nền tảng cốt lõi)

- **Flutter**: Bộ công cụ UI được sử dụng để xây dựng ứng dụng (Phiên bản SDK ^3.7.2).
- **Dart**: Ngôn ngữ lập trình.

### Kiến trúc (Architecture)

- **Clean Architecture**: Dự án tuân theo nguyên tắc phân tách các mối quan tâm thành ba lớp chính:
  - **Presentation (Giao diện)**: UI (Màn hình, Widget) và Quản lý trạng thái (Blocs).
  - **Domain (Nghiệp vụ)**: Logic nghiệp vụ (Thực thể, UseCases, Giao diện Repository).
  - **Data (Dữ liệu)**: Triển khai dữ liệu (Repositories, Data Sources, Models).

### Quản lý trạng thái (State Management)

- **Bloc (flutter_bloc)**: Được sử dụng để quản lý trạng thái của ứng dụng một cách dễ dự đoán.
- **Equatable**: Dùng để so sánh giá trị trong Blocs và Models.

### Backend & Dịch vụ (Firebase)

- **Firebase Core**: Khởi tạo Firebase.
- **Firebase Auth**: Xác thực người dùng (Email/Mật khẩu, Đăng nhập Google).
- **Cloud Firestore**: Cơ sở dữ liệu NoSQL để lưu trữ dữ liệu (Dự án, Công việc, Người dùng, v.v.).
- **Firebase Storage**: Lưu trữ tệp tin (thường dùng cho ảnh đại diện, tệp đính kèm).
- **Firebase Messaging**: Thông báo đẩy (Push notifications).

### Dependency Injection (Tiêm phụ thuộc)

- **GetIt**: Service locator dùng cho dependency injection.

### Code Generation & Tiện ích

- **Freezed**: Dùng để tạo các lớp immutable và unions (hữu ích cho các state/event của Bloc).
- **Flutter SVG**: Để hiển thị các tài sản ảnh vector (SVG).
- **Flutter Local Notifications**: Để xử lý thông báo cục bộ.

## 3. Cấu trúc Thư mục (`lib/`)

Dự án được cấu trúc như sau:

- **`core/`**: Chứa các tiện ích cốt lõi, hằng số, cơ chế xử lý lỗi và logic dùng chung.
- **`data/`**: Triển khai lớp `domain`.
  - `models/`: DTOs (Data Transfer Objects) dùng để phân tích dữ liệu JSON/Firestore.
  - `repositories/`: Triển khai các giao diện repository để lấy dữ liệu từ Firebase.
  - `datasources/`: Tương tác trực tiếp với các API bên ngoài hoặc cơ sở dữ liệu.
- **`domain/`**: Lớp trong cùng, độc lập với các thư viện bên ngoài.
  - `entities/`: Các đối tượng nghiệp vụ cốt lõi (`User`, `Project`, `Task`, `Message`, v.v.).
  - `repositories/`: Các định nghĩa trừu tượng của repository.
  - `usecases/`: Đóng gói các quy tắc nghiệp vụ cụ thể (ví dụ: `CreateTaskUseCase`).
- **`presentation/`**: Lớp giao diện người dùng.
  - `screens/`: Các trang ứng dụng được tổ chức theo tính năng (`auth`, `home`, `project`, `task`, `chat`, `profile`).
  - `blocs/`: Các thành phần logic kết nối UI với Domain use cases.
  - `widgets/`: Các thành phần UI có thể tái sử dụng.
- **`main.dart`**: Điểm bắt đầu của ứng dụng, xử lý việc khởi tạo và chạy ứng dụng.
- **`firebase_options.dart`**: Cấu hình tự động sinh ra cho Firebase.

## 4. Các tính năng chính & Thực thể

Dựa trên phân tích mã nguồn, ứng dụng bao gồm các tính năng chính sau:

### Xác thực (`auth`)

- Màn hình Đăng nhập và Đăng ký.
- Tích hợp Đăng nhập Google.

### Dự án (`project`)

- Tạo và quản lý các dự án.
- Thực thể `Project` có thể chứa các thông tin như tên, mô tả, thành viên, v.v.

### Công việc (`task`)

- Quản lý công việc chi tiết trong các dự án.
- **Độ ưu tiên (Task Priorities)**: Sử dụng `TaskPriority` để phân loại mức độ khẩn cấp.
- **Bình luận**: Người dùng có thể thảo luận về công việc (`TaskComment`).
- Màn hình chi tiết để xem tiến độ công việc.

### Giao tiếp (`chat`)

- Khả năng nhắn tin thời gian thực (thực thể `Message`).
- Có thể hỗ trợ giao tiếp theo dự án hoặc trực tiếp giữa các thành viên.

### Thông báo (`notification`)

- Thực thể `AppNotification`.
- Tích hợp với Firebase Messaging cho thông báo đẩy.
- Thông báo cục bộ cho các cảnh báo trong ứng dụng.

### Hồ sơ người dùng (`profile`)

- Quản lý thông tin chi tiết người dùng (thực thể `User`).

## 5. Cài đặt môi trường phát triển

Để chạy dự án này, bạn cần:

1.  Đã cài đặt **Flutter SDK**.
2.  Đã cấu hình **Firebase Project** (với `google-services.json` cho Android và `GoogleService-Info.plist` cho iOS).
3.  Chạy lệnh `flutter pub get` để cài đặt các thư viện phụ thuộc.
4.  Chạy lệnh `dart run build_runner build` để sinh mã cho Freezed/JSON serialization nếu cần.
