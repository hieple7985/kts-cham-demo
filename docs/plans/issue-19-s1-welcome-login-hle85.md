# Issue #19 — S1 Welcome & Login (Frontend Prototype) — hle85

> Fork từ plan `dat09` để theo dõi/triển khai dần theo hướng “gọn + chạy được”.

## 1) Snapshot hiện trạng (trên `develop`)

- Entry point chính: `3_dev/mobile_app/lib/main.dart` đang chạy luồng `features/`.
- UI catalog (Storybook-like): chạy bằng Widgetbook tại `3_dev/mobile_app/lib/widgetbook/`.
- `lib/prototype/` chỉ để tham khảo/port UI và đã được exclude khỏi analyzer để giảm noise.

## 2) Checklist 1.1 – 1.17 (ước lượng theo code hiện có)

Quy ước: `TODO` | `PARTIAL` | `DONE`

| ID   | Hạng mục                          | Priority | Status   | Ước lượng còn lại |
| ---: | --------------------------------- | :------: | -------- | ----------------: |
|  1.1 | Welcome Screen with Mascot         |    P0    | DONE     |                0h |
|  1.2 | Phone Login Flow                   |    P0    | DONE     |                0h |
|  1.3 | Email/Password Login Flow          |    P0    | DONE     |                0h |
|  1.4 | Phone Signup Flow                  |    P0    | DONE     |                0h |
|  1.5 | Email Signup Flow                  |    P1    | DONE     |                0h |
|  1.6 | Forgot Password (Phone OTP)        |    P1    | DONE     |                0h |
|  1.7 | Forgot Password (Email)            |    P1    | DONE     |                0h |
|  1.8 | Auth Error States & Mascot Feedback|    P1    | DONE     |                0h |
|  1.9 | Auth Success & Routing             |    P0    | DONE     |                0h |
| 1.10 | Onboarding Welcome Screen          |    P1    | DONE     |                0h |
| 1.11 | Onboarding Import Contacts Screen  |    P1    | DONE     |                0h |
| 1.12 | Request Contacts Permission        |    P1    | DONE     |                0h |
| 1.13 | Phone Contacts List Selection      |    P1    | DONE     |                0h |
| 1.14 | Import Selected Contacts           |    P1    | DONE     |                0h |
| 1.15 | Skip Import Flow + Home hint        |    P2    | DONE     |                0h |
| 1.16 | Onboarding Notification Permission |    P1    | DONE     |                0h |
| 1.17 | Onboarding Complete                |    P1    | DONE     |                0h |

### Tiến độ thực tế so với checklist

- P0: `DONE` 5/5 (1.1, 1.2, 1.3, 1.4, 1.9).
- P1: `DONE` 8/8 (1.5–1.8, 1.10–1.14, 1.16, 1.17) theo chuẩn prototype/mock.
- P2: còn lại 1.15 (Home hint).
- P2: DONE 1/1 (1.15).

## 3) Ghi chú đánh giá (tập trung “gọn”)

- Chuẩn hoá UI theo Widgetbook: mọi widget/screen quan trọng nên có use-case trong `lib/widgetbook/widgetbook_app.dart`.
- Ưu tiên widget “pure UI” (không tự `Navigator.push`); navigation để ở layer screen/route. (vd: `CustomerCard` đã chuyển sang nhận `onTap`).
- Phone OTP đang “mix”: UI mock (delay) nhưng verify lại gọi Supabase OTP thật. Cần chọn 1 trong 2:
- Scope Issue #19 dừng ở **prototype**, nên auth mặc định chạy **mock** (OTP = `123456`).
  - Bật Supabase auth khi cần: `--dart-define=CUCA_USE_SUPABASE_AUTH=true`.
- Routing “first-time vs returning” (1.9) đã có flag persisted `didOnboard` (Hive) và được set sau onboarding.
- Mascot feedback (1.8): hiện chủ yếu là hình tĩnh; nếu muốn giống prototype thì chuẩn hoá component/pose cho `features/`.

## 4) Workload tổng (còn lại)

- Còn lại: 0h (Issue #19 prototype scope hoàn tất).

## 5) Changelog

- 2026-01-05: Fork plan (hle85) + ước lượng theo code trên `develop`.
- 2026-01-05: DONE 1.9/1.10 (routing + onboarding flow), thêm persisted flag.
- 2026-01-05: DONE 1.2–1.8, 1.12–1.14 theo chuẩn prototype/mock (OTP resend + mascot + contacts selection mock).
- 2026-01-05: DONE 1.15 (Home + DS Khách hint một lần).
