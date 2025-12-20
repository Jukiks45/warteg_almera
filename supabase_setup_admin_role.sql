-- ================================================
-- SETUP ADMIN ROLE DI TABLE PROFILES
-- ================================================

/*
ROLE VALUES YANG DIGUNAKAN:
- 'admin'  : User dengan akses penuh (tambah/edit/hapus menu & promo)
- 'user'   : User biasa (hanya bisa melihat & order)
- 'kasir'  : User kasir (bisa terima pembayaran)
*/

-- ================================================
-- 1. PASTIKAN KOLOM ROLE SUDAH ADA
-- ================================================

-- CEK KOLOM ROLE (jalankan di SQL Editor untuk lihat hasilnya):
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'profiles' AND column_name = 'role';

-- JIKA KOLOM BELUM ADA, TAMBAHKAN:
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- TAMBAH COMMENT UNTUK DOKUMENTASI:
COMMENT ON COLUMN profiles.role IS 'Role user: admin, user, atau kasir';

-- ================================================
-- 2. INSERT/UPDATE USER ADMIN
-- ================================================

-- INSERT user admin baru dengan role 'admin':
INSERT INTO profiles (id, email, role, full_name, created_at, updated_at)
SELECT 
  id,
  email,
  'admin',
  'Admin Warteg',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'admin@gmail.com'
ON CONFLICT (id) DO UPDATE
SET 
  role = 'admin',
  updated_at = NOW();

-- ================================================
-- 3. UPDATE ROLE USER YANG ADA
-- ================================================

-- Ubah user tertentu menjadi admin:
UPDATE profiles 
SET role = 'admin', updated_at = NOW()
WHERE email = 'admin@gmail.com';

-- Ubah user tertentu menjadi kasir:
UPDATE profiles 
SET role = 'kasir', updated_at = NOW()
WHERE email = 'kasir@warteg.com';

-- ================================================
-- 4. VERIFIKASI DATA ADMIN
-- ================================================

-- LIHAT SEMUA USER & ROLE MEREKA:
SELECT 
  id,
  email,
  role,
  created_at,
  updated_at
FROM profiles
ORDER BY role DESC, created_at DESC;

-- LIHAT HANYA ADMIN:
SELECT * FROM profiles WHERE role = 'admin';

-- LIHAT HANYA KASIR:
SELECT * FROM profiles WHERE role = 'kasir';

-- ================================================
-- 5. CEK KECOCOKAN DENGAN AUTH USERS
-- ================================================

-- CEK USER AUTH YANG BELUM ADA PROFILE:
SELECT 
  au.id,
  au.email,
  CASE WHEN p.id IS NULL THEN 'BELUM ADA PROFILE' ELSE 'ADA PROFILE' END as status
FROM auth.users au
LEFT JOIN profiles p ON p.id = au.id
ORDER BY au.created_at DESC;

-- ================================================
-- 6. INSERT PROFILE UNTUK AUTH USER YANG MISSING
-- ================================================

-- AUTO INSERT profile dari auth.users yang belum ada di profiles:
INSERT INTO profiles (id, email, role, created_at, updated_at)
SELECT 
  id,
  email,
  CASE 
    WHEN email = 'admin@gmail.com' THEN 'admin'
    WHEN email LIKE '%kasir%' THEN 'kasir'
    ELSE 'user'
  END,
  NOW(),
  NOW()
FROM auth.users
WHERE id NOT IN (SELECT id FROM profiles)
ON CONFLICT DO NOTHING;

-- ================================================
-- 7. QUERY UNTUK COBA FITUR ADMIN
-- ================================================

-- SIMULASI: Cek apakah user bisa INSERT promo (harus admin)
-- Di app: User login dengan admin@gmail.com
-- Promo akan insert HANYA jika:
-- 1. User sudah login (authenticated)
-- 2. Email user = 'admin@gmail.com'
-- 3. Role = 'admin' (OPTIONAL, tapi baik untuk memiliki)

-- ================================================
-- 8. DEBUG: JIKA ERROR 403 SAAT INSERT PROMO
-- ================================================

/*
CHECKLIST jika mendapat error 403:

1. ✅ User sudah login dengan email admin@gmail.com?
   - SELECT * FROM auth.users WHERE email = 'admin@gmail.com';

2. ✅ Profile user admin sudah ada di table profiles?
   - SELECT * FROM profiles WHERE email = 'admin@gmail.com';

3. ✅ Role user admin = 'admin' atau role field ada value?
   - SELECT email, role FROM profiles WHERE email = 'admin@gmail.com';

4. ✅ RLS Policy pada table promos mengizinkan admin?
   - Jalankan: SELECT * FROM auth.policies() WHERE table_name = 'promos';

5. ✅ Token auth masih valid & tidak expired?
   - Token baru dapat dari login ulang

6. ✅ API Key di .env sudah benar?
   - SUPABASE_API_KEY harus sesuai dengan SUPABASE_URL

JIKA MASIH ERROR:
- Disable RLS untuk testing: Table Editor → promos → Settings → Disable RLS
- Jika perlu production: Buat RLS policy yang lebih fleksibel
*/

-- ================================================
-- 9. BUAT INDEX UNTUK PERFORMANCE
-- ================================================

-- Buat index pada kolom email & role untuk query lebih cepat:
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email_role ON profiles(email, role);

-- ================================================
-- 10. SETUP AWAL (JALANKAN INI PERTAMA KALI)
-- ================================================

/*
URUTAN SETUP:
1. Jalankan query di step 1 (ALTER TABLE ADD COLUMN)
2. Jalankan query di step 2 (INSERT user admin)
3. Jalankan query di step 3 (UPDATE role)
4. Jalankan query di step 4 untuk verifikasi
5. Buat user baru atau update user yang ada
6. Test login & insert promo dari app
*/
