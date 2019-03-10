-- UDP-button example
-- Author: Ori Novanda
--
-- Created for the RoDIYO group (https://www.facebook.com/groups/376640383160113/)
-- Tested on NodeMCU 0.9.5 build 20150318

buttonPin = 3
ledPin = 4

WIFI_SSID = "YOUR_WIFI_SSID"
WIFI_PASSWORD = "YOUR_WIFI_PASSWORD"

ESP8266_IP = ""
ESP8266_NETMASK = ""
ESP8266_GATEWAY = ""

SERVER_IP = "SERVER_IP"
SERVER_PORT = 8099

gpio.mode(ledPin, gpio.OUTPUT)
gpio.mode(buttonPin, gpio.INPUT, gpio.PULLUP)
gpio.write(ledPin, gpio.LOW)

wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)

if ESP8266_IP ~= "" and ESP8266_NETMASK ~= "" and ESP8266_GATEWAY ~= "" then
	print("Using static IP")
	wifi.sta.setip({ip=ESP8266_IP,netmask=ESP8266_NETMASK,gateway=ESP8266_GATEWAY})
else
	print("Using DHCP")
end
wifi.sta.connect()

function btnPressed(val)
	print(val)
	svr:send(val)
end

print("Connecting to the WIFI...")
tmr.alarm(1, 100, 1,
	function()
		if wifi.sta.getip() ~= nil then
			tmr.stop(1)
			print("Connected")
			print(wifi.sta.getip())

			svr=net.createConnection(net.UDP)
			svr:on("receive",
			function(s, d)
				print(d)
			end
			)
			svr:connect(SERVER_PORT, SERVER_IP)
			gpio.trig(buttonPin, 'both', btnPressed)
			print("Ready for action")
		end
	end
)
