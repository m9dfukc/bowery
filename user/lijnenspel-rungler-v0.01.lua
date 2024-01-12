--- rungler - version 0.01-preview
-- 
-- input 1: vco1 (data) rate
-- input 2: vco2 (clock) rate (and slew of smooth output)
-- output 1: rungler stepped
-- output 2: rungler smooth
-- output 3: xor
-- output 4: clock

function linexp(slo, shi, dlo, dhi, f)
  if f <= slo then
  return dlo
  elseif f >= shi then
  return dhi
  else
  return math.pow( dhi/dlo, (f-slo) / (shi-slo) ) * dlo
  end
end

shift_register = {}
shift_register_length = 8
feedback_freq = 0
feedback = true

vco_one = {value = 0, freq = 0.008}

vco_one.tick = function()
  vco_one.value = vco_one.value ~ 1
  -- XOR out
  output[3].volts = vco_one.value ~ shift_register[8]
end

vco_one.init = function()
  vco_one.metro = metro.init{event = function(c) vco_one:tick() end, count = -1, time = vco_one.freq}
  vco_one.metro:start()
end

vco_two = {freq = 0.065}

vco_two.tick = function()
  -- advance shift register
  table.remove(shift_register)
  table.insert(shift_register, 1, vco_one.value)
  -- output last three 3bit 
  local da_bits = {shift_register[6], shift_register[7], shift_register[8]}
  local bits = table.concat(da_bits)
  local v = tonumber(bits,2)
  -- set outputs
  output[1].volts = v
  output[2].volts = v
  output[4](pulse(0.0005,8))

  -- feedback out into vco rate
  feedback_freq = v
end

vco_two.init = function()
  vco_two.metro = metro.init{event = function(c) vco_two:tick() end, count = -1, time = vco_two.freq}
  vco_two.metro:start()
end

function init()
  for i=1,shift_register_length do
  shift_register[i] = 0
  end
  input[1].mode('stream',0.08)
  input[2].mode('stream',0.08)
  vco_one:init()
  vco_two:init()
end

function add_feedback(v)
  if feedback then
  return v+(feedback_freq/4)
  else
  return v
  end
end

input[1].stream = function(v)
  vco_one.metro.time = linexp(0, 10, 0.0004, 0.6, add_feedback(v))
end

input[2].stream = function(v)
  rate = linexp(0, 10, 0.0015, 0.6, add_feedback(v))
  vco_two.metro.time = rate
  output[2].slew = rate*4
end