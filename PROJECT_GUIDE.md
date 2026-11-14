# 🌟 TÀI LIỆU TOÀN DIỆN DỰ ÁN SKETCHTALE (MOBILE APP)
> **Ứng dụng:** SketchTale - Nền tảng Đọc truyện Tương tác & Sáng tạo Nghệ thuật cho Trẻ em  
> **Nền tảng:** Flutter (Hỗ trợ Điện thoại & Máy tính bảng / iPad)  
> **Kiến trúc:** Layered Service Architecture kết hợp State Management (ChangeNotifier)  
> **Quyền hạn Mobile:** Vai trò Trẻ em (**Role Child**)  
> **Cập nhật:** Tháng 10/2026

---

## 📌 MỤC LỤC
1. [Giới thiệu & Triết lý Thiết kế](#1-giới-thiệu--triết-lý-thiết-kế)
2. [Cấu trúc Thư mục Tổng thể](#2-cấu-trúc-thư-mục-tổng-thể)
3. [Chi tiết Chức năng Từng File trong Dự án](#3-chi-tiết-chức-năng-từng-file-trong-dự-án)
   - [3.1. Thư mục Gốc & Cấu hình (Root Config)](#31-thư-mục-gốc--cấu-hình-root-config)
   - [3.2. Models (`lib/models/`)](#32-models-libmodels)
   - [3.3. Services (`lib/services/`)](#33-services-libservices)
   - [3.4. State Management (`lib/state/`)](#34-state-management-libstate)
   - [3.5. Screens (`lib/screens/`)](#35-screens-libscreens)
   - [3.6. Widgets (`lib/widgets/`)](#36-widgets-libwidgets)
   - [3.7. Theme & Utils (`lib/theme/` & `lib/utils/`)](#37-theme--utils-libtheme--libutils)
   - [3.8. Bộ Kiểm thử Tự động (`test/`)](#38-bộ-kiểm-thử-tự-động-test)
4. [Bản đồ Tích hợp Swagger Backend API (Role Child)](#4-bản-đồ-tích-hợp-swagger-backend-api-role-child)
5. [Quy trình Khởi chạy & Phát triển](#5-quy-trình-khởi-chạy--phát-triển)

---

## 1. GIỚI THIỆU & TRIẾT LÝ THIẾT KẾ

**SketchTale** là ứng dụng di động giáo dục tương tác, nơi trẻ em có thể:
1. **Tự tay vẽ tranh nhân vật:** Bé vẽ nhân vật yêu thích trên bảng vẽ số.
2. **Hóa phép nhân vật vào truyện:** Tranh vẽ của bé được biến thành nhân vật sống động có tương tác vật lý (Squash & Stretch), có thể nhảy, đi dạo, kéo thả.
3. **Đóng vai & Đọc truyện:** Bé gán nhân vật của mình vào vai chính hoặc bạn đồng hành trong câu chuyện. Vị trí nhân vật trên từng trang được dàn trang tự động từ Backend.
4. **Học từ vựng & Làm Quiz:** Trong khi đọc, bé có thể bấm vào thẻ từ vựng để học phát âm/nghĩa và làm câu đố nhận sao thưởng ở cuối mỗi tập.

### Định hướng Phân quyền (Role Child):
- **Phụ huynh (Parent):** Cài đặt thời gian sử dụng, quản lý tài khoản con, mua gói đọc truyện trên **Web Portal**.
- **Trẻ em (Child):** Trên ứng dụng Mobile, bé **chỉ xem và trải nghiệm (Read & Play Only)**, không hiển thị các nút cấu hình, sửa đổi database hay thanh công cụ kỹ thuật.

---

## 2. CẤU TRÚC THƯ MỤC TỔNG THỂ

```text
d:\SkectTable\
├── .env / .env.example             # Biến môi trường (API Base URL, Endpoint)
├── analysis_options.yaml           # Quy chuẩn Static Code Analysis & Linter
├── pubspec.yaml                    # Quản lý dependencies, fonts, assets
├── AUTH_CONTROLLER_README.md       # Đặc tả Backend Auth v2.2
├── PROJECT_GUIDE.md                # Tài liệu toàn diện về toàn bộ dự án này
│
├── assets/
│   └── images/                     # Ảnh logo, minh họa, avatar mẫu
│
├── lib/
│   ├── main.dart                   # Điểm khởi chạy (Entry point) & Điều hướng tab
│   │
│   ├── models/                     # Mô hình dữ liệu (DTO & Entity)
│   │   ├── models.dart             # Central Export Hub & Model cốt lõi
│   │   ├── auth_models.dart        # Token JWT, UserProfile, ParentProfileInfo
│   │   ├── child_profile.dart      # Hồ sơ bé (Thời gian dùng, nhóm tuổi)
│   │   ├── backend_enums.dart      # Enum chuẩn Swagger (AgeGroup, RoleType...)
│   │   ├── story_role_template.dart# Bản mẫu vai diễn nhân vật trong truyện
│   │   ├── story_quiz_template.dart# Bản mẫu câu đố & trắc nghiệm nhận thưởng
│   │   └── vocabulary_template.dart# Thẻ từ vựng học tiếng Anh trong trang truyện
│   │
│   ├── services/                   # Tầng gọi Backend REST API (HTTP Client)
│   │   ├── auth_service.dart       # Xác thực: 14 API AuthController, Blacklist, Rotation
│   │   ├── story_service.dart      # Lấy truyện theo tuổi, dàn trang slot, vai diễn
│   │   ├── child_profile_service.dart # Lấy hồ sơ bé từ /api/child-profiles
│   │   ├── quiz_service.dart       # Lấy câu đố theo truyện từ /api/story-template
│   │   └── vocabulary_service.dart # Lấy từ vựng theo trang từ /api/story-pages
│   │
│   ├── state/
│   │   └── app_state.dart          # Quản lý trạng thái tập trung (ChangeNotifier)
│   │
│   ├── screens/                    # Toàn bộ màn hình giao diện người dùng
│   │   ├── login_screen.dart       # Màn hình đăng nhập tài khoản của bé
│   │   ├── home_screen.dart        # Trang chủ: Streak, thời gian dùng, đề xuất truyện
│   │   ├── library_screen.dart     # Thư viện sách truyện phân theo chủ đề & độ tuổi
│   │   ├── drawing_screen.dart     # Bảng vẽ tranh cảm ứng cho bé sáng tạo
│   │   ├── magic_transform_screen.dart # Hiệu ứng phép thuật biến tranh thành nhân vật
│   │   ├── story_player_screen.dart# Khung đọc truyện tương tác, audio, slot nhân vật
│   │   ├── role_assignment_screen.dart # Giao diện gán nhân vật bé vẽ vào vai truyện
│   │   ├── child_profile_screen.dart # Xem hồ sơ, ngôi sao, tiến độ học của bé
│   │   ├── quiz_reward_screen.dart # Màn hình làm câu đố trắc nghiệm nhận thưởng sao
│   │   └── collection_screen.dart  # Bộ sưu tập tranh vẽ và nhân vật của bé
│   │
│   ├── widgets/                    # Các thành phần giao diện tái sử dụng
│   │   ├── squash_stretch_character.dart # Hoạt họa nhún nảy đàn hồi vật lý
│   │   └── squishy_button.dart     # Nút bấm 3D phong cách hoạt hình ngộ nghĩnh
│   │
│   ├── theme/
│   │   └── app_theme.dart          # Hệ thống màu sắc (Pastel), typography, border
│   │
│   └── utils/                      # Tiện ích bổ trợ
│       ├── app_config.dart         # Quản lý URL và toàn bộ endpoint Swagger
│       └── responsive.dart         # Xử lý responsive cho Phone và iPad/Tablet
│
└── test/                           # Bộ kiểm thử tự động (100% Pass)
    ├── auth_test.dart              # Kiểm thử xác thực, JWT blacklist, token rotation
    ├── child_profile_test.dart     # Kiểm thử hồ sơ bé & thuật toán đề xuất theo tuổi
    ├── quiz_test.dart              # Kiểm thử câu đố trắc nghiệm
    ├── story_slot_test.dart        # Kiểm thử tọa độ slot nhân vật dàn trang
    ├── story_template_test.dart    # Kiểm thử danh sách truyện & vai diễn động
    ├── vocabulary_test.dart        # Kiểm thử từ vựng trang truyện
    └── widget_test.dart            # Smoke test UI trên Phone & Tablet
```

---

## 3. CHI TIẾT CHỨC NĂNG TỪNG FILE TRONG DỰ ÁN

### 3.1. Thư mục Gốc & Cấu hình (Root Config)

| Tên File | Vai trò & Mục đích sử dụng |
| :--- | :--- |
| **`pubspec.yaml`** | Khai báo toàn bộ thư viện phụ thuộc (`http`, `flutter_dotenv`, `google_fonts`, `flutter_test`), cấu hình đường dẫn tài nguyên `assets/images/` và kích hoạt Material Design. |
| **`.env`** / **`.env.example`** | Chứa cấu hình biến môi trường cục bộ, cụ thể là địa chỉ máy chủ `API_BASE_URL=https://sketch-tale-be.onrender.com` và endpoint đăng nhập. |
| **`analysis_options.yaml`** | Thiết lập các quy tắc phân tích mã nguồn nghiêm ngặt (`flutter_lints`) để đảm bảo code sạch, không có cảnh báo dư thừa. |
| **`AUTH_CONTROLLER_README.md`** | Bản đặc tả chi tiết v2.2 do đội ngũ Backend cung cấp, mô tả cơ chế xác thực JWT 60 phút, Refresh Token Rotation 7 ngày, JWT Blacklist khi Logout. |
| **`PROJECT_GUIDE.md`** | File tài liệu này: Bản đồ kiến trúc chi tiết, giải thích vai trò từng file trong hệ thống. |

---

### 3.2. Models (`lib/models/`)

| Tên File | Chức năng chi tiết |
| :--- | :--- |
| **`models.dart`** | **Trục xuất nhập khẩu (Central Export Hub)** của toàn bộ thư mục models. Khai báo các thực thể giao diện: `Story` (cuốn truyện), `StoryPage` (trang truyện), `KidCharacter` (nhân vật của bé), `DrawingPoint` (nét vẽ canvas), `CharacterSlotTemplate` (tọa độ slot dàn trang). |
| **`auth_models.dart`** | Chứa `AuthTokenData` (chứa `token`, `refreshToken`, `role`, `username`), `UserProfile` và `ParentProfileInfo` ánh xạ chính xác định dạng JSON từ `POST /api/auth/login/child` và `GET /api/auth/profile`. |
| **`child_profile.dart`** | Ánh xạ hồ sơ của bé từ `GET /api/child-profiles`: `nickName`, `dailyTimeLimit` (giới hạn thời gian), `targetAgeGroup` (nhóm tuổi 0: Mầm non, 1: Tiểu học, 2: Thiếu niên), `stars` và `streakDays`. |
| **`backend_enums.dart`** | Chứa các kiểu liệt kê enum đồng bộ 1:1 với Backend: `TargetAgeGroup`, `CommonStatus`, `StoryRoleType` (MainCharacter, Companion, Supporting...), `QuizType`. |
| **`story_role_template.dart`** | Mô hình vai diễn trong truyện từ `GET /api/story-template/{storyId}/roles`: Tên vai, mô tả tính cách, câu thoại mẫu, mức độ quan trọng để bé phân vai cho nhân vật của mình. |
| **`story_quiz_template.dart`** | Mô hình câu đố từ `GET /api/story-template/{storyId}/quizzes`: Câu hỏi, danh sách đáp án, giải thích ngộ nghĩnh, số sao thưởng. |
| **`vocabulary_template.dart`** | Mô hình từ vựng từ `GET /api/story-pages/{pageId}/vocabularies`: Từ vựng tiếng Anh, phiên âm, nghĩa tiếng Việt, câu ví dụ để bé chạm vào học khi đọc truyện. |

---

### 3.3. Services (`lib/services/`)

| Tên File | Chức năng chi tiết |
| :--- | :--- |
| **`auth_service.dart`** | Tầng kết nối mạng xác thực: <br>• `loginChild()`: Đăng nhập bé bằng `username`/`password`.<br>• `logout()`: Gửi `POST /api/auth/logout` để server đưa token vào **JWT Blacklist**.<br>• `refreshToken()`: Triển khai **Refresh Token Rotation** (lấy access token mới & refresh token mới).<br>• `getProfile()` & `getCurrentRole()`: Lấy thông tin cá nhân và vai trò hiện tại. |
| **`story_service.dart`** | Xử lý tải dữ liệu truyện: <br>• `fetchStoriesSortedByAgeGroup()`: Lấy danh sách truyện và tự động sắp xếp theo độ tuổi của bé.<br>• `fetchStoryTemplatePages()`: Lấy danh sách trang truyện theo `storyId`.<br>• `fetchStoryRoles()`: Tải các vai diễn trong truyện để gán nhân vật.<br>• `fetchPageSlots()`: Tải tọa độ `posX`, `posY`, `scale`, `flipHorizontal` từ `GET /api/story-pages/{pageId}/slots`. |
| **`child_profile_service.dart`** | Kết nối `GET /api/child-profiles` để đồng bộ thông tin hồ sơ của bé (thời gian được phép chơi, số sao, số ngày streak). Chế độ chỉ đọc cho trẻ. |
| **`quiz_service.dart`** | Kết nối `GET /api/story-template/{storyId}/quizzes` để tải các câu đố học tập gắn liền với cốt truyện. |
| **`vocabulary_service.dart`** | Kết nối `GET /api/story-pages/{pageId}/vocabularies` để tải các từ mới xuất hiện trong trang truyện mà bé đang đọc. |

---

### 3.4. State Management (`lib/state/`)

| Tên File | Chức năng chi tiết |
| :--- | :--- |
| **`app_state.dart`** | **Trái tim trạng thái của toàn ứng dụng (`ChangeNotifier`)**: <br>• Lưu trữ phiên đăng nhập: `authToken`, `refreshToken`, `userRole`, `childUsername`.<br>• Lưu trữ danh sách truyện mẫu, chủ đề giáo dục, nhân vật của bé.<br>• Lưu trữ nhân vật chính (`heroCharacter`) và nhân vật đồng hành (`companionCharacter`).<br>• Tự động đề xuất truyện phù hợp nhất dựa trên độ tuổi của hồ sơ bé (`recommendedStories`).<br>• Quản lý hàm `login()` đồng bộ dữ liệu và `logout()` hủy token trên server. |

---

### 3.5. Screens (`lib/screens/`)

| Tên Màn hình | File Path | Mục đích & Nghiệp vụ giao diện |
| :--- | :--- | :--- |
| **Đăng Nhập** | `login_screen.dart` | Giao diện đăng nhập thân thiện với trẻ nhỏ. Bé chỉ cần nhập tên đăng nhập và mật khẩu (hoặc vào chơi ngay với tài khoản mẫu). Gửi yêu cầu qua `AuthService.loginChild`. |
| **Trang Chủ** | `home_screen.dart` | Trung tâm điều khiển của bé: Hiển thị lời chào cá nhân hóa, huy hiệu chuỗi ngày học (Streak 🔥), số sao tích lũy (⭐), đồng hồ đếm thời gian chơi trong ngày và danh sách truyện gợi ý bám sát độ tuổi. |
| **Thư Viện Truyện**| `library_screen.dart` | Kho truyện cổ tích và bài học cuộc sống. Cho phép bé chọn lọc theo chủ đề giáo dục (Thiên nhiên, Lòng tốt, Sáng tạo, Tình bạn...) và độ tuổi. |
| **Khung Đọc Truyện**| `story_player_screen.dart` | Trải nghiệm đọc truyện đa giác quan: <br>• Lật trang mượt mà kèm đom đóm bay lấp lánh.<br>• Tự động tải slot từ API để đặt nhân vật của bé vào đúng khung cảnh.<br>• Giọng đọc kể chuyện audio ấm áp.<br>• Thẻ từ vựng chạm để nghe phát âm và xem nghĩa.<br>• Bé có thể kéo thả nhân vật tự do trên trang. |
| **Bảng Vẽ Sáng Tạo**| `drawing_screen.dart` | Bảng vẽ cảm ứng: Cung cấp bút vẽ nhiều màu, bảng màu ma thuật, tẩy xóa, tăng giảm nét vẽ để bé tự do vẽ nhân vật tưởng tượng của mình. |
| **Hóa Phép 3D** | `magic_transform_screen.dart` | Màn hình chuyển tiếp ma thuật: Khi bé vẽ xong, hiệu ứng ánh sáng lấp lánh sẽ biến bức tranh 2D của bé thành nhân vật sống động sẵn sàng bước vào thế giới truyện tranh. |
| **Phân Vai Truyện**| `role_assignment_screen.dart` | Giao diện chọn vai: Tải các vai diễn từ API (`GET /api/story-template/{id}/roles`) để bé chọn ai sẽ đóng vai chính, ai là bạn đồng hành cùng bé thám hiểm. |
| **Hồ Sơ Của Bé** | `child_profile_screen.dart` | Xem thông tin cá nhân của bé, nhóm tuổi, giới hạn thời gian xem do ba mẹ đặt trên Web, và nút đồng bộ nhanh dữ liệu từ máy chủ. |
| **Thử Thách Quiz** | `quiz_reward_screen.dart` | Trò chơi đố vui tương tác ở cuối mỗi truyện. Bé trả lời câu hỏi ôn bài để nhận pháo hoa chúc mừng và cộng thêm sao thưởng. |
| **Bộ Sưu Tập** | `collection_screen.dart` | Phòng trưng bày toàn bộ nhân vật mà bé đã sáng tạo ra, danh sách các huy hiệu và thành tích đã mở khóa. |

---

### 3.6. Widgets (`lib/widgets/`)

| Tên Widget | File Path | Đặc điểm kỹ thuật |
| :--- | :--- | :--- |
| **`SquashStretchCharacter`** | `squash_stretch_character.dart` | Widget hoạt họa đàn hồi dạng nảy (Squash & Stretch physics): Cho phép bé chạm vào để nhân vật bật nhảy, rung màn hình nhẹ, nhún thở tự nhiên, hiện bong bóng thoại khích lệ và hỗ trợ kéo thả (`enableDrag: true`). |
| **`Squishy3DButton`** | `squishy_button.dart` | Nút bấm 3D phong cách Jelly/Cartoon: Có độ dày viền nổi (depth), khi chạm vào sẽ lún xuống tạo cảm giác bấm xúc giác cực kỳ đã tay và vui nhộn cho trẻ nhỏ. |

---

### 3.7. Theme & Utils (`lib/theme/` & `lib/utils/`)

| Tên File | Vai trò |
| :--- | :--- |
| **`app_theme.dart`** | Chứa bảng màu chuẩn Material 3 tùy chỉnh: Màu kem sữa chủ đạo (`surfaceContainerLowest`), màu mật ong ấm áp (`primary`), xanh mint tươi sáng (`secondary`), typography bo tròn thân thiện với trẻ nhỏ. |
| **`app_config.dart`** | Bộ quản lý tập trung toàn bộ cấu hình: Nạp file `.env`, sinh URL cho toàn bộ 14 API Auth, API Story, API Role, API Page, API Slot, API Quiz, API Vocab. |
| **`responsive.dart`** | Tính toán padding, font size, tỉ lệ khung hình phù hợp khi ứng dụng chạy trên điện thoại hoặc máy tính bảng/iPad. |

---

### 3.8. Bộ Kiểm thử Tự động (`test/`)
Dự án được bảo vệ bởi **25 bài kiểm thử đơn vị tự động (Unit Tests)**, đảm bảo không có lỗi hồi quy (regression bugs):

| Tên File Test | Nội dung kiểm thử |
| :--- | :--- |
| **`auth_test.dart`** | Kiểm tra chuyển đổi dữ liệu `AuthTokenData`, `UserProfile`, sinh đúng 14 URL Auth và quy trình đăng xuất xóa token khỏi AppState. |
| **`child_profile_test.dart`** | Kiểm thử phân giải hồ sơ bé, hiển thị nhóm tuổi thân thiện và thuật toán tự động đề xuất truyện theo tuổi. |
| **`story_template_test.dart`** | Kiểm thử danh sách truyện từ Backend, sắp xếp tuổi tăng dần và ánh xạ vai diễn động. |
| **`story_slot_test.dart`** | Kiểm thử chuyển đổi JSON tọa độ slot nhân vật, hàm `copyWith` và URL endpoint slot. |
| **`quiz_test.dart`** | Kiểm thử phân giải dữ liệu câu đố, fallback mảng options và chuyển đổi sang QuizQuestion tương tác. |
| **`vocabulary_test.dart`** | Kiểm thử nạp thẻ từ vựng trang truyện. |
| **`widget_test.dart`** | Khởi chạy smoke test ứng dụng trên màn hình điện thoại và máy tính bảng iPad. |

---

## 4. BẢN ĐỒ TÍCH HỢP SWAGGER BACKEND API (ROLE CHILD)

Ứng dụng tuân thủ nghiêm ngặt mô hình phân tách vai trò:

| Phân hệ Swagger | Endpoint Backend | Quyền hạn Mobile (Bé) | Hành vi trên ứng dụng |
| :--- | :--- | :---: | :--- |
| **AuthController** | `POST /api/auth/login/child` | Public | Đăng nhập tài khoản bé bằng username/password |
| **AuthController** | `POST /api/auth/logout` | Authorize | Đăng xuất và đưa token vào JWT Blacklist trên server |
| **AuthController** | `POST /api/auth/refresh-token` | Authorize | Tự động làm mới phiên làm việc khi token 60p hết hạn |
| **AuthController** | `GET /api/auth/profile` | Authorize | Tải thông tin cá nhân và quyền hạn |
| **StoryTemplate** | `GET /api/story-template/stories` | Authorize | Tải danh sách truyện có status Actived |
| **StoryPageTemplate** | `GET /api/storypage-template/pages/{storyId}` | Authorize | Tải nội dung từng trang của cuốn truyện |
| **StoryRoleTemplate**| `GET /api/story-template/{storyId}/roles` | Authorize | Tải các vai diễn trong truyện để bé gán nhân vật |
| **CharacterSlotTemplate**| `GET /api/story-pages/{pageId}/slots` | Authorize | Tải tọa độ vị trí dàn trang nhân vật (Read-only) |
| **VocabularyTemplate** | `GET /api/story-pages/{pageId}/vocabularies`| Authorize | Tải danh sách từ vựng của trang truyện |
| **StoryQuizTemplate** | `GET /api/story-template/{storyId}/quizzes` | Authorize | Tải câu đố trắc nghiệm cuối truyện |
| **ChildProfile** | `GET /api/child-profiles` | Authorize | Tải hồ sơ giới hạn thời gian xem do ba mẹ cài đặt |

---

## 5. QUY TRÌNH KHỞI CHẠY & PHÁT TRIỂN

### 1. Cài đặt môi trường
Đảm bảo máy đã cài đặt Flutter SDK (khuyến nghị phiên bản `>= 3.10.0`):
```bash
flutter doctor
```

### 2. Cài đặt các gói phụ thuộc
```bash
flutter pub get
```

### 3. Kiểm tra mã nguồn (Linter & Static Analysis)
```bash
flutter analyze
```
*(Kết quả yêu cầu: `No issues found!`)*

### 4. Chạy toàn bộ kiểm thử tự động
```bash
flutter test
```
*(Kết quả: `25/25 tests passed!`)*

### 5. Khởi chạy ứng dụng
- **Trên thiết bị Android / iOS hoặc Giả lập:**
```bash
flutter run
```
- **Trên Trình duyệt Web (Chrome):**
```bash
flutter run -d chrome
```

---
*Tài liệu được biên soạn đồng bộ với mã nguồn thực tế của dự án SketchTale.*
