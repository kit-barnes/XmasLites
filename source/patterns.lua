
local effect_timer = tmr.create();
local function_timer = tmr.create();

local rand = node.random;

local color = {
	string.char(255, 0, 0),			-- red
	string.char(255, 255, 0),		-- yellow
	string.char(0, 255, 0),			-- green
	string.char(0, 255, 255),		-- cyan
	string.char(0, 0, 255),			-- blue
	string.char(255, 0, 255),		-- purple
	string.char(255, 255, 255),		-- white (7)
	string.char(0,0,0)				-- black
}

function stopeffect()
	if effect_timer:state() then effect_timer:unregister() end
	pattern = nil
end

function stop()
	if function_timer:state() then function_timer:unregister() end
	stopeffect();
end

function off()
	stop();
	display_buffer:fill(0,0,0);
	ws2812.write(display_buffer);
end

function p1()

	stopeffect();
	local streak_spot, streak_stop, streak_direction, streak_hue = 0, 0, 0, 0;
	-- setup the buffers
	local background_buffer = ws2812.newBuffer(num_leds, 3);
	background_buffer:fill(24,0,0);
	local foreground_buffer = ws2812.newBuffer(num_leds, 3);
	foreground_buffer:fill(0,0,0);	
	-- run the effect
	effect_timer:alarm(100, tmr.ALARM_AUTO, function()
		-- add random active pixels to foreground
		for i = 1,num_leds do
			if rand(num_leds) == 1 then		-- avg 10 per second
				foreground_buffer:set( i, color[rand(6)]);
			end
		end
		-- do streaking
		if streak_spot == streak_stop then		-- not currently streaking
			if rand(20) == 1 then		-- start streak avg 2 seconds after previous
				streak_spot = rand(num_leds);
				streak_stop = rand(num_leds);
				streak_direction = rand(2);
				streak_hue = rand(6);
				if streak_hue <= 3 then streak_hue = color[1];
				elseif streak_hue <=5 then streak_hue = color[3];
				else streak_hue = color[7]; end
			end
		else	-- streaking
			foreground_buffer:set(streak_spot, streak_hue)
			-- randomize background under streak
			local c = rand(6);
			if c<=3 then
				background_buffer:set(streak_spot, string.char(24,0,0));
			elseif c<=5 then
				background_buffer:set(streak_spot, string.char(0,16,0));
			else
				background_buffer:set(streak_spot, string.char(12,10,5));
			end
			-- move spot
			if streak_direction == 1 then
				streak_spot = streak_spot % num_leds + 1;
			else
				streak_spot = (streak_spot + num_leds - 2) % num_leds + 1;
			end
		end
		-- combine and display
		display_buffer:mix(256,background_buffer,256,foreground_buffer);
		ws2812.write(display_buffer);
		-- fade active pixels
		foreground_buffer:fade(2);
	end)
end

function p2()		-- num_leds BETTER be 200!! 

	stopeffect();
	local t34 = {1,1,1,2,2,2,3,3,4,4,5,6,8,9,11,12,15,17,21,24,29,34,40,48,56,67,79,93,110,131,155,183,216,255};
	local t25 = {1,1,2,2,3,3,4,5,6,8,10,13,16,20,25,32,40,51,64,81,102,128,161,203,255};
	local t20 = {1,1,2,2,3,4,6,8,10,14,19,25,33,44,59,80,107,143,191,255};
	
	local x;
	local buf1 = ws2812.newBuffer(num_leds, 3);
	for i = 1,34 do x = t34[i];		-- 3 cycles red
		buf1:set(i, x,0,0); buf1:set(69-i, x,0,0);
		buf1:set(66+i, x,0,0); buf1:set(135-i, x,0,0);
		buf1:set(132+i, x,0,0); buf1:set(201-i, x,0,0);
	end
	local buf2 = ws2812.newBuffer(num_leds, 3);
	for i = 1,25 do x = t25[i];		-- 4 cycles green
		buf2:set(i, 0,x,0); buf2:set(51-i, 0,x,0);
		buf2:set(50+i, 0,x,0); buf2:set(101-i, 0,x,0);
		buf2:set(100+i, 0,x,0); buf2:set(151-i, 0,x,0);
		buf2:set(150+i, 0,x,0); buf2:set(201-i, 0,x,0);
	end
	local buf3 = ws2812.newBuffer(num_leds, 3);
	for i = 1,20 do x = t20[i];		-- 5 cycles blue
		buf3:set(i, 0,0,x); buf3:set(41-i, 0,0,x);
		buf3:set(40+i, 0,0,x); buf3:set(81-i, 0,0,x);
		buf3:set(80+i, 0,0,x); buf3:set(121-i, 0,0,x);
		buf3:set(120+i, 0,0,x); buf3:set(161-i, 0,0,x);
		buf3:set(160+i, 0,0,x); buf3:set(201-i, 0,0,x);
	end
	local buffers, chan, v = {buf1,buf2,buf3}, {1,2,3}, 1;
		-- chanX identifies the color (1,2,3=r,g,b) in buffersX
	effect_timer:alarm(50, tmr.ALARM_AUTO, function()
		x = x%20 + 1;
		if x == 1 and rand(10)~=1 then buf1:shift(v,ws2812.SHIFT_CIRCULAR); end
		if x%2 == 1 and rand(10)~=1 then buf2:shift(v,ws2812.SHIFT_CIRCULAR); end
		buf3:shift(-v,ws2812.SHIFT_CIRCULAR); -- moves quickest and opposite
		if rand(1000)==1 then
			if rand(2)==1 then v = -v; end		-- reverse direction
			local y = rand(3);
			local z = y%3 + 1;
			local b1,b2 = buffers[y], buffers[z];
			local c1,c2, n1,n2 = {},{}, chan[y],chan[z];
			local swapcolors = rand(2)==1;	-- else swap intensity patterns
			if swapcolors then chan[y], chan[z] = n2, n1; end
			for i = 1,num_leds do
				c1[1], c1[2], c1[3] = b1:get(i);
				c2[1], c2[2], c2[3] = b2:get(i);
				if swapcolors then
					c1[n1],c1[n2],c2[n1],c2[n2] = 0,c1[n1],c2[n2],0;
				else -- swap intensities
					c2[n2], c1[n1] = c1[n1], c2[n2];
				end
				b1:set(i,c1); b2:set(i,c2);
			end
		end
		-- combine and display
		display_buffer:mix(256,buf1,256,buf2,256,buf3);
		ws2812.write(display_buffer);
	end)
end

function p3()

	stopeffect();
	local buf1 = ws2812.newBuffer(num_leds, 3);
	local buf2 = ws2812.newBuffer(num_leds, 3);
	local buf3 = ws2812.newBuffer(num_leds, 3);
	local buf4 = ws2812.newBuffer(num_leds, 3);
	local buf5 = ws2812.newBuffer(num_leds, 3);
	
	local i20 = {0,1,2,3,4, 5,7,9,12,16, 21,27,38,49,64, 84,111,147,194,255}
	
	local w = 39;
	effect_timer:alarm(30, tmr.ALARM_AUTO, function()
		w = w%39 + 1;
		local x = w;
		local y = (w+16)%39 + 1;
		local z = (w+32)%39 + 1;
		local u = (w+8)%39 + 1;
		local v = (w+24)%39 + 1;
		if x == 1 then			-- set buf1 colors
			buf1:fill(0,0,0);
			for i = 1,num_leds,5 do buf1:set(i,i20[rand(20)],i20[rand(20)],i20[rand(20)]); end
		elseif y == 1 then		-- set buf3 colors
			buf3:fill(0,0,0);
			for i = 3,num_leds,5 do buf3:set(i,i20[rand(20)],i20[rand(20)],i20[rand(20)]); end
		elseif z == 1 then		-- set buf5 colors
			buf5:fill(0,0,0);
			for i = 5,num_leds,5 do buf5:set(i,i20[rand(20)],i20[rand(20)],i20[rand(20)]); end
		elseif u == 1 then		-- set buf2 colors
			buf2:fill(0,0,0);
			for i = 2,num_leds,5 do buf2:set(i,i20[rand(20)],i20[rand(20)],i20[rand(20)]); end
		elseif v == 1 then		-- set buf4 colors
			buf4:fill(0,0,0);
			for i = 4,num_leds,5 do buf4:set(i,i20[rand(20)],i20[rand(20)],i20[rand(20)]); end
		end
		--local peak;		-- 1 -> 20 -> 1
		if x > 20 then x = 40 - x; end
		if y > 20 then y = 40 - y; end
		if z > 20 then z = 40 - z; end
		if u > 20 then u = 40 - u; end
		if v > 20 then v = 40 - v; end
		display_buffer:mix(i20[x],buf1, i20[y],buf3, i20[z],buf5, i20[u],buf2, i20[v],buf4);
		ws2812.write(display_buffer);
	end)
end

function p4()

	stopeffect();
	local r = 64;
	local g = 0;
	display_buffer:fill(r,g,0);
	ws2812.write(display_buffer);

	local a = {};
	for i = 1, num_leds do a[i] = i; end
	local x = num_leds;
	function fp4()
		if x == num_leds then
			r, g = g*2, r/2;
			x = 0;
			for i = num_leds, 2, -1 do
				local j = node.random(i);
				a[i], a[j] = a[j], a[i];
			end
			effect_timer:alarm(15000, tmr.ALARM_SINGLE , fp4)
		else
			x = x + 1;
			display_buffer:set(a[x], string.char(r,g,0));
			ws2812.write(display_buffer);
			effect_timer:alarm(20, tmr.ALARM_SINGLE , fp4)
		end
	end
	fp4();
end


local patterns = {
	{ name = "Sparkle", f = p1 },
	{ name = "Waves", f = p2 },
	{ name = "PentaPh", f = p3 },
	{ name = "RnG", f = p4 },
}

function all()

	local p
	local f = function()
		local q = patterns[rand(#patterns)];
		if p ~= q then
			p = q
			p.f()
		end
	end
	f()
	function_timer:alarm(120000, tmr.ALARM_AUTO, f )
end

setlights = function(btn)
	
	if not btn then btn = "nil"; end
	if btn == "Off" then off();
	elseif btn == "All" then stop(); all();
	else
		for i,p in ipairs(patterns) do
			if btn == p.name then
				stop();
				p.f();
				break;
			end
		end
	end
	pattern = btn;
end
