--script to re-roll the weather repeatedly and report the wind speed

--won't tell you what direction the wind is blowing, but can help narrow down your search when seeking a strong tailwind.

--Constants up top need to be set manually before running the script
--------------------------------
local branch = 5; --should be set up to reach the next hole and then press start to bring up pause menu
local insertionFrame = 2490; --right before last swing on previous hole
local max_iterations = 50;
local iteration = -1; --usually set to zero, can be set higher to resume an interrupted job
local EndFrame = 3581; --should be after you pause.

--local checkPin = false; --if set true, the branch used shouldn't mash through the hole's intro animation but should let it fly over the green
--local pinFrame = 0;
 
--(mainmemory.read_s8(tonumber("0x106231")) < currentScore )
while (max_iterations > iteration)
do
      local frameAdjust = (iteration + 1) * 2;
      savestate.loadslot(branch);
      tastudio.submitinsertframes(insertionFrame, frameAdjust);
      tastudio.applyinputchanges();
      while (emu.framecount() < EndFrame + frameAdjust)
      do
        emu.frameadvance();
        --if (checkPin and emu.framecount() == pinFrame + frameAdjust)
        --then
          --client.screenshot(string.format("F:\\Iteration %u (pin).png",iteration + 1));
        --end
      end
      
      if (EndFrame + frameAdjust > emu.framecount())
      then
        print("wtf"); --if this happens, something's screwy
        client.pause();
        emu.frameadvance();
      end
      print(string.format("Finished Iteration %u. The wind is: %c%c",iteration + 1,mainmemory.readbyte(tonumber("0x0F6F56")),mainmemory.readbyte(tonumber("0x0F6F57"))));
      client.screenshot(string.format("W:\\Iteration %u.png",iteration + 1));
      iteration = iteration + 1;
end
print("All done.");
client.pause();