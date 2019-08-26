--script to bot analog inputs until the ball goes in the hole

--The original implementation of this was way too slow because it had to wait 
--for the shot to play out each iteration (>1000 frames).
--
--This uses a better memory watch that reduces that timeframe to a small fraction by exploiting the fact that 
--the game knows whether the ball will go in the hole long before the animation shows it going in.

--Constants up top need to be set manually before running the script
--Should try to fine-tune them to balance between how long it will take to run
--vs its chance of success.


--------------------------------
local teeFrame = 4250;
local strikeFrame = 4371;

local teeSlot = 8;
local strikeSlot = 9;

local maxAim = -26;
local minAim = -58;

local minStrikeX = 57;
local maxStrikeX = 60;
local minStrikeY = 30;
local maxStrikeY = 50;



----------------------------
local ChipInAddr = tonumber("0x250B33") --Boolean value (1 if it's going to be a chip-in, 0 otherwise)
local EndFrame = strikeFrame + 10;
local aim = maxAim;
local aim2 = (0 - aim) + 2;
local strikeX = maxStrikeX;
--local aim = -54;
--local strikeX = -52;
local strikeY = maxStrikeY;

--didn't think I'd need this!
local solutionCount = 0;
 
local csv = "";
 
 
 
--(mainmemory.read_s8(tonumber("0x106231")) < currentScore )
while (aim >= minAim)
do
  savestate.loadslot(teeSlot);
  tastudio.submitanalogchange(teeFrame,"P1 X Axis",aim);
  tastudio.submitanalogchange(teeFrame - 2,"P1 X Axis",aim2);
  tastudio.applyinputchanges();
  while (emu.framecount() < strikeFrame - 4)
  do
    emu.frameadvance();
  end
  savestate.saveslot(strikeSlot);
  while (strikeX >= minStrikeX)
  do
    while (strikeY >= minStrikeY)
    do
      
      --tastudio.applyinputchanges() 
      savestate.loadslot(strikeSlot);
      tastudio.submitanalogchange(strikeFrame,"P1 Y Axis",strikeY);
      tastudio.submitanalogchange(strikeFrame,"P1 X Axis",strikeX);
      tastudio.applyinputchanges();
      while (emu.framecount() < EndFrame)
      do
        emu.frameadvance();
      end
      if (mainmemory.read_u8(ChipInAddr) == 1)
      then
        solutionCount = solutionCount + 1;
        print(string.format("Solution #%d",solutionCount));
        print(string.format("Aim: %d,%d",aim,aim2));
        print(string.format("Strikezone X %d",strikeX));
        print(string.format("Strikezone Y %d",strikeY));
        csv = csv..tostring(solutionCount)..","..tostring(aim)..","..tostring(aim2)..","..tostring(strikeX)..","..tostring(strikeY)..",";
      end
      
      --optimize over analog dead zone where everything is equivalent to zero from -15 to 15
      if math.abs(strikeY) > 15 then
        strikeY = strikeY - 1;
      elseif strikeY > 0 then
        strikeY = -1;
      else
        strikeY = -16
      end
    end
    --optimize over analog dead zone where everything is equivalent to zero from -15 to 15
    if math.abs(strikeX) > 15 then
      strikeX = strikeX - 1;
    elseif strikeX > 0 then
      strikeX = -1;
    else
      strikeX = -16
    end
    strikeY = maxStrikeY;
  end
  strikeX = maxStrikeX;
  aim = aim - 2;
  aim2 = aim2 + 2;
end
print("All out of options now. Did anything work?");
--output solutions as csv
print(csv);
client.pause();