"""
🚀 Script Test FCM - Kirim Notifikasi ke Flutter App
====================================================

CARA PAKAI:
1. Install: pip install firebase-admin
2. Download service account key dari Firebase Console:
   - Project Settings → Service Accounts → Generate new private key
   - Simpan sebagai "serviceAccountKey.json" di folder yang sama dengan script ini
3. Ganti FCM_TOKEN dengan token dari console aplikasi
4. Run: python send_test_notification.py

"""

import firebase_admin
from firebase_admin import credentials, messaging
import sys

# ========================================
# KONFIGURASI - GANTI INI!
# ========================================

# 1. FCM Token dari console aplikasi (lihat output "FCM Token: xxxxx")
FCM_TOKEN = "PASTE_TOKEN_DARI_CONSOLE_DI_SINI"

# 2. Path ke service account key
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"

# ========================================
# JANGAN EDIT DI BAWAH INI
# ========================================

def send_test_notification():
    """Kirim notifikasi test sederhana"""
    
    # Initialize Firebase Admin
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
        print("✅ Firebase Admin initialized")
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        print("\n📝 Pastikan file 'serviceAccountKey.json' ada!")
        print("   Download dari: Firebase Console → Project Settings → Service Accounts")
        sys.exit(1)
    
    # Validasi token
    if FCM_TOKEN == "PASTE_TOKEN_DARI_CONSOLE_DI_SINI":
        print("❌ Error: FCM_TOKEN belum diganti!")
        print("\n📝 Cara mendapatkan token:")
        print("   1. Run aplikasi Flutter: flutter run")
        print("   2. Cek console, cari: 'FCM Token: xxxxx'")
        print("   3. Copy token dan paste di variable FCM_TOKEN di script ini")
        sys.exit(1)
    
    # Buat message
    message = messaging.Message(
        notification=messaging.Notification(
            title='🎉 Test dari Python',
            body='Notifikasi berhasil dikirim menggunakan Firebase Admin SDK!',
        ),
        data={
            'type': 'promo',
            'promo_id': '1',
        },
        token=FCM_TOKEN,
    )
    
    # Kirim
    try:
        response = messaging.send(message)
        print(f"\n✅ Notifikasi berhasil dikirim!")
        print(f"📨 Message ID: {response}")
        print(f"\n🎯 Cek aplikasi Anda, notifikasi seharusnya muncul!")
    except Exception as e:
        print(f"\n❌ Error mengirim notifikasi: {e}")
        print("\n📝 Kemungkinan penyebab:")
        print("   - Token salah/expired (run ulang aplikasi untuk token baru)")
        print("   - Internet tidak aktif")
        print("   - Service account key tidak valid")

def send_promo_notification():
    """Kirim notifikasi promo dengan navigasi"""
    
    # Initialize Firebase Admin
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred)
    except:
        pass
    
    message = messaging.Message(
        notification=messaging.Notification(
            title='🔥 PROMO HEMAT 5K!',
            body='Diskon Rp 5.000 untuk pembelian min Rp 10.000. Klik untuk lihat detail!',
        ),
        data={
            'type': 'promo',
            'promo_id': '1',  # ID promo HEMAT5K
        },
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                sound='hidupjokowi',
                channel_id='high_importance_channel',
            ),
        ),
        token=FCM_TOKEN,
    )
    
    try:
        response = messaging.send(message)
        print(f"\n✅ Notifikasi PROMO berhasil dikirim!")
        print(f"📨 Message ID: {response}")
        print(f"\n🎯 Klik notifikasi untuk langsung ke halaman promo!")
    except Exception as e:
        print(f"\n❌ Error: {e}")

def send_menu_notification():
    """Kirim notifikasi menu baru"""
    
    # Initialize Firebase Admin
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred)
    except:
        pass
    
    message = messaging.Message(
        notification=messaging.Notification(
            title='🍽️ Menu Baru!',
            body='Ada menu spesial hari ini! Lihat sekarang.',
        ),
        data={
            'type': 'menu',
        },
        token=FCM_TOKEN,
    )
    
    try:
        response = messaging.send(message)
        print(f"\n✅ Notifikasi MENU berhasil dikirim!")
        print(f"📨 Message ID: {response}")
    except Exception as e:
        print(f"\n❌ Error: {e}")

# ========================================
# MAIN MENU
# ========================================

if __name__ == "__main__":
    print("\n" + "="*60)
    print("🚀 FCM Test - Warteg Almera Notification Sender")
    print("="*60)
    
    print("\nPilih jenis notifikasi:")
    print("1. Test Notifikasi Sederhana")
    print("2. Notifikasi Promo (dengan navigasi)")
    print("3. Notifikasi Menu Baru")
    print("0. Exit")
    
    choice = input("\nPilihan (0-3): ").strip()
    
    if choice == "1":
        send_test_notification()
    elif choice == "2":
        send_promo_notification()
    elif choice == "3":
        send_menu_notification()
    elif choice == "0":
        print("Bye! 👋")
    else:
        print("❌ Pilihan tidak valid!")
    
    print("\n" + "="*60)
