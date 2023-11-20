#include <WiFi.h>
#include <PubSubClient.h>
#include <HardwareSerial.h>
#include <ArduinoJson.h>  

#define BAUD_RATE  115200

// USART2 Declaration
#define RX2            16
#define TX2            17

HardwareSerial SerialPort2(2);

// WiFi
const char *ssid     = "miska_moska";
const char *password = "agora_vai";

// MQTT Broker
const char *mqtt_broker   = "broker.emqx.io";
const char *topic         = "doseminder/dosage";
const char *mqtt_username = "emqx";
const char *mqtt_password = "public";
const int   mqtt_port     = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  // Set software and a hardware serial bridges;
  Serial.begin(BAUD_RATE);
  SerialPort2.begin(BAUD_RATE, SERIAL_8N1, RX2, TX2);
  delay(2000);

  // Connecting to a WiFi network
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the Wi-Fi network");

  // Connecting to a mqtt broker
  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);

  while (!client.connected()) {
    String client_id = "esp32-client-";
    client_id += String(WiFi.macAddress());
    Serial.printf("Client ID: %s\n", client_id.c_str());

    if (client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
      Serial.println("Public EMQX MQTT broker connected");
    } else {
      Serial.print("Failed with state: ");
      Serial.print(client.state());
      delay(2000);
    }
  }

  client.subscribe(topic);
}

void callback(char *topic, byte *payload, unsigned int length) {
  StaticJsonDocument<60> doc;
  DeserializationError error;

  byte data, dose, recipient;

  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
  Serial.print("Message:");
  for (int i = 0; i < length; i++) {
    Serial.print((char) payload[i]);
  }
  Serial.println();
  Serial.println("-----------------------");

  // Unmarshalling errors
  error = deserializeJson(doc, (char*) payload);
  if (error) {
    Serial.print("deserializeJson() failed: ");
    Serial.println(error.c_str());
    return;
  }

  dose = (byte) doc["dose"] << 3;
  recipient = doc["recipient"];
  data = dose + recipient;
  Serial2.write(data);
  Serial.printf("Serial transmission of %x: ", data);
}

void loop() {
  client.loop();
}