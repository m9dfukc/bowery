--- rungler for crow v2.1 //////// Imminent gloom
-- https://llllllll.co/t/rungler-for-crow/51905
-- the Rungler is Rob Hordijks idea; it's a very good idea.
-- my best guess at one based on https://electro-music.com/forum/topic-38081.html

--  input 1: clock, rising edge
--  input 2: data
-- output 1: s/h           (bonus feature #1)
-- output 2: quatized s/h  (bonus feature #2)
-- output 3: digital noise (bonus feature #3)
-- output 4: RUNGLER!

-- WTF and basic patch:
-- Plug VCOs or LFOs into the inputs; mult output 4 to two attenuators or
-- attenuverters; patch each of these to control the frequency of the
-- oscillators; monitor one of the oscillators.

-- The first oscillator is the clock, on every rising edge it samples the
-- second oscillator and adds its value to a shift register that outputs
-- a stepped modulation-signal.

-- A usual implementation has the rungler patched so that it feeds back
-- on the sources providing its input resulting in a chaotic pattern that
-- intermittently jumps from one state to the next.

-- The output is created by running the last 3 steps of the register
-- through a 3-bit DAC, which gives 8 possible values. The register is
-- also feed back on itself by combining the new value with the last step
-- using an xor gate.

-- There are several different versions of the Benjolin out there that
-- all have slight variations, most have two wide-range VCOs and a filter
-- with loads of cross modulation and feedback as well as multiple
-- outputs from both oscillators, combinations of them, and the filter.


register = sequins{0,0,0,0,0,0,0,0}                     -- use sequins as register
r = register
s = {4,2,1}                                             -- set up 3-bit DAC

function init()
  input[1].mode('change',1.0,0.1,'rising')              -- set up input 1 to take clock
  output[2].scale({0,2,3,7,8},12,1)                     -- set scale for output 2
  m:start()                                             -- start metro for noise
end

function to_bin(value,threshold)                        -- check if value is over threshold and output 1/0
  b = value > threshold
  return b and 1 or 0
end
