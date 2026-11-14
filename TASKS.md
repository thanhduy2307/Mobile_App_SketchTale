# 📋 BẢNG THEO DÕI NHIỆM VỤ FRONTEND (FE TASK TRACKING) - SKETCHTALE

> **Dự án:** SketchTale - Nền Tảng Đọc Truyện Tương Tác & Sáng Tạo Nghệ Thuật Cho Trẻ Em  
> **Người phụ trách Mobile App:** **T.Duy (thanhduy2307)**  
> **Người phụ trách Web FE / Usecase:** **H.Nam**  
> **Cập nhật lần cuối:** 22/10/2026  

---

## 📊 1. BẢNG TỔNG HỢP NHIỆM VỤ (ĐỒNG BỘ VỚI GOOGLE SHEET "FE TASK")

Dưới đây là bảng tổng hợp các task đã thực hiện, định dạng chuẩn để dễ dàng đối soát và sao chép trực tiếp vào trang tính **Google Sheet FE Task**:

| Task | Person In Charge | Start Date | Deadline | Status | Detail |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **sửa figma mobile cho chil theo góp ý** | **T.Duy** | 09/09/2026 | 11/09/2026 | `Completed` | Tối ưu hóa UI/UX Figma theo phản hồi của team: Bảng màu Pastel tươi sáng, thiết kế nút bấm kẹo ngọt (Squishy 3D), ẩn các tính năng kỹ thuật của người lớn để tối ưu cho trẻ em (Role Child). |
| **đẩy giao diện figma vào mobile** | **T.Duy** | 10/09/2026 | 11/09/2026 | `Completed` | Chuyển đổi toàn bộ thiết kế Figma vào Flutter Mobile: Màn hình Home, Library, Drawing Canvas, Magic Transform, Story Player, Role Assignment, Child Profile, Quiz Reward, Collection. |
| **Nhận xét usecase** | **H.Nam** | 13/09/2026 | 13/09/2026 | `Completed` | - Phần parent thêm dashboard report ngày của trẻ<br>- Content manager thêm manage background<br>- Phần children có nên thêm trẻ có thể đọc một số story phổ biến không? |
| **Deploy FE Web** | **H.Nam** | - | - | `Completed` | [https://sketch-tale-fe-web.vercel.app/](https://sketch-tale-fe-web.vercel.app/) |
| **Phát triển hoạt họa nhân vật Squash & Stretch (6 Hành động + 3D/Spine Mesh)** | **T.Duy** | 15/09/2026 | 22/09/2026 | `Completed` | Xây dựng widget hoạt họa vật lý đàn hồi [SquashStretchCharacter](file:///d:/SkectTable/lib/widgets/squash_stretch_character.dart): 6 hành động phức tạp (Đứng yên, Đi dạo 3D, Nhảy Disco 3D, Bay lượn, Dậm đất chấn động, Đi ngủ Zzz); hỗ trợ kéo thả, nhấp đúp đổi chiêu, bong bóng thoại. |
| **Tích hợp Character Slot Template API (Dàn trang sách tự động)** | **T.Duy** | 23/09/2026 | 30/09/2026 | `Completed` | Tích hợp Swagger `/api/story-pages/{pageId}/slots`: Tự động tải tọa độ X, Y, Scale %, Lật hướng (Flip) theo từng trang truyện; lưu slot cấu hình nhanh. |
| **Tích hợp Vocabulary Template API (Thẻ từ vựng tương tác)** | **T.Duy** | 01/10/2026 | 06/10/2026 | `Completed` | Tích hợp Swagger `/api/story-pages/{pageId}/vocabularies`: Thẻ học từ vựng tiếng Anh theo ngữ cảnh trang, phát âm giọng đọc, giải thích nghĩa cho bé, hiệu ứng đom đóm sáng lấp lánh. |
| **Tích hợp Story Quiz Template & Star Reward API (Đố vui nhận thưởng)** | **T.Duy** | 07/10/2026 | 12/10/2026 | `Completed` | Tích hợp Swagger `/api/story-template`: Màn hình đố vui trắc nghiệm nhận sao thưởng cuối mỗi tập truyện [QuizRewardScreen](file:///d:/SkectTable/lib/screens/quiz_reward_screen.dart), lưu lịch sử học tập của bé. |
| **Tích hợp AuthController v2.2 & Child Profile API** | **T.Duy** | 13/10/2026 | 18/10/2026 | `Completed` | Tích hợp 14 API Swagger Auth: Đăng nhập bé, JWT Blacklist khi Logout, Refresh Token Rotation; tích hợp `/api/child-profiles` tự động gợi ý truyện theo nhóm tuổi `targetAgeGroup`. |
| **Tối ưu Responsive (Phone & Tablet/iPad) + 25 Bộ kiểm thử tự động** | **T.Duy** | 19/10/2026 | 22/10/2026 | `Completed` | Tối ưu hiển thị responsive đa thiết bị qua [responsive.dart](file:///d:/SkectTable/lib/utils/responsive.dart); hoàn thiện bộ kiểm thử tự động 25/25 bài test (Auth, Profile, Slot, Quiz, Story, Smoke Test) đạt 100% Pass và `flutter analyze` sạch lỗi. |
| **Tích hợp 5 API Bổ sung theo Spec BE (.NET 8)** | **T.Duy** | 23/10/2026 | 25/10/2026 | `Completed` | Tích hợp đầy đủ các endpoint: Upload ảnh bé vẽ lên Cloudinary (`POST /api/upload/avatar`), Lưu gán vai truyện (`POST /api/user-story-character-mappings`), Danh mục chủng loại nhân vật (`GET /api/char-types`), Báo cáo an toàn nội dung (`POST /api/content-reports`), và Bảng chi phí lượt tạo (`GET /api/credit-costs`). |
| **Đồng bộ 3 Luồng Nghiệp vụ theo Sơ đồ WORKFLOW.png** | **T.Duy** | 25/10/2026 | 27/10/2026 | `Completed` | - **Workflow 1:** Kiểm soát thời gian dùng màn hình (`remainingTimeLimit <= 0`) ngay sau đăng nhập.<br>- **Workflow 2:** Kiểm tra duyệt phụ huynh cho vai nhạy cảm (`requiresParentApproval`), lưu role mapping và tính năng báo cáo an toàn 1-chạm.<br>- **Workflow 3:** Giới hạn tạo nhân vật theo ngày (`remainingCharacterLimit <= 0`), upload canvas, AI voice/text fallback theo `CharType`, trừ lượt tạo và hoàn lại lượt nếu bé chọn "Sửa Tiếp / Thử Lại". |
| **Mở rộng Bộ Kiểm Thử Tự Động Toàn Diện (35/35 Tests Passed)** | **T.Duy** | 26/10/2026 | 27/10/2026 | `Completed` | Bổ sung bài integration unit test cho toàn bộ service và model mới trong [workflow_services_test.dart](file:///d:/SkectTable/test/workflow_services_test.dart); toàn bộ 8 test suites (35 bài) đều đạt 100% Pass và `flutter analyze` 0 issues. |
| **Tái Cấu Trúc Khung Đọc Truyện Thành Các Component Nhỏ** | **T.Duy** | 27/10/2026 | 27/10/2026 | `Completed` | Tinh gọn [StoryPlayerScreen](file:///d:/SkectTable/lib/screens/story_player_screen.dart) từ 3,129 dòng xuống cấu trúc module sạch sẽ: Tách 8 component nhỏ chuyên biệt trong [lib/widgets/story_player/](file:///d:/SkectTable/lib/widgets/story_player/); ẩn thanh thí nghiệm hoạt họa của dev khỏi màn hình bé; tối ưu typography và nút điều khiển đọc truyện kẹo ngọt Squishy 3D. |
| **Tinh Gọn Toàn Bộ Giao Diện, Xóa Bỏ Trang Thừa & Chống Rối Mắt** | **T.Duy** | 27/10/2026 | 27/10/2026 | `Completed` | - Loại bỏ trang thừa `magic_transform_screen.dart` (dead code), chuyển luồng biến hình AI trực tiếp trong [DrawingScreen](file:///d:/SkectTable/lib/screens/drawing_screen.dart).<br>- Hợp nhất hồ sơ bé và tủ đồ vào Tab 3 duy nhất: "Góc Của Bé" ([CollectionScreen](file:///d:/SkectTable/lib/screens/collection_screen.dart)), loại bỏ popup trùng lặp.<br>- Tinh gọn xưởng vẽ: 14 màu to bản 1 hàng cuộn mượt (thay vì 30 màu lí nhí 2 hàng), gỡ bỏ thanh tiến trình duyệt ảo 80% gây rối mắt.<br>- Chuẩn hóa các nút Squishy 3D đồng nhất, thay thế thuật ngữ kỹ thuật bằng từ ngữ thân thiện với trẻ thơ.<br>- Khắc phục toàn bộ nguy cơ tràn viền (overflow), đạt `flutter analyze` 0 issues và 36/36 tests passed (100%). |
| **Loại Bỏ Trang Đố Vui Thừa & Mở Nút Tùy Chỉnh Hoạt Họa (Animation Customizer)** | **T.Duy** | 27/10/2026 | 27/10/2026 | `Completed` | - Loại bỏ hoàn toàn trang và tab Đố Vui thừa khỏi trình đọc truyện theo yêu cầu của bạn.<br>- Tạo component [StoryAnimationSheet](file:///d:/SkectTable/lib/widgets/story_player/story_animation_sheet.dart) hiển thị bảng điều khiển trực quan thời gian thực.<br>- Bổ sung nút **"🎭 Hoạt Họa"** trên thanh tab bar, nút **"🎭 Animation"** trên góc Canvas tranh vẽ và thanh gợi ý tương tác phía dưới.<br>- Cho phép tùy chỉnh 6 chiêu thức (`idle`, `patrol`, `dance`, `fly`, `stomp`, `sleep`), 2 engine vật lý (State Machine 3D vs Spine Jelly Mesh), thanh trượt scale %, lật hướng quay mặt, rung chấn và hiệu ứng đom đóm.<br>- Đạt `flutter analyze` 0 issues và 36/36 tests passed (100%). |

---

## 🎯 2. CHI TIẾT CÁC CÔNG VIỆC T.DUY ĐÃ THỰC HIỆN TRÊN MOBILE REPO

### 1. Sửa Figma Mobile & Đẩy giao diện vào Mobile App (Flutter)
- **Thiết kế & Chuyển giao UI:**
  - [HomeScreen](file:///d:/SkectTable/lib/screens/home_screen.dart): Giao diện Trang chủ rực rỡ với lời chào cá nhân hóa, chuỗi ngày đọc (Streak), thanh thời gian sử dụng trong ngày được đồng bộ từ hồ sơ của bé, thanh cuộn sách gợi ý theo độ tuổi.
  - [LibraryScreen](file:///d:/SkectTable/lib/screens/library_screen.dart): Thư viện truyện phong phú, bộ lọc theo nhóm tuổi (Mầm non, Tiểu học...) và chủ đề giáo dục (Thiên nhiên, Lòng tốt, Trí tò mò, Sáng tạo).
  - [DrawingScreen](file:///d:/SkectTable/lib/screens/drawing_screen.dart): Bảng vẽ cảm ứng mượt mà dành cho bé với cọ vẽ đa kích thước, bảng màu tươi vui, tính năng hoàn tác (Undo) và xóa bảng.
  - [MagicTransformScreen](file:///d:/SkectTable/lib/screens/magic_transform_screen.dart): Hiệu ứng ánh sáng huyền ảo biến bản vẽ của bé thành nhân vật sống động.
  - [RoleAssignmentScreen](file:///d:/SkectTable/lib/screens/role_assignment_screen.dart): Cho phép bé lựa chọn gán nhân vật vừa vẽ vào vai Nhân vật chính (Hero) hoặc Bạn đồng hành (Companion).
  - [StoryPlayerScreen](file:///d:/SkectTable/lib/screens/story_player_screen.dart): Trình đọc truyện tương tác đa chế độ (Đọc truyện, Từ vựng, Đố vui), đọc song ngữ Anh - Việt, hoạt họa chuyển trang và dàn trang nhân vật theo thời gian thực.
  - [ChildProfileScreen](file:///d:/SkectTable/lib/screens/child_profile_screen.dart): Quản lý hồ sơ bé, hiển thị số sao tích lũy, huy hiệu khen thưởng và danh sách truyện yêu thích.
  - [CollectionScreen](file:///d:/SkectTable/lib/screens/collection_screen.dart): Bộ sưu tập các tác phẩm vẽ và các nhân vật 3D bé đã sáng tạo.

---

### 2. Hệ thống Hoạt họa Nhân vật Tương tác (Squash & Stretch Physics)
- **Mã nguồn:** [squash_stretch_character.dart](file:///d:/SkectTable/lib/widgets/squash_stretch_character.dart)
- **Tính năng nổi bật:**
  - **6 Chiêu thức / Hành động phức tạp (`CharacterAction`):**
    1. `idle`: Nhún thở nhẹ nhàng kết hợp bóng chuyển động dưới chân.
    2. `patrol`: Đi tuần tra qua lại màn hình kết hợp lật xoay cơ thể 3D.
    3. `dance`: Nhảy Disco xoay 360° quanh trục Y cùng các nốt nhạc bay.
    4. `fly`: Bay lượn bồng bềnh hình sin trên không trung với hạt phát sáng.
    5. `stomp`: Nhún lấy đà, phóng vút lên cao rồi tiếp đất tạo địa chấn rung rinh màn hình.
    6. `sleep`: Nằm ngủ ngáy êm đềm cùng bong bóng thoại Zzz 💤.
  - **Tương tác trực tiếp:**
    - `onTap`: Nhảy tưng và hiển thị câu thoại động viên bé.
    - `onDoubleTap`: Tự động chuyển và biểu diễn ngay hành động kế tiếp.
    - `Drag & Drop`: Bé có thể chạm kéo nhân vật dạo chơi khắp khung cảnh truyện.
  - **Nút bật/tắt (Toggle) và Bảng điều khiển Studio:** Cho phép người đọc linh hoạt trải nghiệm hoặc ẩn bớt bảng điều khiển hoạt họa tùy ý.

---

### 3. Tích hợp Hệ thống Backend REST API (Swagger Documentation)
- **Mã nguồn dịch vụ:** Thư mục [lib/services/](file:///d:/SkectTable/lib/services) & [app_config.dart](file:///d:/SkectTable/lib/utils/app_config.dart)
- **Chi tiết các endpoint đã tích hợp:**
  - **AuthController v2.2:** Quản lý 14 API xác thực, lưu token an toàn, hỗ trợ Blacklist Token khi đăng xuất và Refresh Token Rotation tự động.
  - **ChildProfileService (`/api/child-profiles`):** Tải thông tin bé, nhóm tuổi `targetAgeGroup`, thời gian giới hạn đọc trong ngày.
  - **StoryService (`/api/story-template` & `/api/education-themes`):** Lấy danh mục truyện mẫu, tự động sắp xếp theo nhóm tuổi và đề tài.
  - **Character Slot Template (`/api/story-pages/{pageId}/slots`):** Tự động dàn trang tọa độ và tỷ lệ kích thước của nhân vật bé vẽ trong từng trang sách.
  - **VocabularyTemplate (`/api/story-pages/{pageId}/vocabularies`):** Thẻ từ vựng flashcard tương tác có phát âm giọng đọc chuẩn.
  - **StoryQuizTemplate (`/api/story-template/{id}/quizzes`):** Câu hỏi trắc nghiệm tương tác giúp bé ghi nhớ cốt truyện và nhận thưởng sao vàng.

---

### 4. Tối ưu Đa kích thước & Bộ Kiểm thử Tự động (Tests)
- **Hỗ trợ Responsive:**
  - Xử lý linh hoạt kích thước viewport qua [responsive.dart](file:///d:/SkectTable/lib/utils/responsive.dart), hỗ trợ mượt mà từ điện thoại màn hình nhỏ đến máy tính bảng / iPad.
- **Bộ Kiểm thử Đạt 100% (34/34 Tests Passed across 8 Test Suites):**
  - [auth_test.dart](file:///d:/SkectTable/test/auth_test.dart): Kiểm thử mô hình xác thực, token rotation, JWT blacklist.
  - [child_profile_test.dart](file:///d:/SkectTable/test/child_profile_test.dart): Kiểm thử phân loại nhóm tuổi, thời gian sử dụng và giới hạn tạo nhân vật.
  - [story_slot_test.dart](file:///d:/SkectTable/test/story_slot_test.dart): Kiểm thử serializer tọa độ nhân vật (CharacterSlotTemplate).
  - [vocabulary_test.dart](file:///d:/SkectTable/test/vocabulary_test.dart): Kiểm thử thẻ từ vựng và giải thích nghĩa.
  - [quiz_test.dart](file:///d:/SkectTable/test/quiz_test.dart): Kiểm thử trắc nghiệm đố vui và cộng sao.
  - [story_template_test.dart](file:///d:/SkectTable/test/story_template_test.dart): Kiểm thử phân vai nhân vật và danh sách truyện.
  - [widget_test.dart](file:///d:/SkectTable/test/widget_test.dart): Kiểm thử khói (Smoke Test) khởi chạy toàn bộ ứng dụng trên Mobile & iPad.
  - [workflow_services_test.dart](file:///d:/SkectTable/test/workflow_services_test.dart): 9 bài kiểm thử tích hợp cho Upload Service, Character Mapping, Char Types, Content Safety Reports, Credit Costs và các luồng nghiệp vụ.

---

### 5. Chuẩn Hóa Cấu Hình Theo Backend .NET 8 & Sơ Đồ Hoạt Động (WORKFLOW.png)
- **Đồng bộ hóa 3 Swimlane Activities từ sơ đồ nghiệp vụ:**
  - **Workflow 1 (Child Login / Profile Access):**
    - Kiểm tra thời gian sử dụng còn lại (`remainingTimeLimit <= 0`).
    - Nếu hết giờ, hiển thị thông báo dịu dàng thân thiện với trẻ em (COPPA), đề nghị bé giải lao hoặc nhờ bố mẹ cấp thêm thời gian.
  - **Workflow 2 (Story Selection & Interactive Reading):**
    - Kiểm duyệt vai diễn nhạy cảm: Nếu vai truyện yêu cầu phụ huynh phê duyệt (`requiresParentApproval == true`), hiển thị hộp thoại xác nhận bảo vệ trẻ em trước khi vào truyện.
    - Gán vai truyện và đồng bộ lên server qua [CharacterMappingService](file:///d:/SkectTable/lib/services/character_mapping_service.dart) (`POST /api/user-story-character-mappings`).
    - Tích hợp nút bảo vệ 1-chạm (Shield 🛡️) trên thanh đọc truyện, cho phép bé gửi báo cáo an toàn nội dung qua [ContentReportService](file:///d:/SkectTable/lib/services/content_report_service.dart) (`POST /api/content-reports`).
  - **Workflow 3 (Character Creation & Approval Flow):**
    - Kiểm tra số lượt tạo nhân vật trong ngày (`remainingCharacterLimit <= 0`).
    - Chụp byte mảng vẽ từ canvas và upload trực tiếp lên Cloudinary qua [UploadService](file:///d:/SkectTable/lib/services/upload_service.dart) (`POST /api/upload/avatar`).
    - Tích hợp cơ chế Fallback nhận diện AI bằng giọng nói/văn bản và phân loại theo danh mục [CharTypeService](file:///d:/SkectTable/lib/services/char_type_service.dart) (`GET /api/char-types`).
    - Khấu trừ 1 lượt tạo khi biến hình; nếu bé chọn "Sửa Tiếp / Thử Lại", tự động hoàn trả 1 lượt tạo (`restoreCharacterCreationAttempt()`).
    - Lưu nhân vật ở trạng thái `Pending` (chờ phụ huynh duyệt) theo đúng nghiệp vụ RBAC.

---

## 📌 3. HƯỚNG DẪN CẬP NHẬT NHANH VÀO GOOGLE SHEET

Để cập nhật các dòng mới vào Google Sheet **FE Task** (từ dòng số 7 trở đi):

1. Mở trang tính **FE Task**.
2. Thêm các dòng mới với thông tin tương ứng ở mục **1. Bảng Tổng Hợp Nhiệm Vụ** phía trên:
   - **Task:** Tên tính năng cụ thể.
   - **Person In Charge:** Chọn `T.Duy`.
   - **Start Date & Deadline:** Nhập theo các mốc thời gian tương ứng.
   - **Status:** Chọn `Completed`.
   - **Detail:** Tóm tắt ngắn gọn tính năng hoặc đường dẫn liên quan.
