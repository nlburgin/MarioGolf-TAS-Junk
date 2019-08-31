--script to bot analog inputs until the ball goes in the hole

--The original implementation of this was way too slow because it had to wait 
--for the shot to play out each iteration (>1000 frames).
--
--This uses a better memory watch that reduces that timeframe to a small fraction by exploiting the fact that 
--the game knows whether the ball will go in the hole long before the animation shows it going in.


--------------------------------

--Constants up top need to be set manually before running the script
  --Should try to fine-tune them to balance between how long it will take to run
  --vs its chance of success.

  local teeFrame = 11958;
  local strikeFrame = 12082;

  local teeSlot = 1;
  local strikeSlot = 3;
  
  local minStrikeX = -60;
  local maxStrikeX = -56;
  local minStrikeY = -60;
  local maxStrikeY = -39;



----------------------------------
local csv = "";
local permuteMarioGolf;

permuteMarioGolf = function (sign,maxAim,minAim)
  local ChipInAddr = tonumber("0x250B33") --Boolean value (1 if it's going to be a chip-in, 0 otherwise)
  
  --it takes a variable amount of frames before the boolean's value is computed
  --I used to have it set to +10 instead of +18, that worked for the first several holes I tried it on but failed when I tried it on a long shot par 5
  --At first I thought there were legitimately no solutions within the range I was searching, but it even failed to detect a chip-in that I found manually
  --I opened RAM watch and found out the game was taking too long to update the boolean, and my script wasn't waiting long enough to check on it
  local EndFrame = strikeFrame + 18;
  
  local aim = maxAim;
  --local aim = -34
  local aim2 = (0 - aim) + (sign * 2);
  local strikeX = maxStrikeX;
  --local aim = -54;
  --local strikeX = -52;
  local strikeY = maxStrikeY;

  --didn't think I'd need this!
  local solutionCount = 0;
   
   
   
  --(mainmemory.read_s8(tonumber("0x106231")) < currentScore )
  while (aim >= minAim)
  do
    savestate.loadslot(teeSlot);
    tastudio.submitanalogchange(teeFrame,"P1 X Axis",aim);
    tastudio.submitanalogchange(teeFrame - 2,"P1 X Axis",aim2);
    tastudio.applyinputchanges();
    while (emu.framecount() < strikeFrame - 2)
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
          print("");
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
end
permuteMarioGolf(1,-26,-58);
permuteMarioGolf(-1,58,26);

print("All out of options now. Did anything work?");
--output solutions as csv
print(csv);
client.pause();