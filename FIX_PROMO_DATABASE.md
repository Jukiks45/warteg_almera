# 🔧 Fix Error Promo Database

## ❌ Error yang Terjadi:
```
Pembayaran Gagal!
Error database: Could not find the 'promo_code' column of 'orders' in the schema cache
```

## ✅ Solusi:

### **Opsi 1: Gunakan Promo Tanpa Simpan ke Database (SUDAH AKTIF)**

Promo **SUDAH BERFUNGSI** di aplikasi! User bisa:
- ✅ Pilih dan gunakan promo
- ✅ Lihat diskon yang diterapkan
- ✅ Bayar dengan harga setelah diskon
- ⚠️ Promo **TIDAK tersimpan** di database order

**Status:** Aplikasi sudah fix dan bisa digunakan sekarang!

---

### **Opsi 2: Simpan Promo ke Database (OPSIONAL)**

Jika ingin menyimpan data promo ke database untuk analisis/laporan:

#### **Langkah 1: Update Database**
1. Buka **Supabase Dashboard**
2. Pilih project Anda
3. Klik **SQL Editor**
4. Copy-paste isi file `supabase_add_promo_columns.sql`
5. Klik **Run**

#### **Langkah 2: Uncomment Kode**
Buka file:
```
lib/modules/cart/controllers/cart_controller.dart
```

Cari bagian ini (sekitar baris 220):
```dart
// Uncomment baris berikut setelah menambahkan kolom di database:
// if (appliedPromoCode.value != null) {
//   orderData['promo_code'] = appliedPromoCode.value;
//   orderData['promo_discount'] = promoDiscount.value;
// }
```

Hapus tanda `//` untuk uncomment:
```dart
if (appliedPromoCode.value != null) {
  orderData['promo_code'] = appliedPromoCode.value;
  orderData['promo_discount'] = promoDiscount.value;
}
```

#### **Langkah 3: Test**
- Hot restart aplikasi
- Gunakan promo saat checkout
- Promo akan tersimpan ke database!

---

## 📊 Keuntungan Masing-masing Opsi:

### **Opsi 1 (Tanpa Simpan - Default)**
✅ Tidak perlu ubah database  
✅ Langsung bisa dipakai  
✅ Cocok untuk testing/development  
❌ Data promo tidak tersimpan  

### **Opsi 2 (Dengan Simpan)**
✅ Data promo tersimpan untuk analisis  
✅ Bisa tracking promo yang paling banyak digunakan  
✅ Untuk production/deployment  
⚠️ Perlu akses ke Supabase dashboard  

---

## 🎯 Rekomendasi:

**Untuk Testing:** Gunakan Opsi 1 (sudah aktif)  
**Untuk Production:** Gunakan Opsi 2 (ikuti langkah di atas)

---

## 🚀 Status Saat Ini:

- ✅ **Promo berfungsi di aplikasi**
- ✅ **User bisa gunakan kode promo**
- ✅ **Diskon diterapkan dengan benar**
- ✅ **Checkout berhasil tanpa error**
- ⚠️ **Data promo belum tersimpan di database** (opsional)

**Aplikasi siap digunakan!** 🎉
