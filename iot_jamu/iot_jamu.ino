#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <RTClib.h>

// ========================================================
// 1. Kredensial WiFi
// ========================================================
#define WIFI_SSID "SOEDARA NGOPI"
#define WIFI_PASSWORD "silakanpesandulu"

// ========================================================
// 2. Kredensial Firebase
// ========================================================
#define API_KEY "AIzaSyAQTP3TyLYXCWybZUzwz4OmydQeC5RNbrs"
#define PROJECT_ID "project-ta-c6051"

// ========================================================
// 3. Konfigurasi Pin Hardware
// ========================================================
LiquidCrystal_I2C lcd(0x27, 16, 2);

#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

RTC_DS3231 rtc;

// L298N (Motor Pengaduk)
#define ENA 25
#define IN1 26
#define IN2 27

// Tombol Fisik
#define BTN_START 18
#define BTN_STOP 19

// ========================================================
// 4. Objek & Variabel Global Firebase
// ========================================================
FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

unsigned long sendDataPrevMillis = 0;
bool motorState = false;
bool isManualOverride = false;

void setup() {
    Serial.begin(115200);
    delay(1000);
    Serial.println("\n=================================");
    Serial.println("   SISTEM MONITORING BOILER BOOT  ");
    Serial.println("=================================");

    // Inisialisasi Pin Hardware
    pinMode(ENA, OUTPUT);
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
    pinMode(BTN_START, INPUT_PULLUP);
    pinMode(BTN_STOP, INPUT_PULLUP);

    // Inisialisasi I2C & LCD
    Wire.begin(21, 22);
    lcd.init();
    lcd.backlight();
    lcd.setCursor(0, 0);
    lcd.print("Menghubungkan...");
    lcd.setCursor(0, 1);
    lcd.print("WiFi & Firebase");

    // Inisialisasi Sensor
    sensors.begin();
    if (!rtc.begin()) {
        Serial.println("[WARN] RTC tidak ditemukan atau tidak berjalan!");
    } else {
        Serial.println("[INFO] RTC Terdeteksi.");
    }

    // Koneksi WiFi
    Serial.print("[WIFI] Menghubungkan ke SSID: ");
    Serial.println(WIFI_SSID);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    while (WiFi.status() != WL_CONNECTED) {
        Serial.print(".");
        delay(500);
    }
    Serial.println();
    Serial.println("[WIFI] Terhubung Berhasil! ");
    Serial.print("[WIFI] IP Address: ");
    Serial.println(WiFi.localIP());

    // Inisialisasi Kredensial Firebase
    Serial.println("[FIREBASE] Mengonfigurasi Kredensial...");
    config.api_key = API_KEY;
    config.database_url = "https://project-ta-c6051-default-rtdb.asia-southeast1.firebasedatabase.app/";

    // Bypass Firebase Authentication agar bisa langsung akses Firestore
    config.signer.test_mode = true;

    // Matikan token status callback agar TokenHelper bawaan tidak ikut campur dan memicu error -127
    config.token_status_callback = NULL;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Sistem Siap!");
    Serial.println("[SYSTEM] Setup selesai. Memulai loop...\n");
    delay(2000);
}

void loop() {
    // --------------------------------------------------------
    // A. BACA TOMBOL FISIK
    // --------------------------------------------------------
    if (digitalRead(BTN_START) == LOW) {
        motorState = true;
        isManualOverride = true;
        Serial.println("[INPUT] Tombol START ditekan -> Motor ON (Manual Override)");
        delay(200);
    }
    if (digitalRead(BTN_STOP) == LOW) {
        motorState = false;
        isManualOverride = true;
        Serial.println("[INPUT] Tombol STOP ditekan -> Motor OFF (Manual Override)");
        delay(200);
    }

    // --------------------------------------------------------
    // B. KONTROL MOTOR L298N
    // --------------------------------------------------------
    if (motorState) {
        digitalWrite(ENA, HIGH);
        digitalWrite(IN1, HIGH);
        digitalWrite(IN2, LOW);
    } else {
        digitalWrite(ENA, LOW);
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, LOW);
    }

    // --------------------------------------------------------
    // C. UPDATE & BACA DARI FIREBASE (Tiap 3 Detik)
    // BYPASS: Menggunakan WiFi.status(), tidak peduli dengan token status!
    // --------------------------------------------------------
    if ((WiFi.status() == WL_CONNECTED) && (millis() - sendDataPrevMillis > 3000 || sendDataPrevMillis == 0)) {
        sendDataPrevMillis = millis();
        String documentPath = "monitoring/boiler";

        Serial.println("\n--------------------------------------------------");
        Serial.println("[API] Memulai siklus sinkronisasi Firestore... (Bypass Mode)");

        // 1. Ambil Instruksi dari Firestore
        if (!isManualOverride) {
            Serial.println("[API REST] GET data dari Firestore... ");
            if (Firebase.Firestore.getDocument(&fbdo, PROJECT_ID, "", documentPath.c_str(), "")) {
                Serial.println("[API REST] GET Berhasil! Memparsing payload...");

                FirebaseJson payload;
                payload.setJsonData(fbdo.payload().c_str());
                FirebaseJsonData result;
                payload.get(result, "fields/status/stringValue");

                if (result.success) {
                    String appStatus = result.stringValue;
                    Serial.print("[DATA] Status dari Aplikasi Flutter: ");
                    Serial.println(appStatus);

                    if (appStatus == "NORMAL") motorState = true;
                    else if (appStatus == "OFF") motorState = false;
                } else {
                    Serial.println("[WARN] Gagal memparsing data. Kemungkinan field 'status' belum ada di Firestore.");
                }
            } else {
                Serial.print("[ERROR] GET data gagal. Alasan: ");
                // Jika rules sudah "if true", respon ini akan tetap memproses data walau token error
                Serial.print(fbdo.errorReason());
                Serial.print(" | HTTP CODE: ");
                Serial.println(fbdo.httpCode());
            }
        } else {
            Serial.println("[INFO] Siklus GET dilewati karena status sedang di-override tombol fisik.");
            isManualOverride = false;
        }

        // 2. Baca Suhu & Waktu dari Hardware
        sensors.requestTemperatures();
        float suhu = sensors.getTempCByIndex(0);
        DateTime now = rtc.now();

        // 3. Tampilkan di LCD I2C
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("T:");
        lcd.print(suhu, 1);
        lcd.print((char)223);
        lcd.print("C  ");
        lcd.print(motorState ? "ON " : "OFF");

        lcd.setCursor(0, 1);
        char timeStr[10];
        sprintf(timeStr, "%02d:%02d:%02d", now.hour(), now.minute(), now.second());
        lcd.print(timeStr);

        // 4. Kirim (PATCH) Data Suhu & Motor ke Firestore
        FirebaseJson content;
        content.set("fields/temperature/doubleValue", (double)suhu);
        content.set("fields/status/stringValue", motorState ? "NORMAL" : "OFF");

        Serial.print("[API REST] PATCH data ke Firestore... ");

        if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", documentPath.c_str(), content.raw(), "temperature,status")) {
            Serial.println("BERHASIL DIKIRIM!");
            Serial.print("[SERVER RESPONSE]: ");
            Serial.println(fbdo.payload().c_str());
        } else {
            Serial.print("GAGAL! Alasan: ");
            Serial.print(fbdo.errorReason());
            Serial.print(" | HTTP CODE: ");
            Serial.println(fbdo.httpCode());
        }
        Serial.println("--------------------------------------------------");
    }
}