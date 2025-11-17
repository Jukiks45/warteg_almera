# 🗄️ HIVE CART PERSISTENCE SETUP

## ✅ Fitur yang Sudah Diimplementasi

Cart sekarang menggunakan **Hive** untuk menyimpan data secara lokal dan persisten.

### Cara Kerja:
1. ✅ **Auto-load saat app dibuka** - Cart otomatis dimuat dari Hive
2. ✅ **Auto-save setiap perubahan** - Setiap add/update/remove langsung tersimpan
3. ✅ **Persist hingga pembayaran** - Cart tetap ada meskipun app ditutup
4. ✅ **Clear setelah checkout** - Cart dikosongkan otomatis setelah pembayaran berhasil

## 📂 File yang Dimodifikasi

### 1. **cart_item_adapter.dart** (NEW)
```
lib/modules/cart/models/cart_item_adapter.dart
```
- Custom Hive TypeAdapter untuk CartItemModel
- TypeId: 0
- Serialize/deserialize cart items

### 2. **local_storage_service.dart** (UPDATED)
```
lib/services/local_storage_service.dart
```
- Register CartItemAdapter
- Open cartBox untuk menyimpan cart data

### 3. **cart_controller.dart** (UPDATED)
```
lib/modules/cart/controllers/cart_controller.dart
```
- `onInit()`: Load cart dari Hive saat controller diinit
- `_saveCartToHive()`: Save cart setiap ada perubahan
- `clearCart()`: Clear dari memory dan Hive
- `onClose()`: Save final state sebelum controller dihancurkan

## 🧪 Testing Flow

### Test 1: Persistence Across App Restart
```
1. Login ke aplikasi
2. Tambahkan beberapa menu ke cart (misal 3 items)
3. TUTUP aplikasi sepenuhnya (force close)
4. Buka aplikasi lagi
5. ✅ Cart harus tetap ada dengan 3 items yang sama
```

### Test 2: Auto-save on Changes
```
1. Tambah item ke cart → Auto-saved
2. Ubah quantity (+/-) → Auto-saved
3. Hapus item → Auto-saved
4. Tutup app → Buka lagi → Semua perubahan tersimpan
```

### Test 3: Clear After Payment
```
1. Isi cart dengan beberapa items
2. Checkout dan bayar (sukses)
3. ✅ Cart otomatis kosong
4. Tutup app → Buka lagi → Cart tetap kosong (tidak ada data lama)
```

### Test 4: Multiple Users
```
1. Login sebagai user1
2. Tambah items ke cart
3. Logout
4. Login sebagai user2
5. ⚠️ Cart masih berisi items dari user1 (ini expected behavior)
   - Cart bersifat device-specific, tidak per-user
   - Untuk isolasi per-user, perlu tambahan implementasi
```

## 🔍 Debug Commands

### Check Hive Data:
```dart
// Di debug console atau add temporary button
final box = Hive.box('cartBox');
print('Cart data: ${box.get('cart_items')}');
```

### Clear Cart Manually (for testing):
```dart
// Temporary button untuk testing
final box = Hive.box('cartBox');
await box.delete('cart_items');
```

## ⚙️ Configuration

### Hive Box Name:
```dart
LocalStorageService.cartBoxName = 'cartBox'
```

### Storage Location:
- **Android**: `/data/data/com.example.app/app_flutter/`
- **iOS**: `Library/Application Support/`
- **Windows**: `%APPDATA%/Local/`

## 🎯 User Experience Flow

```
┌─────────────────────────────────────────────────┐
│ 1. User Browse Menu                             │
│    ↓                                             │
│ 2. Add to Cart → SAVE TO HIVE ✅                │
│    ↓                                             │
│ 3. Close App (cart saved locally)               │
│    ↓                                             │
│ 4. Open App → LOAD FROM HIVE ✅                 │
│    ↓                                             │
│ 5. Modify Cart → AUTO-SAVE ✅                   │
│    ↓                                             │
│ 6. Login (required for checkout)                │
│    ↓                                             │
│ 7. Checkout → SAVE TO SUPABASE ✅               │
│    ↓                                             │
│ 8. Clear Cart → DELETE FROM HIVE ✅             │
└─────────────────────────────────────────────────┘
```

## 🚀 Next Steps (Optional)

### Per-User Cart Isolation:
Jika ingin cart berbeda per user:
```dart
// Gunakan user_id sebagai key
final userId = _supabase.auth.currentUser?.id ?? 'guest';
await _cartBox.put('cart_$userId', cartData);
```

### Cart Expiration:
Tambahkan timestamp untuk auto-clear cart lama:
```dart
final lastSaved = DateTime.now();
await _cartBox.put('cart_timestamp', lastSaved.toIso8601String());
```

### Cloud Sync (Advanced):
Sinkronkan cart ke Supabase untuk akses multi-device.

---

**Status**: ✅ **FULLY IMPLEMENTED & READY TO USE**
