-- init.lua --

-- Network Variables
ssid = "espnw"
pass = "12345678"
--ssid = "MLK5H"
--pass = "5JW2SXLJVNM4KHST"

-- Configure Wireless Internet
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')\n')
print('MAC Address: ',wifi.sta.getmac())
print('Chip ID: ',node.chipid())
print('Heap Size: ',node.heap(),'\n')

-- Configure WiFi
wifi.sta.config(ssid,pass)

uart.setup(0,9600,8,0,1)
uart.write( 0, "0")

dofile("http_led_page.lua")
