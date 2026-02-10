# Issue #21 — S3 Customer List (Frontend Prototype) — hle85

> Scope: **prototype/mock**, ưu tiên chạy web (`-d chrome`). Mục tiêu: danh sách Customer “gọn + dùng được”, đủ search/filter/sort/loading, điều hướng sang S4/S5.

## 1) Snapshot hiện trạng (trên `develop`)

- Screen: `3_dev/mobile_app/lib/features/customers/presentation/screens/customer_list_screen.dart` đã có search + filter cơ bản + list + FAB.
- Provider mock: `3_dev/mobile_app/lib/features/customers/presentation/providers/customers_provider.dart` (in-memory).
- Card: `3_dev/mobile_app/lib/features/customers/presentation/widgets/customer_card.dart` đã dùng trong list và có `onTap`.

## 2) Checklist 3.1 – 3.14 (đối chiếu Issue #21)

Quy ước: `TODO` | `PARTIAL` | `DONE`

| ID   | Hạng mục                                  | Priority | Status  | Ước lượng còn lại |
| ---: | ----------------------------------------- | :------: | ------- | ----------------: |
|  3.1 | Customer List Screen Layout               |    P0    | DONE    |                0h |
|  3.2 | Customer Card Component                   |    P0    | DONE    |                0h |
|  3.3 | Search Customer (debounce + notes)        |    P0    | DONE    |                0h |
|  3.4 | Filter by Stage (+ badge counts)          |    P1    | DONE    |                0h |
|  3.5 | Sort Customer List                        |    P1    | DONE    |                0h |
|  3.6 | Empty State với Mascot (no customers)     |    P1    | DONE    |                0h |
|  3.7 | Empty Search Result (confused)            |    P1    | DONE    |                0h |
|  3.8 | Pull-to-Refresh                           |    P1    | DONE    |                0h |
|  3.9 | Infinite Scroll / Pagination (mock)       |    P1    | DONE    |                0h |
| 3.10 | Skeleton Loading                          |    P1    | DONE    |                0h |
| 3.11 | Navigate to Customer Detail (S4)          |    P0    | DONE    |                0h |
| 3.12 | FAB Add Customer (S5)                     |    P0    | DONE    |                0h |
| 3.13 | Swipe Actions on Card                     |    P2    | DONE    |                0h |
| 3.14 | Multi-select Mode                         |    P2    | DONE    |                0h |

## 3) Thứ tự triển khai (cuốn chiếu)

- P0 trước: 3.1 → 3.2 → 3.3 → 3.11 → 3.12
- P1 sau: 3.4 → 3.5 → 3.10 → 3.9 → 3.6/3.7 polish
- P2 cuối (nếu còn thời gian): 3.13 → 3.14

## 4) Notes “gọn + prototype”

- Filter stage: map stage domain hiện có → nhóm UI `Hot/Warm/Cold/Won/Lost` (presentation helper).
- Search debounce 250–400ms; tìm theo `fullName`, `phoneNumber`, và `notes` (cả snippet).
- Pagination: mock “load more” từ in-memory (chia trang) để test UX.
- Widgetbook: đảm bảo có use-cases cho `CustomerListScreen` và `CustomerCard` (offline-safe).
