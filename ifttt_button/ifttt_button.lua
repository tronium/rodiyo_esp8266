-- IFTTT-button example
-- Author: Ori Novanda
--
-- Created for the RoDIYO group (https://www.facebook.com/groups/376640383160113/)
-- Tested on NodeMCU 0.9.5 build 20150318
-- Note: the connection does not use a secure http!

buttonPin = 3
ledPin = 4

WIFI_SSID = "YOUR_WIFI_SSID"
WIFI_PASSWORD = "YOUR_WIFI_PASSWORD"

ESP8266_IP = ""
ESP8266_NETMASK = ""
ESP8266_GATEWAY = ""

PROXY_IP = ""
PROXY_PORT = 8000

IFTTT_IP = "54.175.81.255"

gpio.mode(buttonPin, gpio.INPUT, gpio.PULLUP)
gpio.mode(ledPin, gpio.OUTPUT)

wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)

if ESP8266_IP ~= "" and ESP8266_NETMASK ~= "" and ESP8266_GATEWAY ~= "" then
	print("Using static IP")
	wifi.sta.setip({ip=ESP8266_IP,netmask=ESP8266_NETMASK,gateway=ESP8266_GATEWAY})
else
	print("Using DHCP")
end
wifi.sta.connect()

interval = 1
function mainLoop()
--	tmr.alarm(0, interval, 1, function ()
		currBtnState = gpio.read(buttonPin)
		if currBtnState == 1 then
			gpio.write(ledPin, gpio.LOW)
		else
			gpio.write(ledPin, gpio.HIGH)
		end
		if (currBtnState == 0) and (currBtnState ~= prevBtnState) then
			print("Ordering the pizza:", pizzaType)
			count = count + 1
			srv = net.createConnection(net.TCP, 0)
			srv:on("connection",
				function(sck, c)
					query = "GET http://maker.ifttt.com/trigger/{event_name}/with/key/{your_key}?value1=" .. pizzaType .. "&value2=" .. count .. " HTTP/1.0\r\n\r\n\r\n"
					print(query)
					sck:send(query)
				end
			)
			srv:on("receive",
				function(sck, c)
					--no check
					print("Ordered, sequence number:", count)
					--print(c)
					sck:close()
				end
			)

			if PROXY_IP ~= "" then
				srv:connect(PROXY_PORT, PROXY_IP)
			else
				srv:connect(80, IFTTT_IP)
			end
		end
		prevBtnState = currBtnState
--	end)
end

print("Connecting to the WIFI...")
tmr.alarm(1, 100, 1,
	function()
		if wifi.sta.getip() ~= nil then
			tmr.stop(1)
			print("Connected")
			print(wifi.sta.getip())
			gpio.write(ledPin, gpio.LOW)
			print("Press the button to order the pizza")

			pizzaType = "MeatLover"
			count = 0 
			prevBtnState = 1
			tmr.alarm(0, interval, 1, mainLoop)
		end
	end
)
