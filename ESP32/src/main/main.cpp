#include <Arduino.h>
#include <WiFi.h>
#include <httpProtocol.h>
#include <smartConfig.h> 
#include <WiFiClient.h>
#include <HTTPClient.h>
#include <HardwareSerial.h>
#include <ArduinoJson.h>
#include <main.h>
#include <iostream>

using namespace std;

HardwareSerial SerialPort(2);

char json[400] = { 0 };
uint8_t i = 0; 
unsigned long _time = 0;
unsigned long _time2 = 0;

float tempSPCurr;
float airSPCurr;
float humiSPCurr;
float lightSPCurr;

bool isGetSTMSP = false;

// Parse json thành object
StaticJsonDocument<400> stmJSON;
StaticJsonDocument<200> serverJSON;

void setup() {
  Serial.begin(115200);
  SerialPort.begin(9600, SERIAL_8N1, 16, 17); 

  pinMode(LED_ON_ACTIVE, OUTPUT);
  digitalWrite(LED_ON_ACTIVE, HIGH);

  // Smart config wifi và xác định địa chỉ IP của server
  wifiSmartConfig();
}

// To stm32
void backSetpoint() {
  String req = "http://" + server + "/get";

  String reqTempString = "{\"type\": \"Temp\", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";
  String reqAirString = "{\"type\": \"Air\", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";
  String reqHumiString = "{\"type\": \"Humi\", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";
  String reqLightString = "{\"type\": \"Light\", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";

  String resTempString = httpPOSTRequest(req, reqTempString);
  String resAirString = httpPOSTRequest(req, reqAirString);
  String resHumiString = httpPOSTRequest(req, reqHumiString);
  String resLightString = httpPOSTRequest(req, reqLightString);

  if (resTempString == "Unavailable" || resAirString == "Unavailable" || resHumiString == "Unavailable" || resLightString == "Unavailable") {
    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(500);
    digitalWrite(LED_ON_ACTIVE, HIGH);
    delay(3000);
    return;
  }

  if (stof(resTempString.c_str()) > 2 && abs(tempSPCurr - stof(resTempString.c_str())) > 0.9) {
    String msg = "t" + resTempString;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);

    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(2000);
    digitalWrite(LED_ON_ACTIVE, HIGH);
  }

  if (stof(resAirString.c_str()) > 2 && abs(airSPCurr - stof(resAirString.c_str())) > 0.9) {
    String msg = "a" + resAirString;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);
    
    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(2000);
    digitalWrite(LED_ON_ACTIVE, HIGH);
  }

  if (stof(resHumiString.c_str()) > 2 && abs(humiSPCurr - stof(resHumiString.c_str())) > 0.9) {
    String msg = "h" + resHumiString;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);

    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(2000);
    digitalWrite(LED_ON_ACTIVE, HIGH);
  }

  if (stof(resLightString.c_str()) > 2 && abs(lightSPCurr - stof(resLightString.c_str())) > 0.9) {
    String msg = "l" + resLightString;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);

    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(2000);
    digitalWrite(LED_ON_ACTIVE, HIGH);
  }
}

// To server
void postValue() {
  DeserializationError error = deserializeJson(stmJSON, json);

  if (error) {
    Serial.print("Post value failed: ");
    Serial.println(error.c_str());
  }

  tempSPCurr = stmJSON["TempSP"].as<float>();
  airSPCurr = stmJSON["AirSP"].as<float>();
  humiSPCurr = stmJSON["HumiSP"].as<float>();
  lightSPCurr = stmJSON["LightSP"].as<float>();

  String req = "http://" + server + "/post";

  String reqTempString = "{\"type\": \"Temp\",\"value\":" + String(stmJSON["Temp"].as<float>()) + ", \"isSP\": false,\"password\":\"" + serverPassword + "\" }";
  String reqAirString = "{\"type\": \"Air\",\"value\":" + String(stmJSON["Air"].as<float>()) + ", \"isSP\": false,\"password\":\"" + serverPassword + "\" }";
  String reqHumiString = "{\"type\": \"Humi\",\"value\":" + String(stmJSON["Humi"].as<float>()) + ", \"isSP\": false,\"password\":\"" + serverPassword + "\" }";
  String reqLightString = "{\"type\": \"Light\",\"value\":" + String(stmJSON["Light"].as<float>()) + ", \"isSP\": false,\"password\":\"" + serverPassword + "\" }";

  String resTempString = httpPOSTRequest(req, reqTempString);
  String resAirString = httpPOSTRequest(req, reqAirString);
  String resHumiString = httpPOSTRequest(req, reqHumiString);
  String resLightString = httpPOSTRequest(req, reqLightString);
}

// To server
void postSetpoint() {
  DeserializationError error = deserializeJson(stmJSON, json);

  if (error) {
    Serial.print("Post value failed: ");
    Serial.println(error.c_str());
  }

  tempSPCurr = stmJSON["TempSP"].as<float>();
  airSPCurr = stmJSON["AirSP"].as<float>();
  humiSPCurr = stmJSON["HumiSP"].as<float>();
  lightSPCurr = stmJSON["LightSP"].as<float>();

  String req = "http://" + server + "/post";

  String reqTempString = "{\"type\": \"Temp\",\"value\":" + String(tempSPCurr) + ", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";
  String reqAirString = "{\"type\": \"Air\",\"value\":" + String(airSPCurr) + ", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";
  String reqHumiString = "{\"type\": \"Humi\",\"value\":" + String(humiSPCurr) + ", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";
  String reqLightString = "{\"type\": \"Light\",\"value\":" + String(lightSPCurr) + ", \"isSP\": true,\"password\":\"" + serverPassword + "\" }";

  String resTempString = httpPOSTRequest(req, reqTempString);
  String resAirString = httpPOSTRequest(req, reqAirString);
  String resHumiString = httpPOSTRequest(req, reqHumiString);
  String resLightString = httpPOSTRequest(req, reqLightString);

  if (resTempString == "Unavailable" || resAirString == "Unavailable" || resHumiString == "Unavailable" || resLightString == "Unavailable") {
    digitalWrite(LED_ON_ACTIVE, LOW);
    delay(500);
    digitalWrite(LED_ON_ACTIVE, HIGH);
    delay(3000);
    return;
  }

  SerialPort.write('1');
}

void loop() {
  if (SerialPort.available()) {
    char c = SerialPort.read();
    if (c == '#') {
      postValue();
      i = 0;
      for (int i = 0; i < 400; i++) {
        json[i] = '\0';
      }
      return;
    }
    if (c == '@') {
      postSetpoint();
      i = 0;
      for (int i = 0; i < 400; i++) {
        json[i] = '\0';
      }
      return;
    }
    json[i++] = c;
    Serial.print(c);
    return;
  }
  if (millis() - _time > 1000) {
    _time = millis();
    backSetpoint();
  }
}