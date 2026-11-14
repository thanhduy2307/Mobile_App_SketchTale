# 🎨 SketchTale - Nền Tảng Đọc Truyện Tương Tác & Sáng Tạo Nghệ Thuật Cho Trẻ Em

> **Mobile Application (Flutter)**  
> Ứng dụng dành riêng cho Trẻ Em (**Role Child**) đọc truyện tương tác, vẽ tranh sáng tạo nhân vật, học từ vựng và tham gia thử thách câu đố nhận thưởng.

---

## 📚 TÀI LIỆU DỰ ÁN CHI TIẾT
- **[BẢNG TIẾN ĐỘ & NHIỆM VỤ FRONTEND (FE TASKS)](file:///d:/SkectTable/TASKS.md)**: Tổng hợp toàn bộ các task FE đã thực hiện bởi **T.Duy (Mobile)** & **H.Nam (Web)**, đồng bộ trực tiếp với Google Sheet "FE Task".
- **[HƯỚNG DẪN TOÀN DIỆN & MÔ TẢ CHI TIẾT TỪNG FILE](file:///d:/SkectTable/PROJECT_GUIDE.md)**: Chi tiết toàn bộ kiến trúc dự án, mô tả chi tiết chức năng của từng file trong thư mục `lib/models`, `lib/services`, `lib/screens`, `lib/state`, `lib/widgets`, `lib/theme`, `lib/utils` và `test/`.
- **[ĐẶC TẢ XÁC THỰC AUTH CONTROLLER v2.2](file:///d:/SkectTable/AUTH_CONTROLLER_README.md)**: Đặc tả 14 API AuthController, JWT Blacklist khi Logout, Refresh Token Rotation.


---

## 🚀 CÁCH KHỞI CHẠY NHANH

### 1. Cài đặt các gói thư viện
```bash
flutter pub get
```

### 2. Kiểm tra mã nguồn (Linter & Static Analysis)
```bash
flutter analyze
```

### 3. Chạy toàn bộ 25 bài kiểm thử tự động
```bash
flutter test
```

### 4. Khởi chạy ứng dụng
```bash
flutter run
```
hoặc trên trình duyệt:
```bash
flutter run -d chrome
```

---

## 🧩 PHÂN QUYỀN VAI TRÒ (ROLE CHILD TRÊN MOBILE)
- **Mobile App:** Chỉ phục vụ trải nghiệm của bé (**Role Child**): Bé vẽ tranh, đọc truyện, xem flashcard từ vựng, làm quiz nhận sao.
- **Web Portal:** Dành riêng cho Phụ huynh và Ban quản trị (quản lý thời gian xem của bé, quản lý đăng ký, biên soạn nội dung truyện).
