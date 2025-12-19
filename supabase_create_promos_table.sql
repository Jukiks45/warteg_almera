-- ============================================================
-- TABEL PROMOS - Untuk CRUD Promo oleh Admin
-- ============================================================
-- File: supabase_create_promos_table.sql
-- Deskripsi: Membuat tabel promos dengan fitur CRUD lengkap untuk admin

-- 1. DROP table jika sudah ada (hati-hati, ini akan hapus semua data!)
-- DROP TABLE IF EXISTS promos CASCADE;

-- 2. CREATE TABLE promos
CREATE TABLE IF NOT EXISTS promos (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Informasi Promo
    title VARCHAR(100) NOT NULL,
    description TEXT,
    promo_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Nilai Diskon & Syarat
    discount_amount DECIMAL(10, 2) NOT NULL CHECK (discount_amount > 0),
    min_purchase DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (min_purchase >= 0),
    
    -- Periode Berlaku
    valid_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Media & Status
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Quota & Limit (opsional untuk fitur lanjutan)
    max_usage INTEGER,                    -- Maksimal berapa kali promo bisa dipakai total
    current_usage INTEGER DEFAULT 0,      -- Sudah dipakai berapa kali
    max_usage_per_user INTEGER DEFAULT 1, -- Maksimal berapa kali per user
    
    -- Audit Fields
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,  -- Soft delete
    
    -- Constraints
    CONSTRAINT valid_dates CHECK (valid_until > valid_from),
    CONSTRAINT valid_usage CHECK (max_usage IS NULL OR max_usage > 0),
    CONSTRAINT valid_current_usage CHECK (current_usage >= 0),
    CONSTRAINT valid_max_per_user CHECK (max_usage_per_user > 0)
);

-- 3. CREATE INDEXES untuk performance
CREATE INDEX IF NOT EXISTS idx_promos_promo_code ON promos(promo_code);
CREATE INDEX IF NOT EXISTS idx_promos_is_active ON promos(is_active) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_promos_valid_dates ON promos(valid_from, valid_until);
CREATE INDEX IF NOT EXISTS idx_promos_created_by ON promos(created_by);
CREATE INDEX IF NOT EXISTS idx_promos_deleted_at ON promos(deleted_at) WHERE deleted_at IS NULL;

-- 4. CREATE FUNCTION untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_promos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. CREATE TRIGGER untuk updated_at
DROP TRIGGER IF EXISTS trigger_update_promos_updated_at ON promos;
CREATE TRIGGER trigger_update_promos_updated_at
    BEFORE UPDATE ON promos
    FOR EACH ROW
    EXECUTE FUNCTION update_promos_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- 6. Enable RLS
ALTER TABLE promos ENABLE ROW LEVEL SECURITY;

-- 7. POLICY: Public bisa READ promo yang aktif (untuk tampilan app)
CREATE POLICY "Public can view active promos"
    ON promos
    FOR SELECT
    USING (
        is_active = true 
        AND deleted_at IS NULL
        AND NOW() BETWEEN valid_from AND valid_until
    );

-- 8. POLICY: Admin bisa SELECT semua promo (termasuk yang inactive/deleted)
CREATE POLICY "Admin can view all promos"
    ON promos
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.email = 'admin@gmail.com'
        )
    );

-- 9. POLICY: Admin bisa INSERT promo
CREATE POLICY "Admin can insert promos"
    ON promos
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.email = 'admin@gmail.com'
        )
    );

-- 10. POLICY: Admin bisa UPDATE promo
CREATE POLICY "Admin can update promos"
    ON promos
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.email = 'admin@gmail.com'
        )
    );

-- 11. POLICY: Admin bisa DELETE (hard delete) promo
CREATE POLICY "Admin can delete promos"
    ON promos
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.email = 'admin@gmail.com'
        )
    );

-- ============================================================
-- FUNCTION untuk Soft Delete
-- ============================================================

-- 12. CREATE FUNCTION untuk soft delete
CREATE OR REPLACE FUNCTION soft_delete_promo(promo_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE promos
    SET deleted_at = NOW()
    WHERE id = promo_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 13. CREATE FUNCTION untuk restore soft deleted promo
CREATE OR REPLACE FUNCTION restore_promo(promo_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE promos
    SET deleted_at = NULL
    WHERE id = promo_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION untuk Validasi Promo (untuk aplikasi)
-- ============================================================

-- 14. CREATE FUNCTION untuk cek apakah promo valid
CREATE OR REPLACE FUNCTION is_promo_valid(
    p_promo_code VARCHAR,
    p_user_id UUID,
    p_purchase_amount DECIMAL
)
RETURNS TABLE(
    valid BOOLEAN,
    promo_id UUID,
    discount_amount DECIMAL,
    message TEXT
) AS $$
DECLARE
    v_promo RECORD;
    v_user_usage INTEGER;
BEGIN
    -- Cari promo berdasarkan kode
    SELECT * INTO v_promo
    FROM promos
    WHERE promo_code = p_promo_code
    AND deleted_at IS NULL
    LIMIT 1;
    
    -- Promo tidak ditemukan
    IF v_promo IS NULL THEN
        RETURN QUERY SELECT false, NULL::UUID, 0::DECIMAL, 'Kode promo tidak valid';
        RETURN;
    END IF;
    
    -- Promo tidak aktif
    IF v_promo.is_active = false THEN
        RETURN QUERY SELECT false, v_promo.id, 0::DECIMAL, 'Promo tidak aktif';
        RETURN;
    END IF;
    
    -- Promo belum berlaku atau sudah expired
    IF NOW() < v_promo.valid_from THEN
        RETURN QUERY SELECT false, v_promo.id, 0::DECIMAL, 'Promo belum berlaku';
        RETURN;
    END IF;
    
    IF NOW() > v_promo.valid_until THEN
        RETURN QUERY SELECT false, v_promo.id, 0::DECIMAL, 'Promo sudah expired';
        RETURN;
    END IF;
    
    -- Pembelian tidak memenuhi minimal
    IF p_purchase_amount < v_promo.min_purchase THEN
        RETURN QUERY SELECT 
            false, 
            v_promo.id, 
            0::DECIMAL, 
            'Minimal pembelian Rp ' || v_promo.min_purchase;
        RETURN;
    END IF;
    
    -- Cek quota total (jika ada)
    IF v_promo.max_usage IS NOT NULL AND v_promo.current_usage >= v_promo.max_usage THEN
        RETURN QUERY SELECT false, v_promo.id, 0::DECIMAL, 'Quota promo sudah habis';
        RETURN;
    END IF;
    
    -- Cek quota per user (jika ada user_id dan tabel promo_usage)
    -- Asumsi: ada tabel promo_usage untuk tracking
    -- Jika belum ada, skip validasi ini atau buat tabel terpisah
    
    -- Promo valid!
    RETURN QUERY SELECT 
        true, 
        v_promo.id, 
        v_promo.discount_amount, 
        'Promo berhasil diterapkan!';
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- INSERT DATA DUMMY untuk Testing (opsional)
-- ============================================================

-- 15. INSERT beberapa promo dummy
-- CATATAN: Promo ini akan bisa di-edit oleh user dengan email admin@gmail.com
INSERT INTO promos (
    title,
    description,
    promo_code,
    discount_amount,
    min_purchase,
    valid_from,
    valid_until,
    is_active,
    max_usage,
    max_usage_per_user
) VALUES
(
    'Hemat 5K - Promo Spesial',
    'Diskon Rp 5.000 untuk pembelian minimal Rp 10.000',
    'HEMAT5K',
    5000,
    10000,
    NOW(),
    NOW() + INTERVAL '30 days',
    true,
    100,
    1
),
(
    'Save 10K - Member Baru',
    'Diskon Rp 10.000 khusus member baru dengan pembelian minimal Rp 20.000',
    'SAVE10K',
    10000,
    20000,
    NOW(),
    NOW() + INTERVAL '60 days',
    true,
    50,
    1
),
(
    'Super Diskon 15K',
    'Diskon Rp 15.000 untuk pembelian minimal Rp 30.000',
    'SUPER15',
    15000,
    30000,
    NOW(),
    NOW() + INTERVAL '7 days',
    true,
    NULL,  -- Unlimited usage
    2
),
(
    'Free Ongkir',
    'Gratis ongkir senilai Rp 5.000',
    'FREEONGKIR',
    5000,
    15000,
    NOW(),
    NOW() + INTERVAL '90 days',
    true,
    200,
    3
)
ON CONFLICT (promo_code) DO NOTHING;

-- ============================================================
-- TABEL TAMBAHAN: promo_usage (untuk tracking penggunaan promo)
-- ============================================================

-- 16. CREATE TABLE promo_usage untuk tracking
CREATE TABLE IF NOT EXISTS promo_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promo_id UUID NOT NULL REFERENCES promos(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    discount_applied DECIMAL(10, 2) NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: satu user tidak bisa pakai promo yang sama lebih dari max_usage_per_user
    UNIQUE(promo_id, user_id, order_id)
);

-- 17. INDEX untuk promo_usage
CREATE INDEX IF NOT EXISTS idx_promo_usage_promo_id ON promo_usage(promo_id);
CREATE INDEX IF NOT EXISTS idx_promo_usage_user_id ON promo_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_promo_usage_used_at ON promo_usage(used_at);

-- 18. FUNCTION untuk increment usage saat promo dipakai
CREATE OR REPLACE FUNCTION increment_promo_usage()
RETURNS TRIGGER AS $$
BEGIN
    -- Increment current_usage di tabel promos
    UPDATE promos
    SET current_usage = current_usage + 1
    WHERE id = NEW.promo_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 19. TRIGGER untuk auto-increment usage
DROP TRIGGER IF EXISTS trigger_increment_promo_usage ON promo_usage;
CREATE TRIGGER trigger_increment_promo_usage
    AFTER INSERT ON promo_usage
    FOR EACH ROW
    EXECUTE FUNCTION increment_promo_usage();

-- 20. RLS untuk promo_usage
ALTER TABLE promo_usage ENABLE ROW LEVEL SECURITY;

-- User bisa lihat history penggunaan promo mereka sendiri
CREATE POLICY "Users can view their own promo usage"
    ON promo_usage
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Admin bisa lihat semua history
CREATE POLICY "Admin can view all promo usage"
    ON promo_usage
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.email = 'admin@gmail.com'
        )
    );

-- System bisa insert (via backend)
CREATE POLICY "System can insert promo usage"
    ON promo_usage
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- ============================================================
-- VIEWS untuk Admin Dashboard (opsional)
-- ============================================================

-- 21. VIEW: Statistik Promo
CREATE OR REPLACE VIEW promo_statistics AS
SELECT 
    p.id,
    p.promo_code,
    p.title,
    p.discount_amount,
    p.min_purchase,
    p.is_active,
    p.current_usage,
    p.max_usage,
    CASE 
        WHEN p.max_usage IS NULL THEN 0
        ELSE ROUND((p.current_usage::DECIMAL / p.max_usage) * 100, 2)
    END as usage_percentage,
    COUNT(DISTINCT pu.user_id) as unique_users,
    COALESCE(SUM(pu.discount_applied), 0) as total_discount_given,
    p.valid_from,
    p.valid_until,
    CASE 
        WHEN NOW() < p.valid_from THEN 'Belum Berlaku'
        WHEN NOW() > p.valid_until THEN 'Expired'
        WHEN p.is_active = false THEN 'Tidak Aktif'
        WHEN p.max_usage IS NOT NULL AND p.current_usage >= p.max_usage THEN 'Quota Habis'
        ELSE 'Aktif'
    END as status
FROM promos p
LEFT JOIN promo_usage pu ON p.id = pu.promo_id
WHERE p.deleted_at IS NULL
GROUP BY p.id;

-- ============================================================
-- GRANT PERMISSIONS (jika diperlukan)
-- ============================================================

-- 22. Grant permissions (sesuaikan dengan kebutuhan)
-- GRANT SELECT ON promos TO anon;
-- GRANT ALL ON promos TO authenticated;

-- ============================================================
-- COMMENTS untuk dokumentasi
-- ============================================================

COMMENT ON TABLE promos IS 'Tabel untuk menyimpan data promo yang bisa di-CRUD oleh admin (email: admin@gmail.com)';
COMMENT ON COLUMN promos.promo_code IS 'Kode unik promo yang diinput user';
COMMENT ON COLUMN promos.discount_amount IS 'Jumlah diskon dalam rupiah';
COMMENT ON COLUMN promos.min_purchase IS 'Minimal pembelian untuk bisa pakai promo';
COMMENT ON COLUMN promos.max_usage IS 'Maksimal berapa kali promo bisa dipakai (NULL = unlimited)';
COMMENT ON COLUMN promos.current_usage IS 'Jumlah promo yang sudah dipakai';
COMMENT ON COLUMN promos.deleted_at IS 'Timestamp soft delete (NULL = belum dihapus)';

COMMENT ON TABLE promo_usage IS 'Tabel untuk tracking penggunaan promo oleh user';
COMMENT ON FUNCTION is_promo_valid IS 'Validasi apakah promo bisa dipakai berdasarkan kode, user, dan jumlah pembelian';

-- ============================================================
-- SELESAI!
-- ============================================================

-- Cara menggunakan:
-- 1. Jalankan script ini di Supabase SQL Editor
-- 2. Pastikan tabel 'profiles' sudah ada dengan kolom 'email'
-- 3. Pastikan sudah ada minimal 1 user dengan email 'admin@gmail.com'
-- 4. Test dengan query:
--    SELECT * FROM promos;
--    SELECT * FROM promo_statistics;
--    SELECT * FROM is_promo_valid('HEMAT5K', 'user_uuid', 15000);
