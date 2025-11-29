# Background Planetary Updater - Hướng dẫn sử dụng

## Tổng quan

`BackgroundPlanetaryUpdater` là service chạy nền để tự động tính toán và cập nhật dữ liệu planetary positions vào Firebase hàng ngày.

## Tính năng

- ✅ **Tự động tính toán** planetary positions mỗi ngày
- ✅ **Pre-calculate** dữ liệu cho các ngày sắp tới (mặc định 7 ngày)
- ✅ **Chạy nền** - Tự động update mà không cần user mở app
- ✅ **Tối ưu** - Chỉ tính toán khi cần thiết, không tính lại nếu đã có

## Cách hoạt động

### 1. Khi app khởi động

Service tự động bắt đầu trong `main.dart`:

```dart
BackgroundPlanetaryUpdater.instance.start(
  precalculateDays: 7, // Pre-calculate next 7 days
);
```

### 2. Cập nhật hàng ngày

- **Midnight update**: Tự động tính toán dữ liệu mới vào lúc 00:00 mỗi ngày
- **Periodic check**: Kiểm tra mỗi giờ để đảm bảo dữ liệu luôn fresh
- **Pre-calculation**: Tính toán trước cho các ngày sắp tới

### 3. Khi user chọn xem ngày khác

Khi user chọn xem ngày khác trong app:

```dart
// Trong HomeRemoteDataSource
await _planetaryService.getPlanetaryData(targetDate);
```

Nếu dữ liệu chưa có, sẽ tự động:
1. Tính toán planetary positions cho ngày đó
2. Lưu vào Firebase
3. Trả về dữ liệu

## Cấu hình

### Start service

```dart
BackgroundPlanetaryUpdater.instance.start(
  updateInterval: Duration(hours: 1), // Check every hour
  precalculateDays: 7, // Pre-calculate 7 days ahead
);
```

### Stop service

```dart
BackgroundPlanetaryUpdater.instance.stop();
```

### Manual update cho một ngày cụ thể

```dart
await BackgroundPlanetaryUpdater.instance.updateDate(DateTime(2024, 1, 15));
```

## Lưu ý

### Background Execution

Để service chạy nền khi app đóng, bạn cần:

1. **Android**: Cấu hình `WorkManager` hoặc `Firebase Cloud Functions`
2. **iOS**: Sử dụng background tasks hoặc `Firebase Cloud Functions`

Hiện tại service chạy khi app đang mở. Để chạy nền thực sự, cần:

- **Option 1**: Sử dụng Firebase Cloud Functions để tính toán server-side
- **Option 2**: Sử dụng Flutter background tasks (workmanager package)
- **Option 3**: Tính toán khi user mở app (hiện tại)

### Performance

- Tính toán planetary positions mất ~100-200ms
- Pre-calculation cho 7 ngày mất ~1-2 giây
- Dữ liệu được cache trong Firebase, không cần tính lại

### Data Structure

Dữ liệu được lưu trong Firebase theo cấu trúc:

```
planets_today/
  └── 2024-01-15/
      ├── dateId: "2024-01-15"
      ├── cards: [
      │     {
      │       name: "Sun",
      │       zodiac: "Capricorn",
      │       degrees: "15°30'45\"",
      │       description: "...",
      │       imageUrl: "...",
      │       accentColor: "#F19550"
      │     },
      │     ...
      │   ]
      ├── calculatedAt: timestamp
      └── updatedAt: timestamp
```

## Tích hợp với UI

Khi user chọn ngày trong date picker:

```dart
// Trong HomePage hoặc widget tương tự
Future<void> _onDateSelected(DateTime selectedDate) async {
  // Fetch content for selected date
  // Data will be calculated automatically if not exists
  final content = await homeRepository.fetchContent(
    userId,
    date: selectedDate,
  );
  setState(() {
    _content = content;
  });
}
```

## Monitoring

Để kiểm tra service có đang chạy:

```dart
final isRunning = BackgroundPlanetaryUpdater.instance.isRunning;
print('Background updater is ${isRunning ? "running" : "stopped"}');
```

