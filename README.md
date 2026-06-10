# Ha Floating Demo — File Manager iOS

Ứng dụng **File Manager** cho iOS viết bằng Flutter, giao diện tối màu kiểu Filza.

## Tính năng

- 📂 Duyệt thư mục theo đường dẫn tùy chỉnh
- ✏️ Nhập đường dẫn thủ công (`/var/mobile/Documents`, `/tmp`, v.v.)
- ⬆️ Tiêm file từ thiết bị vào bất kỳ thư mục nào
- 📁 Tạo / Xóa / Đổi tên file và thư mục
- 🔖 Quick Access các đường dẫn phổ biến
- 🔍 Tìm kiếm file trong thư mục

## Build

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release --no-codesign
```

IPA file tự động build qua **GitHub Actions** → xem tab `Releases`.
