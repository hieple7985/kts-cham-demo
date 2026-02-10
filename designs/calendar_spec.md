# Calendar Screen Design Spec (Fluent 2)

## Screen: Calendar Screen (lib/features/home/presentation/screens/calendar_screen.dart)

### Layout Structure

```
┌─────────────────────────────────────┐
│ ← Lịch    Tháng 1 2025    [Today]  │  AppBar
├─────────────────────────────────────┤
│  [Tháng] [Tuần] [Ngày]             │  View Toggle
│         <      >                    │  Navigation
├─────────────────────────────────────┤
│  T2  T3  T4  T5  T6  T7  CN        │  Weekday Header
├─────────────────────────────────────┤
│         1   2   3   4   5   6      │
│  7    8   9  10  11  12  13        │
│ 14   15●  16  17  18●  19  20      │  Calendar Grid
│ 21   22  23  24  25  26  27        │  ● = Has Events
│ 28   29  30  31                    │
├─────────────────────────────────────┤
│ Sự kiện ngày 15/1                  │  Event List Header
│ ─────────────────────────────────  │
│ │ Chăm sóc khách hàng              │  Event Card 1
│ │ Nguyễn Văn A • 09:00 - 10:00     │
│ ─────────────────────────────────  │
│ │ Hẹn gặp                          │  Event Card 2
│ │ Trần Thị B • 14:00 - 15:30       │
└─────────────────────────────────────┘
         [+ Thêm]                      FAB
```

### Design Tokens

| Element | Token | Value |
|---------|-------|-------|
| Background | `AppColors.background` | #FFFFFF |
| Surface | `AppColors.surface` | #F5F5F5 |
| Primary | `AppColors.primary` | #0078D4 |
| Border | `AppColors.grey3` | #E0E0E0 |

### Components

#### 1. View Toggle
```
┌───────────────────────────┐
│ [Tháng] [Tuần] [Ngày]     │
└───────────────────────────┘
Background: grey2 (#F5F5F5)
Selected: surface + shadow
Border Radius: 8px
Padding: 8px horizontal
```

#### 2. Calendar Grid Day Cell
```
┌─────┐
│  15 │  Normal day
└─────┘

┌═══════┐
│ ╾ 15 ╾│  Selected day
└═══════┘  Border: 2px primary
           Background: primary 10%

┌─────┐
│ 15 ●│  Has event
└─────┘  Dot: 4px circle, primary

┌─────┐
│ 15  │  Today
└─────┘  Color: primary, bold
```

#### 3. Event Card
```
┌─────────────────────────────────┐
|▮ Chăm sóc khách hàng      [Phone]│
|  Nguyễn Văn A • 09:00 - 10:00    │
└─────────────────────────────────┘
Border: 1px grey3
Radius: 12px
Left Accent: 4px width
```

### Event Type Colors

| Type | Color | Icon |
|------|-------|------|
| Reminder | warningText (#A03700) | notifications_outlined |
| Call | primary (#0078D4) | phone_outlined |
| Meeting | success (#107C10) | people_outlined |
| Task | grey7 (#616161) | check_circle_outline |

### FAB (Floating Action Button)

```
┌──────────┐
│ [+ Thêm] │
└──────────┘
Background: primary (#0078D4)
Icon: add, white
Text: "Thêm", white, bodyStrong
```

### Spacing

| Element | Token | Value |
|---------|-------|-------|
| Screen padding | `AppSpacing.s4` | 16px |
| Grid spacing | - | 4px |
| Card padding | `AppSpacing.s3` | 12px |
| Card margin | `AppSpacing.s2` | 8px |

### Typography

| Element | Style |
|---------|-------|
| Title | headline (20px, bold) |
| Month/Year | caption (14px, secondary) |
| Day number | body (16px) |
| Event title | bodyStrong (16px, bold) |
| Event detail | caption (14px, secondary) |

### States

| State | Description |
|-------|-------------|
| Today | Bold text, primary color |
| Selected | 2px border + 10% primary background |
| Has Event | 4px dot indicator at bottom |
| Normal | Default text color |

### Interactions

1. **Tap day** → Select day, show events in bottom panel
2. **Tap Previous/Next** → Navigate month/week/day
3. **Tap Today button** → Jump to today
4. **Tap View Toggle** → Switch between Month/Week/Day views
5. **Tap FAB** → Open add event dialog (prototype)
