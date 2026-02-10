# Issue #22 — S4 Customer Detail (Frontend Prototype) — hle85

> Scope: **prototype/mock** (in-memory, không backend). Không chạy smoke theo từng issue; chỉ build/run sau khi gom xong toàn bộ prototype.

## 1) Snapshot hiện trạng (trên `develop`)

- `CustomerDetailScreen` đã có khung cơ bản + stage control + timeline interactions + add interaction.
- Data nguồn: `customersProvider` (in-memory), model `Customer` đã có `stage`, `notes`, `additionalPhones`, `zaloLink`, `facebookLink`, `interactions`.

## 2) Checklist 4.1 – 4.16 (đối chiếu Issue #22)

Quy ước: `TODO` | `PARTIAL` | `DONE`

| ID   | Hạng mục                                              | Priority | Status  |
| ---: | ----------------------------------------------------- | :------: | ------- |
|  4.1 | Customer Detail Screen Layout                          |    P0    | DONE    |
|  4.2 | Header & Quick Actions                                 |    P0    | DONE    |
|  4.3 | Multiple phones & social links display                 |    P0    | DONE    |
|  4.4 | Journey & stage control (Hot/Warm/Cold/Won/Lost)       |    P0    | DONE    |
|  4.5 | Stage change history + reason                          |    P1    | DONE    |
|  4.6 | Interaction timeline section                            |    P0    | DONE    |
|  4.7 | Add interaction/note flow                               |    P0    | DONE    |
|  4.8 | Interaction types + quick actions (edit/delete/next)   |    P1    | DONE    |
|  4.9 | Paste from clipboard in interaction form               |    P2    | DONE    |
| 4.10 | Transactions section                                    |    P1    | DONE    |
| 4.11 | Add/edit transaction flow                               |    P2    | DONE    |
| 4.12 | AI summary & next action card                           |    P0    | DONE    |
| 4.13 | AI chat component (context customer)                    |    P1    | DONE    |
| 4.14 | AI prompt shortcuts                                     |    P2    | DONE    |
| 4.15 | Empty states per section (mascot + CTA)                 |    P1    | DONE    |
| 4.16 | Loading/error states per section                         |    P1    | DONE    |

## 3) Thứ tự triển khai (cuốn chiếu)

- P0: 4.1 → 4.2 → 4.3 → 4.4 → 4.6 → 4.7 → 4.12
- P1: 4.5 → 4.8 → 4.10 → 4.13 → 4.15 → 4.16
- P2: 4.9 → 4.11 → 4.14

## 4) Notes “gọn + prototype”

- Không dùng `url_launcher`; deep link/call chỉ hiển thị SnackBar (web-safe).
- Lưu state vào in-memory provider (`customersProvider`) để UI cập nhật ngay.
- Widgetbook: giữ use-case `CustomerDetailScreen (id=1)` chạy được.
