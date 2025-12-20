-- ================================================
-- CREATE TRIGGER SAAT PROMO DIBUAT (AFTER INSERT)
-- ================================================

-- DROP trigger lama jika ada
DROP TRIGGER IF EXISTS promos_on_insert ON promos CASCADE;
DROP FUNCTION IF EXISTS public.handle_promo_insert() CASCADE;

-- ================================================
-- 1. BUAT FUNCTION UNTUK TRIGGER NOTIFIKASI (SAFE VERSION)
-- ================================================

CREATE OR REPLACE FUNCTION public.handle_promo_insert()
RETURNS TRIGGER AS $$
BEGIN
  -- Simpan notifikasi ke table notifications (biarkan app/edge function yang tangani)
  INSERT INTO promo_notifications (promo_id, title, body, type, status, created_at)
  VALUES (
    NEW.id,
    '🎉 Promo Baru!',
    NEW.title || ' sedang tersedia',
    'promo',
    'pending',
    NOW()
  )
  ON CONFLICT DO NOTHING;

  -- Log promo creation ke audit table (backup log)
  INSERT INTO promo_audit_log (promo_id, action, description, created_at)
  VALUES (
    NEW.id,
    'created',
    'Promo "' || NEW.title || '" dibuat dengan kode: ' || NEW.promo_code,
    NOW()
  )
  ON CONFLICT (promo_id, action, created_at) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 2. BUAT TRIGGER
-- ================================================

CREATE TRIGGER promos_on_insert
AFTER INSERT ON promos
FOR EACH ROW
EXECUTE FUNCTION public.handle_promo_insert();

-- ================================================
-- 3. VERIFIKASI TRIGGER BERHASIL DIBUAT
-- ================================================

SELECT 
  trigger_name,
  event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'promos'
  AND trigger_name NOT LIKE 'RI_Constraint%';

-- ================================================
-- 4. CEK AUDIT LOG TABLE SUDAH ADA
-- ================================================

-- Jika table belum ada, buat:
CREATE TABLE IF NOT EXISTS promo_audit_log (
  id BIGSERIAL PRIMARY KEY,
  promo_id UUID NOT NULL,
  action VARCHAR(50) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (promo_id) REFERENCES promos(id) ON DELETE CASCADE,
  UNIQUE(promo_id, action, created_at)
);

-- ================================================
-- 4B. BUAT TABLE NOTIFICATIONS UNTUK QUEUE
-- ================================================

CREATE TABLE IF NOT EXISTS promo_notifications (
  id BIGSERIAL PRIMARY KEY,
  promo_id UUID NOT NULL,
  title VARCHAR(100) NOT NULL,
  body TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  sent_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (promo_id) REFERENCES promos(id) ON DELETE CASCADE
);

-- ================================================
-- 5. TEST INSERT PROMO - TRIGGER AKAN JALAN
-- ================================================

-- Gunakan PROMO CODE yang UNIK (tidak duplicate):
INSERT INTO promos 
  (title, description, promo_code, discount_amount, min_purchase, valid_from, valid_until, is_active, created_by)
VALUES 
  ('Promo dengan Trigger', 'Promo test dengan trigger baru', 'PROMO_' || TO_CHAR(NOW(), 'YYMMDDHHmmss'), 5000, 10000, NOW(), NOW() + INTERVAL '7 days', true,
   (SELECT id FROM profiles WHERE email = 'admin@gmail.com' LIMIT 1));

-- ================================================
-- 6. CEK AUDIT LOG
-- ================================================

SELECT * FROM promo_audit_log ORDER BY created_at DESC LIMIT 5;

-- ================================================
-- 7. CEK PROMO YANG BARU DIBUAT
-- ================================================

SELECT 
  id,
  title,
  promo_code,
  is_active,
  created_at
FROM promos
ORDER BY created_at DESC
LIMIT 5;
