#include "Arduino.h"
#include <SPI.h>
#include <Ethernet.h>
#include "PubSubClient.cpp"
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte queue[] = {192, 168, 0, 11};
IPAddress ip(192,168,0,177);
EthernetClient eth;
void enable(int what, bool value)
{
    pinMode(what, OUTPUT);
    delay(300);
    digitalWrite(what, value);
}
PubSubClient* client;
void callback(char* topic, byte* payload, unsigned int length)
{
    const char* message = (const char*)payload;
    if((message[0]) == 'l'/*ight*/)
        client->publish("/home/actuators/lights/values", 
                "{\"on\":{\"icon\":\"circle\"},\"off\":{\"icon\":\"circle-blank\"}}");
    else enable(2, message[1] == /*of*/'f');
}
void setup()
{
    client = new PubSubClient(queue, 1883,  callback, (Client&) eth);
    Ethernet.begin(mac, ip);
    client->connect("testClient");
    client->subscribe("/home/actuators");
    client->subscribe("/home/actuators/lights");
    Serial.println("setup.");
}
void loop()
{
    client->loop();
}
