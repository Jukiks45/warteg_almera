-- ================================================
-- SUPABASE DATABASE SCHEMA - CART/ORDERS
-- Minimal schema untuk fitur keranjang belanja
-- ================================================

-- ================================================
-- 1. TABEL ORDERS (Header Pesanan)
-- ================================================
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  total_items INT NOT NULL DEFAULT 0,
  total_price NUMERIC(12,2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'paid',
  payment_method TEXT DEFAULT 'cash',
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 2. TABEL ORDER_ITEMS (Detail Item per Pesanan)
-- ================================================
CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  menu_id INT NOT NULL,
  menu_nama TEXT NOT NULL,
  menu_kategori TEXT,
  menu_harga NUMERIC(12,2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  subtotal NUMERIC(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 3. INDEXES (Untuk Performa Query)
-- ================================================
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

-- ================================================
-- CARA SETUP & TESTING
-- ================================================

/*
SETUP:
1. Copy SQL di atas
2. Buka Supabase Dashboard → SQL Editor
3. Paste dan klik "Run"
4. Verifikasi tabel orders & order_items sudah terbuat

DISABLE RLS (Development):
1. Table Editor → orders → Settings → Disable RLS
2. Table Editor → order_items → Settings → Disable RLS

TESTING:
1. Login di aplikasi Flutter
2. Tambahkan menu ke cart
3. Klik checkout dan bayar
4. Cek di Supabase Table Editor → orders (data order akan muncul)

QUERY UNTUK CEK DATA:
-- Lihat semua orders
SELECT * FROM orders ORDER BY created_at DESC;

-- Lihat order dengan detail items
SELECT 
  o.id,
  o.user_id,
  o.total_items,
  o.total_price,
  o.created_at,
  oi.menu_nama,
  oi.quantity,
  oi.subtotal
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
ORDER BY o.created_at DESC;

-- Total penjualan
SELECT 
  COUNT(*) as total_orders, 
  SUM(total_price) as total_revenue 
FROM orders;
*/
