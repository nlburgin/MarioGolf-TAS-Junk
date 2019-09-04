--script to bot analog inputs until the ball goes in the hole

--An early implementation of this was way too slow because it had to wait 
--for the shot to play out each iteration, before checking a memory address 
--that displayed P1's score (took >1000 frames to do reliably).
--
--This version checks a better memory address that reduces that timeframe to a tiny fraction 
--by exploiting the fact that the game knows whether the ball will go in the hole 
--long before the animation shows it going in.

--------------------------------

--Constants up top need to be set manually before running the script
  --Should try to fine-tune them to balance between how long it will take to run
  --vs its chance of success.

  local teeFrame = 2415; --aim control frame
  local strikeFrame = 2538; --strike zone control frame

  --branch to root the script to
  --previously two branches were used, but now we lean more on the greenzone since it's faster
  local teeSlot = 2;
  --local strikeSlot = 3;
  
  --boundaries for strike zone analog values to search through
  --useful range is -60 to 60. Any higher magnitude just gets rounded down by the game
  -- number of iterations is multiplicative: ΔstrikeX × ΔstrikeY × 34
  local minStrikeX = 45;
  local maxStrikeX = 60;
  local minStrikeY = 45;
  local maxStrikeY = 60;
  
  --frame distance between aim and counter-aim for bidirectional aim permutator
  --outside of unusual lag shenanigans, should pretty much always be set to -2
  local frameDiff = -2
  
  --scan left-to right horizontally, on top of (or instead of) fine-grained counterweighted double permutation.
  --turning this on and setting a wide range tends to be wasteful, as you'll often be aiming nowhere near the hole
  --normally you want to line up manually, but can be used if extreme brute-forcing is desired.
  --this does NOT skip the aim control's dead zone from -28 to 28, so don't cross that area if you don't want a complete waste of time.
  local scan = true;
  local maxScanAim = 60;
  local minScanAim = 54;
  
  --frame distance between bidirectional aim permutator and linear scan aim
  --outside of unusual lag shenanigans, should pretty much always be set to 2
  local frameDiff_S = 3;
  
  --skip the "left" or "right" halves of the bidirectional permutator
  --cuts runtime in half when you know one of the halves will consistently miss the hole
  local skipLeft = false;
  local skipRight = false;
  
  --skipX and skipY should usually both be 15 (representing the strike zone's analog dead zone)
  --unless you're running second pass to broaden range without duplicating much work
  local skipX = 15
  local skipY = 15
  
  --if true disable bidirectional aim permutation, only permute strike zone. 
  --Decreases run time by a factor of 34.
  --teeFrame variable is ignored
  --can stack with "scan" to scan aim without fine permutation, though that rarely finds anything.
  local simple = false;
  
  --skip running the zero case when skipping deadzone
  --should be false unless running a second(+) pass
  local skipZero = false;
  
  --file for output log. 
  --By logging to a file instead of lua console, we don't lose all our progress if the emulator crashes
  --if using overwrite mode and not append mode, be sure to rename successful logs before running again.
  local file = io.open("W:\\HolePermutationLog.txt", "w+");

----------------------------------
local csv = "";
local permuteMarioGolf;
local ChipInAddr = 0x250B33; --Boolean value (1 if it's going to be a chip-in, 0 otherwise)

client.SetSoundOn(false);
io.output(file);

if simple then
  frameDiff_S = 0;
end


permuteMarioGolf = function (sign,maxAim,minAim)
  local scanAim = minScanAim;
  repeat
    --it takes a variable amount of frames before the boolean's value is computed
    --I used to have it set to +10 instead of +18, that worked for the first several holes I tried it on but failed when I tried it on a long shot par 5
    --At first I thought there were legitimately no solutions within the range I was searching, but it even failed to detect a chip-in that I found manually
    --I opened RAM watch and found out the game was taking too long to update the boolean, and my script wasn't waiting long enough to check on it
    local EndFrame = strikeFrame + 18;
    
    local aim = maxAim;
    local aim2 = (0 - aim) + (sign * 2);
    local strikeX = maxStrikeX;
    local strikeY = maxStrikeY;
    
    --didn't think I'd need this!
    local solutionCount = 0;
    
    if scan then
      local msg = string.format("scan has reached aim level %d",scanAim);
      print(msg);
      io.write(msg.."\n");
    end
    
    while (aim >= minAim)
    do
      savestate.loadslot(teeSlot);
      print(string.format("now trying: (%d,%d)",aim,aim2));
      emu.yield();
      if not simple then
        tastudio.submitanalogchange(teeFrame,"P1 X Axis",aim);
        tastudio.submitanalogchange(teeFrame + frameDiff,"P1 X Axis",aim2);
      end
      if scan then
        tastudio.submitanalogchange(teeFrame + frameDiff_S,"P1 X Axis",scanAim);
      end
      if scan or (not simple) then
        tastudio.applyinputchanges();
      end
      --tastudio.setplayback(strikeFrame-3);
      --while (emu.framecount() < strikeFrame - 2)
      --do
        --emu.frameadvance();
      --end
      --savestate.saveslot(strikeSlot);
      while (strikeX >= minStrikeX)
      do
        while (strikeY >= minStrikeY)
        do
          
          --tastudio.applyinputchanges() 
          --savestate.loadslot(strikeSlot);
          tastudio.submitanalogchange(strikeFrame,"P1 Y Axis",strikeY);
          tastudio.submitanalogchange(strikeFrame,"P1 X Axis",strikeX);
          tastudio.applyinputchanges();
          --emu.frameadvance();
          --emu.frameadvance();
          tastudio.setplayback(EndFrame)
          --while (emu.framecount() < EndFrame)
          --do
            --emu.frameadvance();
            --emu.frameadvance();
          --end
          if (mainmemory.read_u8(ChipInAddr) == 1)
          then
            solutionCount = solutionCount + 1;
            print(solutionCount);
            io.write(string.format("Solution #%d\n",solutionCount));
            io.write(string.format("Aim: %d,%d\n",aim,aim2));
            io.write(string.format("Strikezone X %d\n",strikeX));
            io.write(string.format("Strikezone Y %d\n\n",strikeY));
            io.flush();
            csv = csv..tostring(solutionCount)..","..tostring(scanAim)..tostring(aim)..","..tostring(aim2)..","..tostring(strikeX)..","..tostring(strikeY)..",";
          end
          
          --optimize over analog dead zone where everything is equivalent to zero from -15 to 15
          if math.abs(strikeY) > skipY then
            strikeY = strikeY - 1;
          elseif strikeY > 0 and not skipZero then
            strikeY = -1;
          else
            strikeY = -1 - skipY
          end
          
          --insert a yield here if you want script to be interruptible
          --emu.yield()
          
        end
        --optimize over analog dead zone where everything is equivalent to zero from -15 to 15
        if math.abs(strikeX) > skipX then
          strikeX = strikeX - 1;
        elseif strikeX > 0 and not skipZero then
          strikeX = -1; --equivalent to zero
        else
          strikeX = -1 - skipX
        end
        strikeY = maxStrikeY;
      end
      
      if simple then
        break;
      end
      
      strikeX = maxStrikeX;
      aim = aim - 2;
      aim2 = aim2 + 2;
    end
    
    scanAim = scanAim + 2;
  until((not scan) or scanAim > maxScanAim)
end

if simple then
  permuteMarioGolf(1,0,0);
else
  if not skipRight then
    permuteMarioGolf(1,-26,-58);
    if not skipLeft then
      io.write("printing first half of CSV in case you want to give up on second half...\n");
      io.write(csv);
      io.write("\n");
      io.flush();
    end
  end
  if not skipLeft then
    permuteMarioGolf(-1,58,26);
  end
end
print("Permutator complete.");
if csv == "" then
  print("It appears I have failed you.");
else
  print("Check your log file!");
end
--output solutions as csv
io.write("CSV of Final Results:\n");
io.write(csv);
io.write("\n");
io.flush();
io.close();
client.SetSoundOn(true);


--kludge. "Save changes" dialog prevents actual exit and can be canceled, but also overrides the anti-pause helper script so it doesn't run infinitely
--client.exit();


client.pause();