#include <httpProtocol.h>
#include <main.h>

// GET request HTTP
String httpGETRequest(String serverName) {
  HTTPClient http;
    
  // Your IP address with path or Domain name with URL path 
  Serial.println(serverName);
  http.begin(serverName);
  
  // Send HTTP GET request
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

// POST request HTTP
String httpPOSTRequest(String serverName, String param) {
  HTTPClient http;
    
  // Your IP address with path or Domain name with URL path 
  Serial.println(serverName);
  
  http.begin(serverName);
  http.addHeader("Content-Type", "application/json");

  digitalWrite(LED_ON_REQUEST, HIGH);
  // Send HTTP POST request
  int httpResponseCode = http.POST(param);
  digitalWrite(LED_ON_REQUEST, LOW);

  Serial.println(param);
  
  String payload = "Unavailable"; 
  
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