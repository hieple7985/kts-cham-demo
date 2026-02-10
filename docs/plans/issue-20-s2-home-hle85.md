# Issue #20 — S2 Home (Frontend Prototype) — hle85

> Scope dừng ở mức **prototype/mock** (không phụ thuộc backend). Mục tiêu: “gọn + chạy được”, ưu tiên web (`-d chrome`) để tránh phụ thuộc Xcode/macOS build.

## 1) Snapshot hiện trạng (trên `develop`)

- Home screen đã có sẵn tại `3_dev/mobile_app/lib/features/home/presentation/screens/home_screen.dart` (UI mock).
- Widgetbook đã include `HomeScreen` trong `3_dev/mobile_app/lib/widgetbook/widgetbook_app.dart`.
- Bottom navigation hiện dùng `Navigator.push` (chưa phải tab shell giữ state).

## 2) Checklist 2.1 – 2.13 (đối chiếu Issue #20)

Quy ước: `TODO` | `PARTIAL` | `DONE`

| ID   | Hạng mục                                                | Priority | Status  | Ước lượng còn lại |
| ---: | ------------------------------------------------------- | :------: | ------- | ----------------: |
|  2.1 | Home Screen Layout (header/scroll/bottom nav)            |    P0    | DONE    |                0h |
|  2.2 | Today Reminders Section                                  |    P0    | DONE    |                0h |
|  2.3 | AI Insight Card (tap mở detail/AI chat)                  |    P0    | DONE    |                0h |
|  2.4 | Quick Action Buttons                                     |    P1    | DONE    |                0h |
|  2.5 | Reminder Item Component (tách widget + actions đủ)        |    P0    | DONE    |                0h |
|  2.6 | Mark Reminder Done/Snooze                                |    P1    | DONE    |                0h |
|  2.7 | Empty Reminders State (CUCA relax)                       |    P1    | DONE    |                0h |
|  2.8 | Pull-to-Refresh                                          |    P1    | DONE    |                0h |
|  2.9 | Notification Badge on Home                               |    P2    | DONE    |                0h |
| 2.10 | Skeleton Loading                                         |    P1    | DONE    |                0h |
| 2.11 | Navigate to Customer Detail (S4)                          |    P0    | DONE    |                0h |
| 2.12 | CUCA Header Mascot Animation                              |    P2    | DONE    |                0h |
| 2.13 | First-time Home State (No Customers)                      |    P1    | DONE    |                0h |

### Tiến độ thực tế so với checklist

- P0: `DONE` 5/5 (2.1/2.2/2.3/2.5/2.11).
- P1: `DONE` 6/6 (2.4/2.6/2.7/2.8/2.10/2.13).
- P2: `DONE` 2/2 (2.9/2.12).

## 3) Workload tổng (còn lại)

- Còn lại ước lượng: 0h (Issue #20 prototype scope hoàn tất).

## 4) Notes “gọn + prototype”

- Không tạo backend calls; mọi data ở Home dùng mock list/fixtures.
- UI component nên “pure” (nhận callback), tránh tự push route ở tầng widget nhỏ.
- Widgetbook ưu tiên offline-safe (không `NetworkImage`).

## 5) Changelog

- 2026-01-05: Tạo plan (hle85) dựa trên source hiện có và scope prototype.
- 2026-01-05: DONE 2.3/2.6, PARTIAL 2.7, DONE 2.9 (App shell + widgetbook).
- 2026-01-05: Đối chiếu lại theo mô tả Issue #20 (2.1–2.13) và cập nhật estimate.
- 2026-01-05: DONE 2.1–2.13 theo chuẩn prototype/mock (reminders + actions + badge + skeleton + routing).
