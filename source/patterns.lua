
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
	background_buffer:fill(12,0,0);
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
				background_buffer:set(streak_spot, string.char(12,0,0));
			elseif c<=5 then
				background_buffer:set(streak_spot, string.char(0,9,0));
			else
				background_buffer:set(streak_spot, string.char(8,7,4));
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

function p2()		-- num_leds BETTER be 150!! 

	stopeffect();
	local i18 = {0,1,1,2,3,4,6,10,16,26,41,64,95,134,176,216,245,255};
	local i15 = {0,1,2,3,4,7,12,21,38,64,102,150,201,241,255};
	local i12 = {0,1,2,4,8,16,33,64,113,176,233,255};
	
	local x;
	local buf1 = ws2812.newBuffer(num_leds, 3);
	for i = 1,12 do x = i12[i];		-- 6 cycles red
		buf1:set(i, x,0,0); buf1:set(25-i, x,0,0);
		buf1:set(25+i, x,0,0); buf1:set(51-i, x,0,0);
		buf1:set(50+i, x,0,0); buf1:set(75-i, x,0,0);
		buf1:set(75+i, x,0,0); buf1:set(101-i, x,0,0);
		buf1:set(100+i, x,0,0); buf1:set(125-i, x,0,0);
		buf1:set(125+i, x,0,0); buf1:set(151-i, x,0,0);
	end
	local buf2 = ws2812.newBuffer(num_leds, 3);
	for i = 1,18 do x = i18[i];		-- 4 cycles green
		buf2:set(i, 0,x,0); buf2:set(37-i, 0,x,0);
		buf2:set(37+i, 0,x,0); buf2:set(74-i, 0,x,0);
		buf2:set(75+i, 0,x,0); buf2:set(112-i, 0,x,0);
		buf2:set(112+i, 0,x,0); buf2:set(149-i, 0,x,0);
	end
	local buf3 = ws2812.newBuffer(num_leds, 3);
	for i = 1,15 do x = i15[i];		-- 5 cycles blue
		buf3:set(i, 0,0,x); buf3:set(31-i, 0,0,x);
		buf3:set(30+i, 0,0,x); buf3:set(61-i, 0,0,x);
		buf3:set(60+i, 0,0,x); buf3:set(91-i, 0,0,x);
		buf3:set(90+i, 0,0,x); buf3:set(121-i, 0,0,x);
		buf3:set(120+i, 0,0,x); buf3:set(151-i, 0,0,x);
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
	
	local i20 = {0,1,2,3,4,5,7,9,12,16,21,27,38,49,64,84,111,147,194,255}
	
	local x = 40;
	effect_timer:alarm(30, tmr.ALARM_AUTO, function()
		x = x%40 + 1;
		if x == 1 then			-- set buf1 colors
			buf1:fill(0,0,0);
			for i = 1,num_leds,2 do buf1:set(i,i20[rand(20)],i20[rand(20)],i20[rand(20)]); end
		elseif x == 21 then		-- set buf2 colors
			buf2:fill(0,0,0);
			for i = 2,num_leds,2 do buf2:set(i,i20[rand(20)],i20[rand(20)],i20[rand(20)]); end
		end
		local peak;		-- 1 -> 20 -> 1
		if x <= 20 then peak = x;
		else peak = 41 - x;
		end
		display_buffer:mix(i20[peak],buf1,i20[21-peak],buf2);
		ws2812.write(display_buffer);
	end)
end