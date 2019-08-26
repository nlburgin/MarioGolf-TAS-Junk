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
      tastudio.submitanalogchange(tastudio.getselection()[iteration],"P1 Y Axis",math.random(-60,60));
      tastudio.submitanalogchange(tastudio.getselection()[iteration],"P1 X Axis",math.random(-60,60));
      iteration = iteration + 1;
end
tastudio.applyinputchanges();
print("All done.");
client.pause();