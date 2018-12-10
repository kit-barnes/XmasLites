dofile("patterns.lua");
dofile("HTTPserver.lua");
local x = node.random(3);
if x == 1 then p1()
elseif x == 2 then p2()
else p3();
end