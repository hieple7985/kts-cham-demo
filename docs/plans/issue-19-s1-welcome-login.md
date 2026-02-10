# Issue #19 — S1 Welcome & Login (Frontend Prototype)

## 1) Mục tiêu

- Hoàn thiện luồng **Welcome & Auth + Onboarding cơ bản** theo danh sách 1.1–1.17.
- Phạm vi: **Frontend / prototype / mock logic**, chưa tích hợp backend.

## 2) Phạm vi (Scope)

- UI + validate + loading + error handling (thân thiện).
- Routing theo rule prototype:
  - Login/Signup thành công:
    - **First-time** → Onboarding (1.10 → 1.17)
    - **Returning** → Home (S2)
- Mascot CUCA: hỗ trợ các pose tối thiểu: ready / wave / alert / thumbs up (celebrate).

## 3) Ngoài phạm vi (Non-scope)

- Tích hợp backend (Supabase/Firebase/Auth server).
- Permission contacts thật + đọc contacts thật (có thể mock UI/logic).
- Notification permission thật (có thể mock UI/logic).

## 4) Definition of Done (DoD)

- App build/run được từ entry point chính.
- Flow P0 chạy end-to-end:
  - 1.1 Welcome
  - 1.2 Phone Login (SĐT → OTP)
  - 1.3 Email Login
  - 1.4 Phone Signup (SĐT → OTP → tạo mật khẩu optional)
  - 1.9 Auth success routing (first-time vs returning)
- P1/P2: có thể hoàn thiện sau nhưng có plan rõ ràng.

## 5) Hiện trạng nhanh (Snapshot)

> Cập nhật: điền % sau mỗi lần merge/commit.

- Source of truth hiện tại:
  - [ ] `features/` là luồng chạy trong `main.dart`
  - [ ] `prototype/` chỉ để tham khảo/port UI

### Rủi ro kỹ thuật cần xử lý trước

- [ ] Mismatch constructor/params giữa các màn (vd: OTP screen nhận `phoneNumber` nhưng nơi gọi truyền `phone`).
- [ ] Routing chưa thống nhất (login/signup mỗi nơi navigate khác).

## 6) Checklist theo yêu cầu (1.1 – 1.17)

> Quy ước trạng thái: `TODO` | `IN PROGRESS` | `DONE` | `BLOCKED`

| ID   | Hạng mục                          | Priority | Status | %   | Ghi chú |
| ---: | --------------------------------- | :------: | ------ | --: | ------ |
|  1.1 | Welcome Screen with Mascot         |    P0    | TODO   |   0 |        |
|  1.2 | Phone Login Flow                   |    P0    | TODO   |   0 |        |
|  1.3 | Email/Password Login Flow          |    P0    | TODO   |   0 |        |
|  1.4 | Phone Signup Flow                  |    P0    | TODO   |   0 |        |
|  1.5 | Email Signup Flow                  |    P1    | TODO   |   0 |        |
|  1.6 | Forgot Password (Phone OTP)        |    P1    | TODO   |   0 |        |
|  1.7 | Forgot Password (Email)            |    P1    | TODO   |   0 |        |
|  1.8 | Auth Error States & Mascot Feedback|    P1    | TODO   |   0 |        |
|  1.9 | Auth Success & Routing             |    P0    | TODO   |   0 |        |
| 1.10 | Onboarding Welcome Screen          |    P1    | TODO   |   0 |        |
| 1.11 | Onboarding Import Contacts Screen  |    P1    | TODO   |   0 |        |
| 1.12 | Request Contacts Permission        |    P1    | TODO   |   0 |        |
| 1.13 | Phone Contacts List Selection      |    P1    | TODO   |   0 |        |
| 1.14 | Import Selected Contacts           |    P1    | TODO   |   0 |        |
| 1.15 | Skip Import Flow + Home hint        |    P2    | TODO   |   0 |        |
| 1.16 | Onboarding Notification Permission |    P1    | TODO   |   0 |        |
| 1.17 | Onboarding Complete                |    P1    | TODO   |   0 |        |

## 7) Milestones (thứ tự triển khai đề xuất)

### Milestone A — Stabilize & Single Flow (P0 base, làm trước)

- [ ] Chốt 1 luồng chạy chính (khuyến nghị: `features/` vì `main.dart` đang dùng).
- [ ] Fix mismatch constructor/params giữa screens (đảm bảo build/run không crash).
- [ ] Chuẩn hoá navigation skeleton: Welcome → Login/Signup → OTP/Create Password.
- [ ] Định nghĩa rule “first-time vs returning” (mock flag persisted) để dùng cho 1.9.

### Milestone B — Complete Auth P0

- [ ] 1.1 Welcome (mascot pose ready, 2 CTA).
- [ ] 1.2 Phone login (send OTP mock, OTP verify mock, error + loading).
- [ ] 1.3 Email login + entry forgot password.
- [ ] 1.4 Phone signup (OTP → create password optional → onboarding).
- [ ] 1.9 Routing first-time vs returning (mock flag persisted).

### Milestone C — Onboarding P1 mock

- [ ] 1.10 Onboarding welcome.
- [ ] 1.11 Import contacts screen (mock import/skip).
- [ ] 1.16 Notification permission (mock allow/later).
- [ ] 1.17 Complete onboarding.

### Milestone D — P1/P2 optional

- [ ] 1.5 Email signup flow polish.
- [ ] 1.6/1.7 Forgot password flow tách màn rõ ràng.
- [ ] 1.12–1.14 UI contacts selection (mock data).
- [ ] 1.15 Home hint/tooltip cho FAB.

## 8) Test scenarios (manual) — kịch bản test cùng nhau

### A. Smoke & Navigation

- [ ] Launch app → Welcome hiển thị OK.
- [ ] Welcome → Login / Signup navigation OK.

### B. Phone Login (1.2)

- [ ] Validate phone invalid.
- [ ] Phone valid → send OTP (loading) → OTP screen.
- [ ] OTP sai → hiện lỗi rõ + mascot alert (nếu áp dụng).
- [ ] OTP đúng (`123456`) → success routing.

### C. Email Login (1.3)

- [ ] Validate email format.
- [ ] Sai password (mock) → lỗi.
- [ ] Quên mật khẩu → vào flow 1.7.

### D. Phone Signup (1.4)

- [ ] Phone valid → OTP → đúng → create password (optional) → onboarding.
- [ ] Password mismatch → validate.

### E. Onboarding (1.10–1.17)

- [ ] Onboarding welcome → continue.
- [ ] Import contacts: Import (mock success) / Skip.
- [ ] Notification permission: allow/later.
- [ ] Complete → Start → Home.

## 9) Thời gian ước tính (solo)

- Tối thiểu: 6–10 giờ (fix wiring + routing + polish cơ bản).
- Thực tế: 12–24 giờ (1.5–3 ngày) để ổn định và ít bug.

---

## 10) Changelog
- 2025-12-28: Created initial plan template.
