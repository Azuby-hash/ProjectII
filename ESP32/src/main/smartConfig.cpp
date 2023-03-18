#include "WiFi.h"
#include "httpProtocol.h"
#include "string.h"
#include "main.h"

String server;

RTC_DATA_ATTR uint8_t rvd_data[33] = "192.168.1.86:3000"; // IP server
RTC_DATA_ATTR uint8_t ssid[33] = "Tang 2"; // Ten WiFi
RTC_DATA_ATTR uint8_t password[65] = "long12345"; // Password Wifi

String serverPassword = "9797964a-2f5c-41c6-91c1-44aa68308631";

unsigned long _time3 = 0;

void wifiSmartConfig();

// Handle WiFi cho từng giai đoạn
void wiFiEvent(WiFiEvent_t event, WiFiEventInfo_t info)
{
  Serial.printf("[WiFi-event] event: %d\n", event);

  switch (event) {

      case ARDUINO_EVENT_SC_SCAN_DONE:
      {
          Serial.println("Scan done");
      }
      break;

      case ARDUINO_EVENT_SC_FOUND_CHANNEL:
      {
          Serial.println("Found channel");

      }
      break;

      case ARDUINO_EVENT_SC_GOT_SSID_PSWD:
      {
        Serial.println("Got SSID and password");

        memcpy(ssid, info.sc_got_ssid_pswd.ssid, sizeof(info.sc_got_ssid_pswd.ssid));
        memcpy(password, info.sc_got_ssid_pswd.password, sizeof(info.sc_got_ssid_pswd.password));

        Serial.printf("SSID:%s\n", ssid);
        Serial.printf("PASSWORD:%s\n", password);

        if (info.sc_got_ssid_pswd.type == SC_TYPE_ESPTOUCH_V2) {
          ESP_ERROR_CHECK( esp_smartconfig_get_rvd_data(rvd_data, sizeof(rvd_data)) );

          Serial.println("RVD_DATA");
          Serial.write(rvd_data, 33);
          Serial.printf("\n");

          for (int i = 0; i < 33; i++) {
              Serial.printf("%02x ", rvd_data[i]);
          }
          Serial.printf("\n");
        }
      }
      break;

      case ARDUINO_EVENT_SC_SEND_ACK_DONE:
      {
        Serial.println("SC_EVENT_SEND_ACK_DONE");
      }
      break;

      default:
      {
        Serial.printf("no case event: %d\n", event);
      }
      break;
  }
}

// Config IP server 
void serverHostConfig() {
  Serial.println("WiFi Connected.");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  // WiFi.stopSmartConfig();

  String ip = "";

  // Loại bỏ kí tự thừa trong rvd_data và gán vào biến ip
  for (int i = 0; i < sizeof(rvd_data); i++) { 
    if ((rvd_data[i] >= 0x30 && rvd_data[i] <= 0x39) || rvd_data[i] == (char)'.' || rvd_data[i] == (char)':') {
      ip = ip + (char)rvd_data[i];
    }
  }
  Serial.println(ip);

  // Request để test xem IP gửi về rvd_data có đúng không
  String rq = "http://" + ip + "/espConfig";
  String res = httpPOSTRequest(rq, "{\"password\":\"" + serverPassword + "\"}");

  if (res == serverPassword) {
    // Nếu đúng nháy đèn D2 2 phát và lưu vào biến server

    server = ip;
    Serial.println(rq);
    Serial.println("Config done!");
    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(500);
    digitalWrite(LED_ON_ACTIVE, HIGH);
    delay(500);
    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(500);
    digitalWrite(LED_ON_ACTIVE, HIGH);
    return;
  }
  // Nếu sai nháy đèn D2 1 phát và kiểm tra lại

  digitalWrite(LED_ON_ACTIVE, LOW);
  delay(500);
  digitalWrite(LED_ON_ACTIVE, HIGH);
  delay(2000);

  serverHostConfig();
}

void wifiSmartConfig() {
  WiFi.mode(WIFI_AP_STA);
  WiFi.onEvent(wiFiEvent);

  // // Kiểm tra xem tên và pass WiFi có lưu trong bộ nhớ RTC(sleep and wake) không
  // if (ssid[0] != '\0' || password[0] != '\0') {
  //   // Nếu có thì thử kết nối trong 3s, nếu 3s không kết nối đc thì bắt đầu smart config
  //   WiFi.begin((char *)ssid, (char *)password);
  //   while (_time3 < 8000) {
  //     if (WiFi.status() == WL_CONNECTED) {
  //       delay(500);
  //       serverHostConfig();
  //       return;
  //     }
  //     _time3 += 500;
  //     delay(500);
  //     Serial.print(".");
  //   }
  //   digitalWrite(LED_ON_ACTIVE, LOW);
  //   return;
  // }
  // // Nếu không thì smart config

  // /* start SmartConfig */
  // WiFi.beginSmartConfig(SC_TYPE_ESPTOUCH_V2, (char *)"0000000000000000");
 
  // /* Wait for SmartConfig packet from mobile */
  // Serial.println("Waiting for SmartConfig.");
  // while (!WiFi.smartConfigDone()) {
  //   delay(500);
  //   Serial.print(".");
  // }
  // Serial.println("");
  // Serial.println("SmartConfig done.");
 
  WiFi.begin((char *)ssid,(char *)password);

  /* Wait for WiFi to connect to AP */
  Serial.println("Waiting for WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  serverHostConfig();
}