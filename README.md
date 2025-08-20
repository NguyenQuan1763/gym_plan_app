# 🏋️‍♂️ Gym Plan App
Ứng dụng lập kế hoạch tập gym toàn diện được xây dựng với Flutter, giúp người dùng quản lý workout, meal plan và theo dõi tiến độ tập luyện một cách hiệu quả.

## 🌟 Tổng quan dự án
Đây là một ứng dụng mobile hoàn chỉnh dành cho việc lập kế hoạch và theo dõi quá trình tập luyện gym, bao gồm quản lý workout, meal plan, và các tính năng hỗ trợ người dùng đạt được mục tiêu fitness của mình.

## ✨ Tính năng chính

### 👤 Dành cho người dùng
- 🔐 Đăng ký, đăng nhập và quản lý tài khoản cá nhân
- 🏋️‍♂️ Tạo và quản lý workout plan chi tiết
- 🍽️ Lập kế hoạch bữa ăn (meal plan) theo mục tiêu
- 📊 Theo dõi tiến độ tập luyện và thống kê
- 📱 Giao diện thân thiện với bottom navigation
- 🎯 Quản lý mục tiêu fitness cá nhân
- 📸 Tích hợp camera để chụp ảnh progress
- ⚙️ Tùy chỉnh cài đặt ứng dụng

### 🛠️ Tính năng kỹ thuật
- 💾 Lưu trữ dữ liệu local với SQLite
- 🔄 Quản lý state với Provider/Bloc
- 🎨 UI/UX hiện đại với Material Design
- 📱 Hỗ trợ đa nền tảng (iOS, Android)
- 🔒 Bảo mật dữ liệu người dùng
- 📊 Thống kê và báo cáo chi tiết

## 🏗️ Kiến trúc hệ thống

```
gym_plan_app/
├── lib/                    # Source code chính
│   ├── main.dart          # Entry point
│   ├── onboard/           # Màn hình onboarding
│   ├── auth/              # Xác thực người dùng
│   ├── menu_bottom_nav/   # Navigation và screens chính
│   ├── model/             # Data models
│   ├── DatabaseHelper/    # Database operations
│   ├── add_screen/        # Màn hình thêm dữ liệu
│   └── Item/              # Components và widgets
├── assets/                # Tài nguyên (images, fonts)
├── android/               # Android configuration
├── ios/                   # iOS configuration
├── test/                  # Unit tests
└── pubspec.yaml          # Dependencies
```

## 🎨 Frontend (Flutter)

### Framework & Libraries
- **Framework**: Flutter 3.8+
- **Language**: Dart
- **UI Framework**: Material Design
- **State Management**: Provider/Bloc
- **Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences
- **Image Handling**: image_picker
- **Animations**: Lottie
- **Date/Time**: intl
- **PIN Code**: pin_code_fields

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  pin_code_fields: ^8.0.1
  sqflite: ^2.4.2
  path: ^1.9.1
  intl: ^0.20.2
  lottie: ^3.3.1
  shared_preferences: ^2.3.2
  image_picker: ^1.1.2
```

## 📱 Cấu trúc màn hình

### Onboarding & Authentication
- **Splash Screen**: Màn hình khởi động
- **Welcome Screen**: Chào mừng người dùng
- **Login Screen**: Đăng nhập
- **Register Screen**: Đăng ký tài khoản

### Main Features
- **Home Screen**: Dashboard chính
- **Workout Page**: Quản lý workout plans
- **Meal Page**: Quản lý meal plans
- **Settings Page**: Cài đặt ứng dụng

### Detail Pages
- **Workout Detail**: Chi tiết workout
- **Workout Edit**: Chỉnh sửa workout
- **Meal Detail**: Chi tiết meal plan
- **Meal Edit**: Chỉnh sửa meal plan

## 📋 Yêu cầu hệ thống

### Development
- Flutter SDK >= 3.8.1
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

### Runtime
- Android: API level 21+ (Android 5.0+)
- iOS: iOS 11.0+
- RAM: 2GB+
- Storage: 100MB+

## 🚀 Cài đặt và chạy

### 1. Tải về dự án
```bash
# Nếu đã có repository trên GitHub
git clone https://github.com/NguyenQuan1763/gym_plan_app.git
cd gym_plan_app

# Hoặc tải về file ZIP và giải nén
# Sau đó cd vào thư mục dự án
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Chạy ứng dụng
```bash
# Chạy trên device/emulator hiện tại
flutter run

# Chạy trên Android
flutter run -d android

# Chạy trên iOS
flutter run -d ios
```

### 4. Build ứng dụng
```bash
# Build APK cho Android
flutter build apk

# Build App Bundle cho Android
flutter build appbundle

# Build cho iOS
flutter build ios
```

## 🧪 Testing

```bash
# Chạy unit tests
flutter test

# Chạy integration tests
flutter test integration_test/
```

## 📦 Database Schema

### Users Table
- id (Primary Key)
- username
- email
- password_hash
- created_at
- updated_at

### Workouts Table
- id (Primary Key)
- user_id (Foreign Key)
- name
- description
- exercises
- duration
- created_at
- updated_at

### Meals Table
- id (Primary Key)
- user_id (Foreign Key)
- name
- description
- ingredients
- calories
- meal_type
- created_at
- updated_at

## 🔧 Cấu hình


### Android Configuration
- Minimum SDK: 21
- Target SDK: 33
- Permissions: Camera, Storage, Internet

### iOS Configuration
- Minimum iOS Version: 11.0
- Permissions: Camera, Photo Library

## 👥 Tác giả

- **Nguyễn Minh Quân** - *Initial work* - [NguyenQuan1763](https://github.com/NguyenQuan1763).

## 🙏 Acknowledgments

- Flutter team cho framework tuyệt vời
- Cộng đồng Flutter/Dart
- Tất cả contributors đã đóng góp vào dự án


⭐ Nếu dự án này hữu ích, hãy cho chúng tôi một star khi repository được upload lên GitHub!
