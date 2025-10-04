# Hướng dẫn tuỳ chỉnh cho GitHub Copilot

## Ngôn ngữ phản hồi
- **Luôn giao tiếp và giải thích bằng Tiếng Việt.**  
- Mọi comment, mô tả commit, message trong template và giải thích kèm code phải là Tiếng Việt rõ ràng, dễ hiểu.

---

## Quy tắc chung cho dự án Flutter
- **Framework:** Dự án sử dụng **Flutter**. Tất cả gợi ý về code, cấu trúc thư mục, patterns phải tuân theo best practices của Flutter hiện đại.
- **Không trộn logic nghiệp vụ vào UI.** UI chỉ xử lý hiển thị và tương tác, mọi logic nằm trong ViewModel / UseCase / Repository tương ứng.

---

## Kiến trúc ứng dụng
- Áp dụng **Clean Architecture + MVVM** với 3 tầng tách biệt:
  - `presentation/` — UI: Screens, Widgets, ViewModels (provider/riverpod providers nằm ở tầng này).  
  - `domain/` — Entities, UseCases, Interfaces (thuần business logic).  
  - `data/` — Implementations của repositories, services (API, local DB, Firebase, mapping models).
- Mỗi lớp/tầng có rõ ràng ranh giới, dependency chỉ đi từ trên xuống (presentation → domain → data) thông qua interface.

---

## Quản lý trạng thái với Bloc
- Sử dụng **Bloc/Cubit** cho toàn bộ quản lý trạng thái.  
- Mỗi tính năng sẽ có một thư mục Bloc riêng: `presentation/blocs/feature_name/`.  
  - Ví dụ: `task_bloc.dart`, `task_event.dart`, `task_state.dart`.  
- **Event → Bloc → State** phải tuân thủ tuần tự:
  - UI bắn **Event** → Bloc xử lý logic → phát ra **State** → UI rebuild theo State.  
- Chỉ Bloc được phép gọi **UseCase** từ domain layer.  
- UI không gọi repository trực tiếp.  

### Quy tắc đặt tên khi dùng Bloc
- Bloc class kết thúc bằng `Bloc`, ví dụ: `TaskBloc`.  
- State class kết thúc bằng `State`, ví dụ: `TaskState`.  
- Event class kết thúc bằng `Event`, ví dụ: `TaskCreatedEvent`.  
- File phải dùng `snake_case.dart`, ví dụ: `task_bloc.dart`.  

### Cách tổ chức Bloc
- **Một feature = Một Bloc** (hoặc Cubit nếu chỉ cần state đơn giản).  
- Nếu logic phức tạp (ví dụ chat, phân quyền), ưu tiên dùng Bloc thay vì Cubit.  
- Với Stream real-time từ Firebase, sử dụng `StreamSubscription` trong Bloc để lắng nghe và emit state mới.  

### Testing với Bloc
- Mỗi Bloc cần có test:
  - Test khi gửi Event thì State có thay đổi đúng không.  
  - Test với các trường hợp bất thường (lỗi mạng, không đủ quyền...).  

### Ví dụ flow
- `UI` → dispatch `AddTaskEvent(task)`  
- `TaskBloc` → gọi `CreateTaskUseCase` → gọi `TaskRepository`  
- `Firestore` lưu dữ liệu → emit `TaskCreatedState`  
- `UI` rebuild dựa trên `TaskCreatedState`.  

---

## Quy tắc đặt tên & cấu trúc file
- Tên màn hình: kết thúc bằng `Screen` → `home_screen.dart`.  
- Tên widget tái sử dụng: kết thúc bằng `Widget` → `task_card_widget.dart`.  
- Provider: tên kết thúc bằng `Provider` → `authProvider` / `taskListProvider`.  
- File dùng `snake_case.dart`.  
- Thư mục ví dụ:
lib/
├─ main.dart
│
├─ core/                         # Thành phần dùng chung
│  ├─ constants/                 # Hằng số, route name, key
│  │   ├─ app_colors.dart
│  │   ├─ app_routes.dart
│  │   └─ firebase_keys.dart
│  ├─ errors/                    # Exception, Failure
│  │   └─ failures.dart
│  ├─ utils/                     # Helpers, formatters, validators
│  ├─ theme/                     # Theme, typography, light/dark mode
│  └─ widgets/                   # Widgets tái sử dụng (Button, Loader, Snackbar)
│
├─ data/
│  ├─ datasources/               # Firebase / REST / Local DB
│  │   ├─ firebase/
│  │   │   ├─ auth_service.dart
│  │   │   ├─ task_service.dart
│  │   │   └─ chat_service.dart
│  │   └─ local/
│  │       └─ sqflite_helper.dart
│  ├─ models/                    # Data Models (freezed + json_serializable)
│  │   ├─ task_model.dart
│  │   ├─ project_model.dart
│  │   ├─ message_model.dart
│  │   └─ user_model.dart
│  └─ repositories_impl/          # Implement Repository (implements domain interface)
│      ├─ auth_repository_impl.dart
│      ├─ task_repository_impl.dart
│      └─ chat_repository_impl.dart
│
├─ domain/
│  ├─ entities/                  # Business entities (pure Dart)
│  │   ├─ task.dart
│  │   ├─ project.dart
│  │   ├─ message.dart
│  │   └─ user.dart
│  ├─ repositories/              # Abstract Repository Interface
│  │   ├─ auth_repository.dart
│  │   ├─ task_repository.dart
│  │   └─ chat_repository.dart
│  └─ usecases/                  # Business logic (1 usecase = 1 file)
│      ├─ login_user.dart
│      ├─ create_task.dart
│      ├─ update_task.dart
│      └─ send_message.dart
│
├─ presentation/
│  ├─ screens/                   # UI Screens
│  │   ├─ auth/
│  │   │   ├─ login_screen.dart
│  │   │   └─ signup_screen.dart
│  │   ├─ project/
│  │   │   ├─ project_list_screen.dart
│  │   │   └─ project_detail_screen.dart
│  │   ├─ task/
│  │   │   ├─ task_list_screen.dart
│  │   │   └─ task_detail_screen.dart
│  │   └─ chat/
│  │       └─ chat_screen.dart
│  ├─ blocs/                     # Bloc / Cubit cho từng feature
│  │   ├─ auth/
│  │   │   ├─ auth_bloc.dart
│  │   │   ├─ auth_event.dart
│  │   │   └─ auth_state.dart
│  │   ├─ project/
│  │   │   ├─ project_bloc.dart
│  │   │   ├─ project_event.dart
│  │   │   └─ project_state.dart
│  │   ├─ task/
│  │   │   ├─ task_bloc.dart
│  │   │   ├─ task_event.dart
│  │   │   └─ task_state.dart
│  │   └─ chat/
│  │       ├─ chat_bloc.dart
│  │       ├─ chat_event.dart
│  │       └─ chat_state.dart
│  └─ widgets/                   # Widget tái sử dụng trong UI
│      ├─ task_card_widget.dart
│      ├─ message_bubble_widget.dart
│      └─ progress_chart_widget.dart
│
└─ test/                         # Unit & Widget tests
   ├─ domain/
   ├─ data/
   └─ presentation/

---
## Quy tắc đặt tên và tổ chức Widget (UI)

### 1. Nguyên tắc chung
- Mỗi **Widget** phải được định nghĩa trong **file riêng**, tên file dùng `snake_case.dart`.  
  - Ví dụ: `task_card_widget.dart`, `project_list_item_widget.dart`.  
- **Tên class** của widget phải mô tả rõ ràng vai trò hoặc nội dung hiển thị.  
  - Ví dụ:  
    - `TaskCardWidget` → hiển thị thẻ công việc.  
    - `ProjectHeaderWidget` → hiển thị tiêu đề project.  
    - `ChatMessageBubbleWidget` → hiển thị bong bóng tin nhắn.  
- Không đặt tên chung chung như `MyWidget`, `CustomWidget`, `ContainerWidget`, v.v.

### 2. Cấu trúc thư mục
- Tất cả widget UI nằm trong thư mục `presentation/widgets/`.  
- Các widget đặc thù của một màn hình nên đặt trong thư mục con

### 3. Quy tắc tạo và đặt tên Widget
- Mỗi Widget nên đặt trong file riêng, theo định dạng: `snake_case.dart`.
- Tên class luôn kết thúc bằng **Widget**, ví dụ:
  - `TaskCardWidget`
  - `ProjectHeaderWidget`
  - `ChatMessageBubbleWidget`
- Mỗi màn hình có thư mục `widgets/` riêng để chứa các widget đặc thù.
- Các widget tái sử dụng chung cho nhiều màn hình → đặt trong `presentation/widgets/`.
- Phải có mô tả ngắn gọn ở đầu class:
  ```dart
  /// Widget hiển thị thông tin chi tiết của một công việc (Task)
  class TaskDetailCardWidget extends StatelessWidget { ... }

---
## Giao diện (UI / UX)
- Tuân theo **Material Design 3**.  
- Tập trung vào accessibility, responsive layout, hỗ trợ **chế độ sáng & tối**.  
- Theme tập trung trong một file `theme/theme.dart` (colors, typography, shapes).  
- Tạo components UI nhỏ, tái sử dụng (buttons, cards, form fields).

---

## Dữ liệu & Local Storage
- **Local DB:** dùng `sqflite` cho lưu offline / cache.  
- **Models:** đặt trong `models/`, immutable (sử dụng `freezed` cho data classes).  
- **Khi fetch từ API / DB:** wrap kết quả trong `Result<T>` (trạng thái `success` / `error` / `loading`) để dễ xử lý ở presentation layer.  
- Mapping giữa data model (data layer) và domain entity phải rõ ràng và tách biệt.

---

## Kiểm thử (Testing)
- Mỗi UseCase có **unit test**.  
- Các màn hình chính có **widget test** tối thiểu (render, interaction cơ bản).  
- File test đặt ở `test/` và tên file test kết thúc bằng `_test.dart`.  
- Mocks cho repository/datasource (ví dụ dùng `mocktail`).

---

## Quy tắc code & công cụ
- Chạy `dart format` trước khi commit.  
- Dùng `lint` với rule nghiêm ngặt (cấu hình trong `analysis_options.yaml`).  
- Viết comment (doc comments) cho tất cả class / method public.  
- Tập trung code có thể tái sử dụng, module hóa và dễ unit test.

---

## Hướng dẫn cho AI (Copilot / Assistant)
- Khi sinh code, **luôn tuân theo quy tắc ở trên**.  
- Ưu tiên viết code **dễ kiểm thử, module hoá, rõ ràng**; tránh shortcuts phá kiến trúc.  
- Không sinh code "tắt" (viết nhanh, vi phạm kiến trúc hoặc bypass tầng domain/data).  
- Khi đưa ra snippet code: kèm theo **giải thích bằng tiếng Việt** (mục đích snippet, nơi đặt file, vì sao thiết kế vậy).  
- Nếu có nhiều cách làm, trình bày **ngắn gọn ưu/nhược điểm** từng cách và đề xuất 1 phương án ưu tiên.

---

## Yêu cầu về mô tả khi gợi ý code
- Mỗi gợi ý code phải gồm:
1. **Mục đích** (một câu).  
2. **File/đường dẫn đề xuất** (ví dụ `lib/presentation/viewmodels/task_viewmodel.dart`).  
3. **Đoạn code mẫu** (đầy đủ, tuân theo lint).  
4. **Giải thích chi tiết từng bước** — tại sao làm như vậy, luồng dữ liệu qua các tầng, cách test.  
- Nếu logic phức tạp: giải thích bằng ngôn ngữ dễ hiểu, không chỉ ném code.

---

## Báo cáo & phân tích lỗi
- Khi phát hiện hoặc yêu cầu phân tích lỗi, cung cấp:
- Nguyên nhân gốc rễ.  
- Các đoạn mã nguồn liên quan (file và dòng tham khảo).  
- Ít nhất **một** giải pháp cụ thể để khắc phục (với pros/cons).  
- Nếu cần, kèm thêm test case đơn giản để tái tạo lỗi.

---

## Thiết kế chi tiết (Detailed Design)
- **Ưu tiên hàng đầu:** Nếu dự án có file `detailed design`, mọi gợi ý kiến trúc, luồng dữ liệu, hoặc business logic **phải tuân thủ tuyệt đối** tài liệu đó.  
- Nếu có xung đột giữa guideline này và `detailed design`, ưu tiên `detailed design` và giải thích lý do khi đề xuất khác biệt.

---

## Các quy tắc bổ sung (best practices)
- Dùng `freezed` + `json_serializable` cho models để đảm bảo immutability và mapping.  
- Sử dụng dependency injection (ví dụ `riverpod`'s `Provider` hoặc `get_it`) theo một pattern nhất quán.  
- Tách rõ các service (AuthService, TaskService, StorageService) trong `data/datasources` hoặc `data/services`.  
- Tránh hardcode string/keys — đưa vào `constants/` hoặc config.

---

## Lưu ý khi review PR / merge
- Kiểm tra sự tuân thủ kiến trúc (không có business logic trong UI).  
- Kiểm tra test coverage cho UseCase quan trọng.  
- Chạy `dart analyze` và `dart format`.  
- Đảm bảo có mô tả rõ trong PR: thay đổi gì, lý do, ảnh hưởng ở đâu.
