# Issue #23 — S5 Add / Edit Customer (Frontend Prototype) — hle85

> Scope: **prototype/mock**. Không smoke test theo từng issue; chỉ build/run sau khi gom xong toàn bộ prototype.

## 1) Snapshot hiện trạng (trên `develop`)

- Screen: `3_dev/mobile_app/lib/features/customers/presentation/screens/add_edit_customer_screen.dart` dùng `FormBuilder`, nhập SĐT phụ dạng chuỗi, chưa có nhiều SĐT có label/Zalo.
- Flow: S3 mở S5 bằng FAB; S4 có nút edit.
- Data: `Customer` đã có `phoneNumber`, `additionalPhones`, `zaloLink/facebookLink`, `source`, `notes`, `stage`.

## 2) Checklist 5.1 – 5.15 (đối chiếu Issue #23)

Quy ước: `TODO` | `PARTIAL` | `DONE`

| ID   | Hạng mục                                        | Priority | Status  |
| ---: | ----------------------------------------------- | :------: | ------- |
|  5.1 | Add screen layout (sticky Save)                  |    P0    | DONE    |
|  5.2 | Edit screen (prefill + Save/Cancel)              |    P0    | DONE    |
|  5.3 | Basic fields (name req, avatar optional)         |    P0    | DONE    |
|  5.4 | Multiple phones (label, hasZalo, add/remove)     |    P0    | DONE    |
|  5.5 | Phone validation (format + no duplicates)        |    P1    | DONE    |
|  5.6 | Social links section (add/remove)                |    P1    | DONE    |
|  5.7 | Paste clipboard for social links                 |    P1    | DONE    |
|  5.8 | Social link guide bottom sheet                   |    P1    | DONE    |
|  5.9 | Import from phone contacts (prototype mock)      |    P1    | DONE    |
| 5.10 | Stage selection (Hot/Warm/Cold/Won/Lost)         |    P0    | DONE    |
| 5.11 | Notes field                                      |    P1    | DONE    |
| 5.12 | Source field                                     |    P2    | DONE    |
| 5.13 | Save validation + inline errors                  |    P0    | DONE    |
| 5.14 | Save success mascot + navigate back              |    P1    | DONE    |
| 5.15 | Discard changes confirmation                     |    P1    | DONE    |

## 3) Thứ tự triển khai (cuốn chiếu)

- P0: 5.1 → 5.4 → 5.10 → 5.13 → 5.2/5.3
- P1: 5.6 → 5.7 → 5.8 → 5.14 → 5.15 → 5.9
- P2: 5.12 polish

## 4) Notes “gọn + prototype”

- Avatar/contact picker: prototype sẽ dùng placeholder (SnackBar) để web-safe.
- Deep link MXH: chỉ validate dạng URL cơ bản, không mở app thật.
- Mapping stage: dùng nhóm `Hot/Warm/Cold/Won/Lost` giống S3/S4 (presentation helper).
