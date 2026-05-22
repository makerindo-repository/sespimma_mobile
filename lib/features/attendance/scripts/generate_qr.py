import qrcode
import json
import os

def generate_attendance_qr(zone_id, activity_name):
    data = {
        "type": "attendance_sespimma",
        "zoneId": zone_id,
        "activity": activity_name,
        "secret": "SESPIMMA-2026-MAKERINDO"
    }
    
    qr_data = json.dumps(data)
    
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(qr_data)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    
    # Save image
    filename = f"qr_{zone_id}.png"
    img.save(filename)
    
    print(f"✅ QR Code generated successfully: {filename}")
    print(f"📄 Data content: {qr_data}")
    print(f"📌 Path: {os.path.abspath(filename)}")

if __name__ == "__main__":
    generate_attendance_qr("zone_apel_makerindo", "Apel Pagi")
