# Issue #24 — S6 Settings & Profile (Frontend Prototype) — hle85

> Scope: **prototype/mock**. Không smoke test theo từng issue; chỉ build/run sau khi gom xong toàn bộ prototype.

## 1) Snapshot hiện trạng (trên `develop`)

- `SettingsScreen` đã có layout cơ bản + một số item (tuỳ theo code hiện tại).
- Chưa có state/settings model thống nhất; đa số là UI mock.
- Logout flow ở app hiện đang ở scope auth mock (S1).

## 2) Checklist 6.1 – 6.14 (đối chiếu Issue #24)

Quy ước: `TODO` | `PARTIAL` | `DONE`

| ID   | Hạng mục                                  | Priority | Status  |
| ---: | ----------------------------------------- | :------: | ------- |
|  6.1 | Settings screen layout (sections)         |    P0    | DONE    |
|  6.2 | Profile summary section                   |    P0    | DONE    |
|  6.3 | Edit profile flow                         |    P0    | DONE    |
|  6.4 | Change password flow                      |    P0    | DONE    |
|  6.5 | Notification preferences section          |    P0    | DONE    |
|  6.6 | Quiet hours / DND                         |    P1    | DONE    |
|  6.7 | Test notification action                  |    P1    | DONE    |
|  6.8 | Subscription info section                 |    P1    | DONE    |
|  6.9 | Manage subscription CTA                   |    P2    | DONE    |
| 6.10 | Language & region settings                |    P2    | DONE    |
| 6.11 | About & support section                   |    P1    | DONE    |
| 6.12 | Logout flow                               |    P0    | DONE    |
| 6.13 | Delete account request                    |    P2    | DONE    |
| 6.14 | Mascot hints in settings                  |    P2    | DONE    |

## 3) Thứ tự triển khai (cuốn chiếu)

- P0: 6.1 → 6.2 → 6.3 → 6.4 → 6.5 → 6.12
- P1: 6.6 → 6.7 → 6.8 → 6.11
- P2: 6.9 → 6.10 → 6.13 → 6.14

## 4) Notes “gọn + prototype”

- Không dùng push notification thật; “Gửi thử” chỉ SnackBar.
- Subscription/payment chỉ mở placeholder (SnackBar).
- Logout: clear state mock + điều hướng về `WelcomeScreen`.
