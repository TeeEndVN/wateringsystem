#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <Servo.h>

#define ssid "Bo"
#define password "haibang161020"
#define mqtt_server "maqiatto.com"
const int mqtt_port = 1883;
const int DHTPIN = 10;
const int DHTTYPE = DHT11;
const int ROOFPIN_1 = 14;
const int ROOFPIN_2 = 12;
const int PUMPPIN = 15;
const int LIGHTPIN = 13;
const int MOISTUREPIN = A0;

unsigned long t;
unsigned long pumpStart;
int pumpTimer;
bool light = false;
bool roof = false;
bool roofFlag = false;

DHT dht(DHTPIN, DHTTYPE);
WiFiClient espClient;
PubSubClient client(espClient);
Servo servo1;
Servo servo2;

void setup()
{
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  dht.begin();
  servo1.attach(ROOFPIN_1);
  servo2.attach(ROOFPIN_2);
  pinMode(PUMPPIN, OUTPUT);
  pinMode(LIGHTPIN, OUTPUT);
  pinMode(MOISTUREPIN, INPUT);
}
// Hàm kết nối wifi
void setup_wifi()
{
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void lightControl(String msg) {
  if (msg == "On") {
    light = true;
    client.publish("shipangei00@gmail.com/lightstat", "On", true);
  }
  else {
    light = false;
    client.publish("shipangei00@gmail.com/lightstat", "Off", true);
  }
}

void roofControl(String msg) {
  if (msg == "Open") {
    roof = true;
    client.publish("shipangei00@gmail.com/roofstat", "Open", true);
  }
  else {
    roof = false;
    client.publish("shipangei00@gmail.com/roofstat", "Closed", true);
  }
}

void pumpControl(String msg) {
  pumpStart = millis();
  pumpTimer = msg.toInt();
  if (pumpTimer <= 0) {
    pumpTimer = 0;
    client.publish("shipangei00@gmail.com/pumpstat", "Off", true);
  }
  else  client.publish("shipangei00@gmail.com/pumpstat", "On", true);
}

void callback(char* topic, byte* payload, unsigned int length)
{
  Serial.print("Co tin nhan moi tu topic:");
  Serial.println(topic);
  String msg = "";
  for (int i = 0; i < length; i++)
  {
    Serial.print((char)payload[i]);
    msg += (char)payload[i];
  }
  Serial.println();

  if ((String)topic == "shipangei00@gmail.com/light")
    lightControl(msg);
  else if ((String)topic == "shipangei00@gmail.com/roof")
    roofControl(msg);
  else if ((String)topic == "shipangei00@gmail.com/pump")
    pumpControl(msg);
}


void reconnect()
{
  while (!client.connected())
  {
    if (client.connect("ESP8266", "shipangei00@gmail.com", "!n&$NoF4hD2iFwYZ"))
    {
      Serial.println("Connected");
      client.subscribe("shipangei00@gmail.com/light");
      client.subscribe("shipangei00@gmail.com/pump");
      client.subscribe("shipangei00@gmail.com/roof");
    }
    else
    {
      Serial.print("Lỗi:, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void loop()
{
  if (!client.connected())
    reconnect();
  client.loop();
  if (millis() - t > 500)
  {
    float temp = dht.readTemperature();
    float humid = dht.readHumidity();
    int value = analogRead(A0);
    int moisture = 100-map(value, 0, 1023, 0, 100);
    t = millis();
    client.publish("shipangei00@gmail.com/temp", String(temp, 1).c_str());
    client.publish("shipangei00@gmail.com/humid", String(humid, 1).c_str());
    client.publish("shipangei00@gmail.com/moisture", String(moisture).c_str());
  }

  if (millis() - pumpStart > pumpTimer) {
    digitalWrite(PUMPPIN, LOW);
  } else {
    digitalWrite(PUMPPIN, HIGH);
  }

  if (light) {
    digitalWrite(LIGHTPIN, HIGH);
  } else {
    digitalWrite(LIGHTPIN, LOW);
  }

  if (roof) {
      servo1.write(0);
      servo2.write(0);
  } else {
      servo1.write(75);
      servo2.write(45);
  }
}
