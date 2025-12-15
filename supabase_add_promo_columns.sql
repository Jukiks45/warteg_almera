-- ============================================
-- SQL Migration: Menambahkan Kolom Promo ke Tabel Orders
-- ============================================
-- Jalankan script ini di Supabase SQL Editor untuk menambahkan
-- dukungan promo/voucher ke sistem pembayaran

-- 1. Tambahkan kolom promo_code untuk menyimpan kode promo yang digunakan
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS promo_code TEXT;

-- 2. Tambahkan kolom promo_discount untuk menyimpan nilai diskon
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS promo_discount NUMERIC(10,2) DEFAULT 0;

-- 3. Tambahkan index untuk performa query berdasarkan promo_code (opsional)
CREATE INDEX IF NOT EXISTS idx_orders_promo_code ON orders(promo_code);

-- 4. Verifikasi perubahan
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'orders' 
  AND column_name IN ('promo_code', 'promo_discount')
ORDER BY ordinal_position;

-- ============================================
-- Setelah menjalankan migration ini:
-- ============================================
-- 1. Buka file: lib/modules/cart/controllers/cart_controller.dart
-- 2. Cari bagian "saveOrderToSupabase"
-- 3. Uncomment baris berikut:
--
--    if (appliedPromoCode.value != null) {
--      orderData['promo_code'] = appliedPromoCode.value;
--      orderData['promo_discount'] = promoDiscount.value;
--    }
--
-- 4. Save dan promo akan tersimpan ke database!

-- ============================================
-- Rollback (jika perlu):
-- ============================================
-- ALTER TABLE orders DROP COLUMN IF EXISTS promo_code;
-- ALTER TABLE orders DROP COLUMN IF EXISTS promo_discount;
-- DROP INDEX IF EXISTS idx_orders_promo_code;
