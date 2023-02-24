#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClient.h>
#include <HTTPClient.h>
#include <HardwareSerial.h>
#include <ArduinoJson.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

HardwareSerial SerialPort(2);

const char* ssid = "Anh Vien Ngoc Ha";
const char* password = "0914255717";

char json[200];
uint8_t i = 0; 
unsigned long _time = 0;
unsigned long _time2 = 0;

float tempSPCurr;
float airSPCurr;
float humiSPCurr;
float lightSPCurr;

StaticJsonDocument<400> document;
StaticJsonDocument<4000> document2;

String httpGETRequest(String serverName);

void backData();

// Post data from STM to thingspeak, merge data from STM to ESP
void postData() {
  char buf[20];

  DeserializationError error = deserializeJson(document, json);

  String request = "https://api.thingspeak.com/update?key=3SKAWGZH32NSTQ33";
  String temp = document["Temp"].as<uint8_t>() == 0 ? "" : ("&field1=" + document["Temp"].as<String>());
  String air = document["Air"].as<uint8_t>() == 0 ? "" : ("&field2=" + document["Air"].as<String>());
  String humi = document["Humi"].as<uint8_t>() == 0 ? "" : ("&field3=" + document["Humi"].as<String>());
  String light = document["Light"].as<uint8_t>() == 0 ? "" : ("&field4=" + document["Light"].as<String>());

  String tempSP = document["TempSP"].as<uint8_t>() == 0 ? "" : ("&field5=" + document["TempSP"].as<String>());
  String airSP = document["AirSP"].as<uint8_t>() == 0 ? "" : ("&field6=" + document["AirSP"].as<String>());
  String humiSP = document["HumiSP"].as<uint8_t>() == 0 ? "" : ("&field7=" + document["HumiSP"].as<String>());
  String lightSP = document["LightSP"].as<uint8_t>() == 0 ? "" : ("&field8=" + document["LightSP"].as<String>());

  request = request + tempSP + temp + airSP + air + humiSP + humi + lightSP + light;

  if (millis() - _time2 > 100000) {
    _time2 = millis();
    httpGETRequest(request);
  }

  tempSPCurr = document["TempSP"].as<float>();
  airSPCurr = document["AirSP"].as<float>();
  humiSPCurr = document["HumiSP"].as<float>();
  lightSPCurr = document["LightSP"].as<float>();
}

// Check if setpoint complete update from STM to thingspeak
void checkUpdateData() {
  String jsonCheck = httpGETRequest("https://api.thingspeak.com/channels/2010355/feeds.json?api_key=Z44QT5NIMCCUG96X&results=10");
  DeserializationError error2 = deserializeJson(document2, jsonCheck);

  JsonArray feeds = document2["feeds"].as<JsonArray>();

  float tempSP;
  float airSP;
  float humiSP;
  float lightSP;

  for (int i = 0; i < 10; i++) {
    if (feeds[i]["field5"].as<float>() > 5) {
      tempSP = feeds[i]["field5"].as<float>();
    }
    if (feeds[i]["field6"].as<float>() > 5) {
      airSP = feeds[i]["field6"].as<float>();
    }
    if (feeds[i]["field7"].as<float>() > 5) {
      humiSP = feeds[i]["field7"].as<float>();
    }
    if (feeds[i]["field8"].as<float>() > 5) {
      lightSP = feeds[i]["field8"].as<float>();
    }
  }

  if (tempSP > 5 && abs(tempSPCurr - tempSP) > 0.9) {
    delay(2000);
    checkUpdateData();
    return;
  }
  if (airSP > 5 && abs(airSPCurr - airSP) > 0.9) {
    delay(2000);
    checkUpdateData();
    return;
  }
  if (humiSP > 5 && abs(humiSPCurr - humiSP) > 0.9) {
    delay(2000);
    checkUpdateData();
    return;
  }
  if (lightSP > 5 && abs(lightSPCurr - lightSP) > 0.9) {
    delay(2000);
    checkUpdateData();
    return;
  }
  Serial.println("Complete update");
}

// Update setpoint from STM to thingspeak
void updateData() {
  char buf[20];

  DeserializationError error = deserializeJson(document, json);

  String request = "https://api.thingspeak.com/update?key=3SKAWGZH32NSTQ33";
  
  String temp = document["TempSP"].as<uint8_t>() == 0 ? "" : ("&field5=" + document["TempSP"].as<String>());
  String air = document["AirSP"].as<uint8_t>() == 0 ? "" : ("&field6=" + document["AirSP"].as<String>());
  String humi = document["HumiSP"].as<uint8_t>() == 0 ? "" : ("&field7=" + document["HumiSP"].as<String>());
  String light = document["LightSP"].as<uint8_t>() == 0 ? "" : ("&field8=" + document["LightSP"].as<String>());

  tempSPCurr = document["TempSP"].as<float>();
  airSPCurr = document["AirSP"].as<float>();
  humiSPCurr = document["HumiSP"].as<float>();
  lightSPCurr = document["LightSP"].as<float>();

  if (millis() - _time2 > 20000) {
    _time2 = millis();
   
    request = request + temp + air + humi + light;
    String res = httpGETRequest(request);

    checkUpdateData();

    SerialPort.write(res == "0" ? '0' : '1');
  }
}

// Merge data from thingspeak to STM
void backData() {
  String jsonCheck = httpGETRequest("https://api.thingspeak.com/channels/2010355/feeds.json?api_key=Z44QT5NIMCCUG96X&results=10");
  DeserializationError error2 = deserializeJson(document2, jsonCheck);

  JsonArray feeds = document2["feeds"].as<JsonArray>();

  float tempSP;
  float airSP;
  float humiSP;
  float lightSP;
  
  for (int i = 0; i < 10; i++) {
    if (feeds[i]["field5"].as<float>() > 5) {
      tempSP = feeds[i]["field5"].as<float>();
    }
    if (feeds[i]["field6"].as<float>() > 5) {
      airSP = feeds[i]["field6"].as<float>();
    }
    if (feeds[i]["field7"].as<float>() > 5) {
      humiSP = feeds[i]["field7"].as<float>();
    }
    if (feeds[i]["field8"].as<float>() > 5) {
      lightSP = feeds[i]["field8"].as<float>();
    }
  }

  if (tempSP < 2 || airSP < 2 || humiSP < 2 || lightSP < 2) {
    delay(2000);
    backData();
  }

  if (tempSP > 2 && abs(tempSPCurr - tempSP) > 0.9) {
    String msg = "t" + (String)tempSP;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);

    delay(2000);
  }

  if (airSP > 2 && abs(airSPCurr - airSP) > 0.9) {
    String msg = "a" + (String)airSP;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);

    delay(2000);
  }
  
  if (humiSP > 2 && abs(humiSPCurr - humiSP) > 0.9) {
    String msg = "h" + (String)humiSP;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);

    delay(2000);
  }
  
  if (lightSP > 2 && abs(lightSPCurr - lightSP) > 0.9) {
    String msg = "l" + (String)lightSP;
    for (int i = 0; i < msg.length(); i++) {
      SerialPort.write(msg[i]);
    }
    Serial.print(msg);
  }
}

void setup() {
  Serial.begin(9600);
  SerialPort.begin(9600, SERIAL_8N1, 16, 17); 

  WiFi.disconnect();
  WiFi.begin(ssid, password);
  Serial.println("Connecting");
  while(WiFi.status() != WL_CONNECTED) { 
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("Connected to WiFi network with IP Address: ");

  backData();
}

void loop() {
  // Serial.print("onCheck");
  if (SerialPort.available()) {
    char c = SerialPort.read();
    if (c == '#') {
      postData();
      i = 0;
      for (int i = 0; i < 200; i++) {
        json[i] = '\0';
      }
      return;
    }
    if (c == '@') {
      updateData();
      i = 0;
      for (int i = 0; i < 200; i++) {
        json[i] = '\0';
      }
      return;
    }
    json[i++] = c;
    Serial.print(c);
  }
  if (millis() - _time > 1000 && json[0] == '\0') {
    _time = millis();
    backData();
  }
}

String httpGETRequest(String serverName) {
  HTTPClient http;
    
  // Your IP address with path or Domain name with URL path 
  Serial.println(serverName);
  http.begin(serverName);
  
  // Send HTTP POST request
  int httpResponseCode = http.GET();
  
  String payload = "--"; 
  
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    payload = http.getString();
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  // Free resources
  http.end();

  return payload;
}

// void setup(){
  // WiFi.disconnect();
  // WiFi.begin(ssid, password);
  // Serial.println("Connecting");
  // while(WiFi.status() != WL_CONNECTED) { 
  //   delay(500);
  //   Serial.print(".");
  // }
  // Serial.println("");
  // Serial.print("Connected to WiFi network with IP Address: ");
// }

// void loop(){
// //  https://api.thingspeak.com/update?api_key=YRQF26JX5T2PM0C8&field{i}={value}  // Write field
// //  https://api.thingspeak.com/channels/2010355/fields/1.json?api_key=Z44QT5NIMCCUG96X&results={timeCount} // Read field

//   String request = "https://api.thingspeak.com/update?key=YRQF26JX5T2PM0C8&field1=";
//   request += random(50);
//   httpGETRequest(request);
//   delay(500);
// }