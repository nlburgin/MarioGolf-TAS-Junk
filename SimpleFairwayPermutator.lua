--script to bot analog inputs and measure shot distance and how long it takes the ball to come to a stop.

--it is considerably slower than our permutator for making it go in the hole, because it has to wait for the shot to play out.
--So we must make sure to run it for relatively few iterations to keep the timescales sane. It's still better than manual trial and error


--------------------------------

--Constants up top need to be set manually before running the script
  --Should try to fine-tune them to balance between how long it will take to run
  --vs its chance of success.

  local teeFrame = 718;
  local strikeFrame = 840;

  local teeSlot = 2;
  local strikeSlot = 3;
  
  local minStrikeX = -30;
  local maxStrikeX = 30;
  local minStrikeY = 56;
  local maxStrikeY = 60;
  local minAim = 0;
  local maxAim = 0;



----------------------------------
local isNumericChar;

isNumericChar = function(val)
  return val >= 0x30 and val <= 0x39;
end


--local prev = 0;
--local cur = 1;

local EndFrame = strikeFrame + 18;

local aim = maxAim;
--local aim = -34
--local aim2 = (0 - aim) + (sign * 2);
local strikeX = maxStrikeX;
--local aim = -54;
--local strikeX = -52;
local strikeY = maxStrikeY;

--didn't think I'd need this!
 
 
 
--(mainmemory.read_s8(tonumber("0x106231")) < currentScore )
while (aim >= minAim)
do
  savestate.loadslot(teeSlot);
  tastudio.submitanalogchange(teeFrame,"P1 X Axis",aim);
  --tastudio.submitanalogchange(teeFrame - 2,"P1 X Axis",aim2);
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
      
      while (emu.framecount() < (strikeFrame+100)) do
        emu.frameadvance()
      end
      
      
      
      
      --string address is only valid every other frame, give or take depending on lag.
      --however, it stops flickering and becomes stable during the transition to the next shot
      --sort of like how the wind number stabilizes when the pause menu is up.
      --we use this to measure if the shot has run its course.
      local stable = 0;
      local one;
      local two;
      local three;
      local four;
      local five;
      local six;
      local seven;
      while (stable < 10) do
        emu.frameadvance();
        one   =   mainmemory.readbyte(0x0F71A2);
        two   =   mainmemory.readbyte(0x0F71A3);
        three =   mainmemory.readbyte(0x0F71A4);
        four  =   mainmemory.readbyte(0x0F71A5);
        five  =   mainmemory.readbyte(0x0F71A6);
        six   =   mainmemory.readbyte(0x0F71A7);
        seven =   mainmemory.readbyte(0x0F71A8);
        if isNumericChar(one) and isNumericChar(two) and isNumericChar(three) and isNumericChar(four) and isNumericChar(five) and isNumericChar(six) and isNumericChar(seven) then
            stable = stable + 1;
        else
          stable = 0;
        end
      end
      
      print(string.format("Frame: %d ; Aim: %d ; Strikezone (X,Y): %d,%d ; distance: %c%c%c.%c%c%c%c",emu.framecount(),aim,strikeX,strikeY,one,two,three,four,five,six,seven));
      
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
  --aim2 = aim2 + 2;
end


print("All out of options now. Did anything work?");
--output solutions as csv
print(csv);
client.pause();