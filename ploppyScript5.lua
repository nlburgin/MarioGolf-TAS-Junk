--script to re-roll the weather repeatedly and report the wind speed

--won't tell you what direction the wind is blowing, but can help narrow down your search when seeking a strong tailwind.

--Constants up top need to be set manually before running the script
--------------------------------
local iteration = 0; --usually set to zero, can be set higher to resume an interrupted job
 
function sign(x)
  return x>0 and 1 or x<0 and -1 or 0;
end

local r = 23

--(mainmemory.read_s8(tonumber("0x106231")) < currentScore )
local selection = tastudio.getselection();
local length = 0;
while (selection[length] ~= nil)
do
  length = length + 1;
end

while (selection[iteration] ~= nil)
do
      local t = (math.pi * 2) * (iteration / length) * 3;
      local a = math.floor(r * math.sin(t));
      local a2 = a + (18 * sign(a));
      local b = math.floor(r * math.cos(t));
      local b2 = b + (18 * sign(b));
      
      
      tastudio.submitanalogchange(selection[iteration],"P1 Y Axis",a2);
      tastudio.submitanalogchange(selection[iteration],"P1 X Axis",b2);
      iteration = iteration + 1;
end
tastudio.applyinputchanges();
print("All done.");
client.pause();