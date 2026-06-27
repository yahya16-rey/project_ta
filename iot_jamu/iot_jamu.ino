#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <RTClib.h>

// Provide the token generation process info.
#include "addons/TokenHelper.h"

// ========================================================
// 1. Kredensial WiFi
// ========================================================
#define WIFI_SSID "NAMA_WIFI_ANDA"
#define WIFI_PASSWORD "PASSWORD_WIFI_ANDA"

// ========================================================
// 2. Kredensial Firebase
// Dapatkan API_KEY dan PROJECT_ID dari Firebase Console
// (Project Settings -> General)
// ========================================================
#define API_KEY "AIzaSyAQTP3TyLYXCWybZUzwz4OmydQeC5RNbrs"
#define PROJECT_ID "project-ta-c6051"

// ========================================================
// 3. Konfigurasi Pin Hardware
// ========================================================
// LCD I2C
LiquidCrystal_I2C lcd(0x27, 16, 2);

// DS18B20
#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// RTC
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
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
bool motorState = false; // Status awal motor mati (OFF)
bool isManualOverride = false; // Flag jika tombol fisik baru saja ditekan

void setup() {
  Serial.begin(115200);

  // Inisialisasi Pin
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  
  // Menggunakan internal pull-up untuk tombol (aman)
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
    Serial.println("Warning: RTC tidak ditemukan!");
  }

  // Koneksi WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Menghubungkan ke Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println();
  Serial.print("Terhubung! IP: ");
  Serial.println(WiFi.localIP());

  // Inisialisasi Firebase
  config.api_key = API_KEY;
  // Login secara anonim (karena Firebase Rules Flutter app Anda sudah "if true")
  auth.user.email = "";
  auth.user.password = "";
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sistem Siap!");
  delay(2000);
}

void loop() {
  // --------------------------------------------------------
  // A. BACA TOMBOL FISIK
  // --------------------------------------------------------
  // Karena pakai INPUT_PULLUP, saat ditekan nilainya LOW
  if (digitalRead(BTN_START) == LOW) {
    motorState = true;
    isManualOverride = true; // Tandai bahwa kita mengatur manual lewat tombol
    delay(200); // debounce sederhana
  }
  if (digitalRead(BTN_STOP) == LOW) {
    motorState = false;
    isManualOverride = true;
    delay(200); // debounce sederhana
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
  // --------------------------------------------------------
  if (Firebase.ready() && (millis() - sendDataPrevMillis > 3000 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();
    String documentPath = "monitoring/boiler";

    // 1. Baca instruksi On/Off dari Aplikasi Flutter terlebih dahulu
    //    (Kecuali tombol fisik baru saja ditekan, kita utamakan tombol fisik)
    if (!isManualOverride) {
      if (Firebase.Firestore.getDocument(&fbdo, PROJECT_ID, "", documentPath.c_str(), "")) {
        FirebaseJson payload;
        payload.setJsonData(fbdo.payload().c_str());
        FirebaseJsonData result;
        payload.get(result, "fields/status/stringValue");
        
        if (result.success) {
          String appStatus = result.stringValue;
          if (appStatus == "NORMAL") motorState = true;
          else if (appStatus == "OFF") motorState = false;
        }
      }
    } else {
      // Reset flag override agar di siklus berikutnya bisa membaca instruksi dari aplikasi lagi
      isManualOverride = false;
    }

    // 2. Baca Suhu & Waktu
    sensors.requestTemperatures();
    float suhu = sensors.getTempCByIndex(0);
    DateTime now = rtc.now();

    // 3. Tampilkan di LCD I2C
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("T:");
    lcd.print(suhu, 1);
    lcd.print((char)223); // Simbol Derajat
    lcd.print("C  ");
    lcd.print(motorState ? "ON " : "OFF");

    lcd.setCursor(0, 1);
    char timeStr[10];
    sprintf(timeStr, "%02d:%02d:%02d", now.hour(), now.minute(), now.second());
    lcd.print(timeStr);

    // 4. Kirim Suhu & Status terbaru ke Firestore
    FirebaseJson content;
    content.set("fields/temperature/doubleValue", suhu);
    content.set("fields/status/stringValue", motorState ? "NORMAL" : "OFF");
    
    Serial.print("Update Suhu (");
    Serial.print(suhu);
    Serial.print("C) ke Firestore... ");
    
    // patchDocument akan memperbarui atau membuat dokumen jika belum ada
    if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", documentPath.c_str(), content.raw(), "temperature,status")) {
      Serial.println("Berhasil!");
    } else {
      Serial.println("Gagal: " + fbdo.errorReason());
    }
  }
}
