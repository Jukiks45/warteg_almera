"""
FCM Push Notification Sender - Python Example
==============================================

Script untuk mengirim push notification FCM ke Flutter app.
Cocok untuk backend/server-side implementation.

Requirements:
    pip install requests

Usage:
    python send_fcm_notification.py
"""

import requests
import json

# ==================== CONFIGURATION ====================
# Dapatkan dari Firebase Console → Project Settings → Cloud Messaging
FCM_SERVER_KEY = "YOUR_FCM_SERVER_KEY_HERE"

# FCM Token dari device (lihat di console Flutter app)
DEVICE_TOKEN = "DEVICE_FCM_TOKEN_HERE"

FCM_URL = "https://fcm.googleapis.com/fcm/send"
# =======================================================


def send_promo_notification(
    token: str,
    title: str,
    body: str,
    promo_id: str = None,
    promo_type: str = "promo"
):
    """
    Kirim notifikasi promo ke device
    
    Args:
        token: FCM token device
        title: Judul notifikasi
        body: Isi notifikasi
        promo_id: ID promo spesifik (optional, jika kosong akan ke list promo)
        promo_type: Tipe notifikasi (default: "promo")
    """
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"key={FCM_SERVER_KEY}"
    }
    
    # Data payload untuk navigasi
    data = {
        "type": promo_type
    }
    
    if promo_id:
        data["promo_id"] = promo_id
    
    payload = {
        "to": token,
        "notification": {
            "title": title,
            "body": body,
            "sound": "hidupjokowi",  # Custom sound (optional)
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "priority": "high"
        },
        "data": data,
        "priority": "high"
    }
    
    try:
        response = requests.post(FCM_URL, headers=headers, data=json.dumps(payload))
        response.raise_for_status()
        
        result = response.json()
        print(f"✅ Notifikasi berhasil dikirim!")
        print(f"Response: {json.dumps(result, indent=2)}")
        return result
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Error mengirim notifikasi: {e}")
        if hasattr(e.response, 'text'):
            print(f"Response: {e.response.text}")
        return None


def send_order_notification(token: str, order_id: str, status: str):
    """Kirim notifikasi update order"""
    
    status_messages = {
        "processing": "Pesanan Anda sedang diproses",
        "cooking": "Pesanan Anda sedang dimasak",
        "delivery": "Pesanan Anda sedang diantar",
        "completed": "Pesanan Anda telah selesai"
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"key={FCM_SERVER_KEY}"
    }
    
    payload = {
        "to": token,
        "notification": {
            "title": "Update Pesanan",
            "body": status_messages.get(status, "Status pesanan berubah"),
            "sound": "hidupjokowi"
        },
        "data": {
            "type": "order",
            "order_id": order_id,
            "status": status
        },
        "priority": "high"
    }
    
    try:
        response = requests.post(FCM_URL, headers=headers, data=json.dumps(payload))
        response.raise_for_status()
        print(f"✅ Notifikasi order berhasil dikirim!")
        return response.json()
    except Exception as e:
        print(f"❌ Error: {e}")
        return None


def send_bulk_notification(tokens: list, title: str, body: str, data: dict = None):
    """
    Kirim notifikasi ke multiple devices
    
    Args:
        tokens: List of FCM tokens
        title: Judul notifikasi
        body: Isi notifikasi
        data: Custom data payload
    """
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"key={FCM_SERVER_KEY}"
    }
    
    payload = {
        "registration_ids": tokens,  # Multiple tokens
        "notification": {
            "title": title,
            "body": body,
            "sound": "hidupjokowi"
        },
        "data": data or {"type": "promo"},
        "priority": "high"
    }
    
    try:
        response = requests.post(FCM_URL, headers=headers, data=json.dumps(payload))
        response.raise_for_status()
        
        result = response.json()
        success_count = result.get('success', 0)
        failure_count = result.get('failure', 0)
        
        print(f"✅ Notifikasi bulk berhasil!")
        print(f"   Success: {success_count}")
        print(f"   Failed: {failure_count}")
        
        return result
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return None


# ==================== CONTOH PENGGUNAAN ====================

if __name__ == "__main__":
    print("=" * 60)
    print("FCM Push Notification Sender")
    print("=" * 60)
    
    # Contoh 1: Kirim notifikasi promo umum (ke list promo)
    print("\n1. Mengirim notifikasi promo umum...")
    send_promo_notification(
        token=DEVICE_TOKEN,
        title="🎉 Promo Spesial Hari Ini!",
        body="Lihat semua promo menarik yang tersedia untuk Anda"
    )
    
    # Contoh 2: Kirim notifikasi promo spesifik (ke detail promo)
    print("\n2. Mengirim notifikasi promo spesifik...")
    send_promo_notification(
        token=DEVICE_TOKEN,
        title="🔥 Diskon 50% Menu Spesial!",
        body="Gunakan kode SPESIAL50 untuk diskon hingga 50%",
        promo_id="1"  # ID promo spesifik
    )
    
    # Contoh 3: Kirim notifikasi order
    print("\n3. Mengirim notifikasi update order...")
    send_order_notification(
        token=DEVICE_TOKEN,
        order_id="12345",
        status="delivery"
    )
    
    # Contoh 4: Kirim ke multiple devices
    print("\n4. Mengirim ke multiple devices...")
    # send_bulk_notification(
    #     tokens=[DEVICE_TOKEN, "token2", "token3"],
    #     title="Promo Weekend!",
    #     body="Nikmati promo weekend spesial",
    #     data={"type": "promo"}
    # )
    
    print("\n" + "=" * 60)
    print("Selesai!")
    print("=" * 60)
