-- ================================================
-- CREATE ADMIN USER - WARTEG ALMERA
-- Setup user admin untuk testing
-- ================================================

/*
CARA BUAT USER ADMIN DI SUPABASE:

OPSI 1: LEWAT DASHBOARD (PALING MUDAH)
1. Buka Supabase Dashboard
2. Authentication → Users → Add User
3. Isi data:
   - Email: admin@warteg.com
   - Password: admin123
   - Auto Confirm: ON (centang)
4. Klik "Create User"

OPSI 2: LEWAT SQL EDITOR (ADVANCED)
Jalankan query berikut di SQL Editor:

-- Insert user ke auth.users (hanya untuk development)
-- CATATAN: Password harus di-hash dengan bcrypt
-- Gunakan Dashboard untuk lebih mudah!

*/

-- ================================================
-- TESTING LOGIN
-- ================================================

/*
CARA TESTING:

1. Buat user admin lewat Supabase Dashboard (Opsi 1 di atas)

2. Di aplikasi Flutter:
   - Username: admin
   - Password: admin123
   
3. Sistem akan otomatis convert ke email: admin@warteg.com

4. Setelah login berhasil, cek user di aplikasi:
   - Supabase Auth akan menyimpan session
   - Bisa checkout dan order akan tersimpan dengan user_id

BUAT USER LAIN (OPTIONAL):
- Email: user@warteg.com, Password: user123
- Email: kasir@warteg.com, Password: kasir123

FORMAT LOGIN:
- Ketik: admin → Sistem convert ke: admin@warteg.com
- Ketik: user → Sistem convert ke: user@warteg.com
- Ketik: kasir → Sistem convert ke: kasir@warteg.com
*/

-- ================================================
-- TROUBLESHOOTING
-- ================================================

/*
JIKA LOGIN GAGAL:
1. Pastikan user sudah dibuat di Supabase Dashboard
2. Pastikan "Auto Confirm" dicentang (atau verifikasi email)
3. Cek password benar (case-sensitive)
4. Cek koneksi internet dan Supabase URL di .env

JIKA CHECKOUT GAGAL:
1. Pastikan sudah login terlebih dahulu
2. Cek tabel orders dan order_items sudah dibuat
3. Disable RLS untuk testing (Table Editor → Settings → Disable RLS)

CEK USER YANG LOGIN:
SELECT * FROM auth.users ORDER BY created_at DESC;
*/
