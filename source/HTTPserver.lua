

setlights = function(btn)
	stop();
	if btn == "all" then off();
	elseif btn == "p1" then p1();
	elseif btn == "p2" then p2();
	elseif btn == "p3" then p3();
	else return;
	end
	pattern = btn;
end
 
setlights("all");

local boundary = "not set"	-- INVALID - contains space

srv=net.createServer(net.TCP);
srv:listen(80,function(conn)
	conn:on("receive",function(conn,payload)
		print(payload);
		if payload:match("^POST /file ") then
			boundary = payload:match("%sboundary=(%-%-%-%-%S*)");
			print("boundary set: "..boundary);
			return	-- nothing sent - won't trigger disconnect
		end
		local pagename = pattern;
		local btn = payload:match("^GET /(%S*)");
		print(btn);
		if payload:match(boundary) then
			local filename = payload:match(' filename="(%S*)"');
			local filestart = payload:match("\n[\r]*\n()");
			local fileend = payload:match("()[\r]*\n"..boundary, filestart);
			if #filename and filestart and fileend then
				print(filename, filestart, fileend)
				if file.open(filename,"w") then
					file.write(payload:sub(filestart,fileend));
					file.close();
				end
			end
		elseif btn=="upload" or btn=="all" or btn=="p1" or btn=="p2" or btn=="p3" then
			if pattern ~= btn then setlights(btn) end
			pagename = btn;
		elseif btn=="favicon.ico" then
			conn:send('HTTP/1.0 404 Not Found');
			print("404 sent");
			return
		end
		print(pagename);
		local page = "error?";
		if file.open(pagename..".htm") then
			page = file.read();
			file.close();
		end
		conn:send(page);
	end)
	conn:on("sent",function(conn)
		conn:close();
	end)
end)
