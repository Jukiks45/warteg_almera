# 📋 RIWAYAT PEMESANAN (ORDER HISTORY)

## ✅ Fitur yang Sudah Diimplementasi

Sistem riwayat pemesanan lengkap yang menampilkan semua pesanan user dari database Supabase.

---

## 🎯 Fitur Utama

### 1. **Daftar Pesanan**
- ✅ Menampilkan semua pesanan user (berdasarkan user_id)
- ✅ Diurutkan dari yang terbaru
- ✅ Preview 2 item pertama di setiap card
- ✅ Indikator jika ada item lebih banyak
- ✅ Status pesanan (Dibayar, Menunggu, Selesai, Dibatalkan)
- ✅ Metode pembayaran (Tunai, Kartu, QRIS)

### 2. **Detail Pesanan**
- ✅ Modal bottom sheet dengan detail lengkap
- ✅ Semua item yang dipesan
- ✅ Harga per item dan subtotal
- ✅ Total pembayaran
- ✅ Tanggal dan waktu pesanan
- ✅ Catatan (jika ada)

### 3. **UI/UX Features**
- ✅ Pull to refresh
- ✅ Loading state
- ✅ Empty state (belum ada pesanan)
- ✅ Error state dengan retry button
- ✅ Color-coded status chips
- ✅ Icon untuk metode pembayaran
- ✅ Format currency (Rp)
- ✅ Format date (dd MMM yyyy, HH:mm)

---

## 📂 Struktur File

```
lib/modules/order_history/
├── models/
│   ├── order_model.dart          # Model untuk order header
│   └── order_item_model.dart     # Model untuk order items
├── controllers/
│   └── order_history_controller.dart  # Logic fetch & format data
├── views/
│   └── order_history_view.dart   # UI riwayat pesanan
└── bindings/
    └── order_history_binding.dart     # Dependency injection
```

---

## 🔗 Integrasi

### Routes
```dart
// app_routes.dart
static const orderHistory = '/order-history';

// app_pages.dart
GetPage(
  name: AppRoutes.orderHistory,
  page: () => const OrderHistoryView(),
  binding: OrderHistoryBinding(),
),
```

### Menu View
- ✅ Icon riwayat pesanan di AppBar (icon receipt)
- ✅ Navigate ke OrderHistoryView saat diklik

---

## 💾 Database Query

### Fetch Orders
```sql
SELECT * FROM orders 
WHERE user_id = 'USER_UUID' 
ORDER BY created_at DESC
```

### Fetch Order Items
```sql
SELECT * FROM order_items 
WHERE order_id = 'ORDER_UUID'
```

---

## 🎨 UI Components

### Order Card
```
┌─────────────────────────────────────┐
│ Pesanan #abc12345      [Status Chip]│
│ 18 Nov 2025, 14:30                  │
├─────────────────────────────────────┤
│ 2x Nasi Goreng          Rp 50.000   │
│ 1x Es Teh Manis         Rp 5.000    │
│ +3 item lainnya                      │
├─────────────────────────────────────┤
│ Total                    [💳 Tunai]  │
│ Rp 85.000                            │
└─────────────────────────────────────┘
```

### Status Chips
- 🟠 **Menunggu** (pending) - Orange
- 🟢 **Dibayar** (paid) - Green
- 🔵 **Selesai** (completed) - Blue
- 🔴 **Dibatalkan** (cancelled) - Red

### Payment Icons
- 💵 **Tunai** (cash)
- 💳 **Kartu** (card)
- 📱 **QRIS** (qris)

---

## 🧪 Testing Flow

### Test 1: Melihat Riwayat
```
1. Login ke aplikasi
2. Klik icon riwayat (receipt icon) di menu
3. ✅ Tampil list semua pesanan
4. ✅ Pesanan terbaru di atas
```

### Test 2: Detail Pesanan
```
1. Di halaman riwayat
2. Tap salah satu order card
3. ✅ Bottom sheet muncul
4. ✅ Tampil detail lengkap
5. ✅ Scroll untuk lihat semua items
```

### Test 3: Refresh Data
```
1. Di halaman riwayat
2. Pull down untuk refresh
   ATAU
3. Klik icon refresh di AppBar
4. ✅ Data ter-update
```

### Test 4: Empty State
```
1. Login sebagai user baru (belum pernah order)
2. Buka riwayat pesanan
3. ✅ Tampil empty state dengan icon & text
```

### Test 5: Error Handling
```
1. Matikan koneksi internet
2. Buka riwayat pesanan
3. ✅ Tampil error state
4. Klik "Coba Lagi"
5. ✅ Fetch ulang data
```

---

## 🔄 Integration dengan Cart

Setelah checkout berhasil di CartView:
```dart
// cart_controller.dart
await _supabase.from('order_items').insert(orderItemsData);

// Clear cart after successful payment
clearCart();

// Data otomatis tersimpan di database
// Bisa langsung dilihat di Order History
```

---

## 📊 Data Flow

```
┌─────────────────────────────────────────┐
│           ORDER HISTORY FLOW            │
├─────────────────────────────────────────┤
│                                         │
│  User Opens Order History               │
│         ↓                               │
│  Controller.fetchOrders()               │
│         ↓                               │
│  Query Supabase: orders + order_items   │
│         ↓                               │
│  Parse to Model Objects                 │
│         ↓                               │
│  Display in ListView                    │
│         ↓                               │
│  User Taps Order Card                   │
│         ↓                               │
│  Show Detail in BottomSheet             │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🎯 User Journey

### Scenario 1: After Checkout
```
User: Browse Menu → Add to Cart → Checkout → Pay
System: Save to DB
User: Click Receipt Icon
Result: ✅ New order appears at top of list
```

### Scenario 2: View Past Orders
```
User: Open Order History
System: Fetch all user orders from DB
User: See complete history
User: Tap order for details
Result: ✅ Full order details displayed
```

### Scenario 3: Track Payment Method
```
User: View order history
System: Display payment method icon & label
Result: ✅ User can see how they paid
```

---

## 🚀 Features Overview

| Feature | Status | Description |
|---------|--------|-------------|
| List Orders | ✅ | Display all user orders |
| Order Details | ✅ | Full detail in bottom sheet |
| Status Badge | ✅ | Color-coded status chips |
| Payment Method | ✅ | Icon & label for payment |
| Pull to Refresh | ✅ | Refresh order data |
| Empty State | ✅ | Show when no orders |
| Error Handling | ✅ | Retry on failure |
| Date Formatting | ✅ | Indonesian format |
| Currency Format | ✅ | Rupiah with separator |
| User-specific | ✅ | Filter by user_id |
| Sorted by Date | ✅ | Newest first |

---

## 📱 Navigation

### From Menu Screen
```dart
IconButton(
  icon: const Icon(Icons.receipt_long),
  onPressed: () => Get.toNamed(AppRoutes.orderHistory),
  tooltip: 'Riwayat Pesanan',
)
```

### Back to Menu
```
AppBar back button → Auto navigate back
```

---

## 🔧 Maintenance Notes

### To Add Status Change
Update `_getStatusLabel()` and `_buildStatusChip()` in order_history_view.dart

### To Add Payment Method
Update `_getPaymentIcon()` and `_getPaymentLabel()` in order_history_view.dart

### To Change Date Format
Update `formatDate()` in order_history_controller.dart

### To Change Currency Format
Update `formatCurrency()` in order_history_controller.dart

---

## ✅ Status: FULLY IMPLEMENTED

**Riwayat pemesanan lengkap dan siap digunakan!** 🎉

### Quick Access:
- 🏠 Menu Screen → Icon Receipt (top right) → Order History
- 📋 View all orders
- 👆 Tap for details
- 🔄 Pull to refresh

**Happy ordering!** 🍽️
