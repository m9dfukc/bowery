--- Remainders (version 0.1)
-- https://llllllll.co/t/remainders-a-modulo-gesture-generator-for-crow/40084
-- modulo gesture generator/cv divider
-- Input a voltage and get 4 folded outputs based on a simple modulo operation. Perfect for your one knob to rule them all.

-- in 1: Gesture (CV) in (Great for knobs/joysticks)
-- in 2: Transpose in (Great for quantised melodies)
-- out 1-4: Voltages being folded 1 to 4 times, top to bottom. eg. Output 4 has modulo of 2 meaning it recents to 0V with every 2V increment meaning it folds 4 times.


minVal = 0;
maxVal = 0;
peakToPeak = 0;

function init()
  input[1].mode('stream', 0.01)
  input[2].mode('change', 1, 0.1, 'rising')
  for n=1,4 do output[n].slew = 0.01 end
end

function calcBounds(v)
  if (v < minVal) then
    minVal = v;
  end
  if (v > maxVal) then
    maxVal = v;
  end
  peakToPeak = math.abs(minVal) + math.abs(maxVal);
end

input[2].change = function()
  minVal = 0;
  maxVal = 0;
  peakToPeak = 0;
end

input[1].stream = function(v)
  calcBounds(v)
  for n=1,4 do
      remainder = v % (peakToPeak/(n+1))
      output[n].volts = (remainder * (n + 1)) - math.abs(minVal)
  end
end