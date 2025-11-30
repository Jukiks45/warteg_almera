-- =====================================================
-- SQL MIGRATION: Add Location Tracking to Profiles
-- =====================================================
-- Tabel: profiles
-- Deskripsi: Menambahkan kolom latitude, longitude, dan updated_at
--            untuk tracking lokasi user secara realtime
-- =====================================================

-- Cek apakah tabel profiles sudah ada, jika belum buat dulu
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tambahkan kolom latitude jika belum ada
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'latitude'
    ) THEN
        ALTER TABLE public.profiles 
        ADD COLUMN latitude DOUBLE PRECISION;
    END IF;
END $$;

-- Tambahkan kolom longitude jika belum ada
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'longitude'
    ) THEN
        ALTER TABLE public.profiles 
        ADD COLUMN longitude DOUBLE PRECISION;
    END IF;
END $$;

-- Buat index untuk query berdasarkan lokasi (optional, untuk performa)
CREATE INDEX IF NOT EXISTS idx_profiles_location 
ON public.profiles(latitude, longitude);

-- Buat index untuk updated_at (untuk query lokasi terbaru)
CREATE INDEX IF NOT EXISTS idx_profiles_updated_at 
ON public.profiles(updated_at DESC);

-- =====================================================
-- RLS (Row Level Security) Policies
-- =====================================================

-- Enable RLS jika belum aktif
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies jika ada (untuk re-run migration)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;

-- Policy: User dapat membaca profil mereka sendiri
CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

-- Policy: User dapat update profil mereka sendiri (termasuk lokasi)
CREATE POLICY "Users can update their own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy: User dapat insert profil mereka sendiri
CREATE POLICY "Users can insert their own profile"
ON public.profiles
FOR INSERT
WITH CHECK (auth.uid() = id);

-- =====================================================
-- TRIGGER: Auto-update updated_at timestamp
-- =====================================================

-- Function untuk auto-update updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger yang memanggil function di atas
DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- SAMPLE QUERY
-- =====================================================

-- Query untuk mendapatkan lokasi semua user (jika diperlukan)
-- SELECT 
--     id, 
--     email, 
--     full_name, 
--     latitude, 
--     longitude, 
--     updated_at 
-- FROM public.profiles 
-- WHERE latitude IS NOT NULL 
--   AND longitude IS NOT NULL
-- ORDER BY updated_at DESC;

-- Query untuk mendapatkan user dalam radius tertentu (contoh: 5km dari Jakarta)
-- SELECT 
--     id,
--     email,
--     full_name,
--     latitude,
--     longitude,
--     (
--         6371 * acos(
--             cos(radians(-6.2088)) * cos(radians(latitude)) * 
--             cos(radians(longitude) - radians(106.8456)) + 
--             sin(radians(-6.2088)) * sin(radians(latitude))
--         )
--     ) AS distance_km
-- FROM public.profiles
-- WHERE latitude IS NOT NULL 
--   AND longitude IS NOT NULL
-- HAVING distance_km <= 5
-- ORDER BY distance_km;

-- =====================================================
-- VERIFIKASI
-- =====================================================

-- Verifikasi struktur tabel
-- \d public.profiles

-- Verifikasi RLS policies
-- SELECT * FROM pg_policies WHERE tablename = 'profiles';

COMMENT ON COLUMN public.profiles.latitude IS 'User current latitude from GPS';
COMMENT ON COLUMN public.profiles.longitude IS 'User current longitude from GPS';
COMMENT ON COLUMN public.profiles.updated_at IS 'Last time profile was updated (auto-updated)';
