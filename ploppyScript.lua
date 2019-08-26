--script to re-roll the weather repeatedly and report the wind speed

--won't tell you what direction the wind is blowing, but can help narrow down your search when seeking a strong tailwind.

--Constants up top need to be set manually before running the script
--------------------------------
local iteration = 0; --usually set to zero, can be set higher to resume an interrupted job
 
function sign(x)
  return x>0 and 1 or x<0 and -1 or 0;
end
 
--(mainmemory.read_s8(tonumber("0x106231")) < currentScore )
while (tastudio.getselection()[iteration] ~= nil)
do
      local a = iteration * 2;
      local b = 60 - (a % 120);
      local c = b * sign(a);
      tastudio.submitanalogchange(tastudio.getselection()[iteration],"P1 Y Axis",c);
      tastudio.submitanalogchange(tastudio.getselection()[iteration],"P1 X Axis",c);
      iteration = iteration + 1;
end
tastudio.applyinputchanges();
print("All done.");
client.pause();