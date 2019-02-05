
page = [[
HTTP/1.0 200 OK

<!DOCTYPE html>
<html>
<title>Christmas Tree Lights</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<body>
<h2>Pattern</h2>
<form method=post action="" enctype="text/plain">
  <input type="submit" name="pattern" value="All">
  <input type="submit" name="pattern" value="Sparkle">
  <input type="submit" name="pattern" value="Waves">
  <input type="submit" name="pattern" value="PentaPh">
  <input type="submit" name="pattern" value="RnG">
</form>
</body>
</html>
]]

srv=net.createServer(net.TCP);
srv:listen(80,function(conn)
	conn:on("receive",function(conn,payload)
		print(payload);
		if payload:match("^GET /%s") then
			conn:send(page);
			print("page sent");
		elseif payload:match("^POST /%s") then
			local pat = payload:match("pattern=(%S*)")
			if not pat then pat = "nil"; end
			setlights(pat);
			conn:send(page);
			print("page sent - btn="..pat);
		else
			conn:send('HTTP/1.0 404 Not Found');
			print("404 sent");
		end
	end)
	conn:on("sent",function(conn)
		conn:close();
	end)
end)
