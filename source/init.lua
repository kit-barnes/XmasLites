-- wifi.sta.config({ssid="115ChadwickRd",pwd="Welcome2Hillsdale!"})

ws2812.init()

num_leds = 150;
display_buffer = ws2812.newBuffer(num_leds, 3);

display_buffer:fill(128,0,0);					-- red (no connection yet)
ws2812.write(display_buffer);

if not pcall(node.flashindex("_init")) then
	display_buffer:fill(0,0,64);				-- blue - LFS init failed
	ws2812.write(display_buffer);
	return;
end

tmr.alarm(0, 500, tmr.ALARM_AUTO, function()
	if (wifi.sta.status() == wifi.STA_GOTIP) then
		tmr.unregister(0)
		print("WiFi up", node.heap(), wifi.sta.getip())

		FTP = require("ftpserver");
		FTP.createServer("xmas","tree");
		print("FTP up");
		
		telnet = LFS.telnet();
		telnet:open(nil,nil,23);
		print("telnet coming up");

		display_buffer:fill(0,128,0);			-- green - telnet & FTP servers up, caling main
		ws2812.write(display_buffer);

		if file.exists("main.lua") then
			dofile("main.lua");
		end
	else
		print(".");
	end
end)

