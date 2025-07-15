# Chức Năng Báo Cáo Vấn Đề (Issue Report)

## Tổng Quan
Ứng dụng đã được mở rộng với chức năng báo cáo vấn đề mới, cho phép người dùng báo cáo các vấn đề phát sinh tại công trường. Chức năng này hoạt động tương tự như hệ thống checkin hiện có nhưng được thiết kế riêng cho việc báo cáo và theo dõi các vấn đề.

## Cấu Trúc Code Mới

### 1. Issue Report Module
```
lib/modules/issue_report/
├── issue_report.dart              # Export file
├── issue_report_binding.dart      # Dependency injection
├── issue_report_controller.dart   # Business logic
├── issue_report_screen.dart       # Màn hình báo cáo
└── issue_history_screen.dart      # Màn hình lịch sử
```

### 2. Routes Mới
- `/issue-report` - Màn hình tạo báo cáo vấn đề mới
- `/issue-history` - Màn hình xem lịch sử báo cáo

### 3. Storage Service
Đã mở rộng `StorageService` để lưu trữ báo cáo vấn đề local:
- `issueReportsJson` - Lưu trữ danh sách báo cáo dưới dạng JSON

## Các Tính Năng Chính

### 1. Báo Cáo Vấn Đề
- **Loại vấn đề**: Safety, Equipment, Quality, Environment, Other
- **Mức độ ưu tiên**: Low, Medium, High, Critical  
- **Mô tả chi tiết**: Text field để mô tả vấn đề
- **Chụp ảnh**: Tích hợp camera với watermark (location, GPS, timestamp)
- **Thông tin vị trí**: GPS coordinates và địa chỉ tự động
- **Lưu trữ**: Tự động save ảnh vào gallery và lưu data local

### 2. Lịch Sử Báo Cáo
- **Thống kê**: Tổng số báo cáo, pending, in progress, resolved
- **Danh sách**: Hiển thị tất cả báo cáo với thông tin đầy đủ
- **Chi tiết**: Xem ảnh full screen, thông tin location, timestamp
- **Quản lý**: Cập nhật trạng thái, xóa báo cáo

### 3. Tích Hợp Với Checkin
- Button "Report Issue" trong Checkin screen
- Button "Report Issue" trong Home screen với design đặc biệt (màu đỏ)

## Flow Hoạt Động

### Tạo Báo Cáo Mới:
1. Chọn loại vấn đề (Safety/Equipment/Quality/Environment/Other)
2. Chọn mức độ ưu tiên (Low/Medium/High/Critical)
3. Nhập mô tả vấn đề chi tiết
4. Hệ thống tự động lấy location hiện tại
5. Chụp ảnh với camera (có watermark location + GPS + timestamp)
6. Save ảnh vào gallery và lưu data local
7. Hiển thị thông báo thành công

### Xem Lịch Sử:
1. Màn hình thống kê tổng quan
2. Danh sách báo cáo theo thời gian (mới nhất trước)
3. Tap vào báo cáo để xem chi tiết
4. Có thể cập nhật trạng thái hoặc xóa báo cáo

## Data Structure

### Issue Report Object:
```json
{
  "id": "unique_timestamp_id",
  "type": "issue_report",
  "issueType": "safety|equipment|quality|environment|other",
  "priority": "low|medium|high|critical",
  "description": "Chi tiết mô tả vấn đề",
  "latitude": 10.762622,
  "longitude": 106.660172,
  "address": "Địa chỉ từ GPS",
  "imageBase64": "base64_encoded_image",
  "timestamp": "2025-01-15T10:30:00.000Z",
  "status": "pending|in_progress|resolved",
  "lastUpdated": "2025-01-15T10:30:00.000Z"
}
```

## UI/UX Design

### Issue Report Screen:
- **Location Card**: Hiển thị vị trí hiện tại với icon và loading state
- **Issue Type**: Horizontal chips với các loại vấn đề
- **Priority**: Horizontal chips với màu sắc phân biệt mức độ
- **Description**: Multi-line text field
- **Submit Button**: Màu đỏ với icon camera
- **Recent Reports**: Preview 3 báo cáo gần nhất

### Issue History Screen:  
- **Statistics Card**: 4 metrics trong 1 row (Total/Pending/In Progress/Resolved)
- **Report Cards**: Material design cards với priority indicator
- **Action Buttons**: View Photo, Update Status, Delete
- **Empty State**: Friendly message khi chưa có báo cáo

## Color Coding

### Priority Colors:
- **Low**: Green
- **Medium**: Orange  
- **High**: Red
- **Critical**: Dark Red

### Status Colors:
- **Pending**: Orange
- **In Progress**: Blue
- **Resolved**: Green

## Tích Hợp Với Hệ Thống Hiện Có

### Services Sử Dụng:
- `CameraService`: Chụp ảnh với watermark
- `LocationService`: Lấy GPS và địa chỉ
- `StorageService`: Lưu trữ báo cáo local

### Navigation:
- Từ Home screen: Button "Report Issue" màu đỏ
- Từ Checkin screen: Button "Report Issue" 
- Từ Issue Report: Button history để xem lịch sử
- Từ Issue History: Button + để tạo báo cáo mới

## Extensibility

Hệ thống được thiết kế để dễ dàng mở rộng:

1. **Thêm loại vấn đề mới**: Chỉ cần thêm vào enum `IssueType`
2. **Thêm trạng thái mới**: Cập nhật logic trong controller
3. **Integration API**: Controller đã sẵn sàng để tích hợp với backend
4. **Notifications**: Có thể thêm push notifications cho status updates
5. **File attachments**: Có thể mở rộng để đính kèm nhiều files
6. **Comments**: Có thể thêm hệ thống comment cho từng báo cáo

## Testing

Để test chức năng:

1. **Tạo báo cáo**: 
   - Vào Home → "Report Issue" hoặc Checkin → "Report Issue"
   - Chọn type, priority, nhập description  
   - Chụp ảnh và kiểm tra watermark
   - Verify ảnh được save vào gallery

2. **Xem lịch sử**:
   - Vào Issue History từ Report screen
   - Kiểm tra statistics
   - Test view photo, update status, delete

3. **Data persistence**:
   - Tạo báo cáo, kill app, mở lại → data vẫn còn
   - Test với nhiều báo cáo khác nhau

## Performance Considerations

- **Image storage**: Sử dụng base64 encoding cho simplicity, có thể optimize bằng file paths
- **Local storage**: JSON serialization, có thể migrate sang SQLite cho large datasets  
- **Memory**: Lazy loading cho danh sách báo cáo lớn
- **Camera**: Proper disposal của camera controller
