--- Crell
-- https://github.com/dansimco/crell
-- Dan Sim 2020.07.30
-- Krell in Crow
-- in1: Attack/Decay shape tilt (-5V - +5V)
-- in2: Total envelope length (0V - 10V)
-- out1: Envelope
-- out2: Random voltages (-2V - 2V)
-- out3: Random voltages (0V - 10V)
-- out4: Clock pulse

local env_median = 1000
local attack_max = 500
local decay_max = 500
local octave_range = 4
local mod_range = 10
local shape_mode = 'logarithmic'

function init()
  output[1](loop{
    to(10, gen_voltages, shape_mode),
    to(0, function() return math.ceil(decay_max * math.random()) / 1000 end , shape_mode)
  })
  output[4].action = pulse(0.02,8)
end

function gen_voltages()
  output[2].volts = (math.random() * octave_range) - (octave_range/2)
  output[3].volts = (math.random() * mod_range)
  output[4]()
  local attack_time = math.ceil(attack_max * math.random()) / 1000
  return attack_time
end

function process_shape_change(v)
  local shape_weight = v*(env_median/5-10)
  attack_max = env_median + shape_weight
  decay_max = env_median - shape_weight
end

input[1].stream = process_shape_change
input[1].mode("stream", 0.25)


function process_time_change(v)
  local new_env = math.abs(v*1000)
  if new_env < 50 then new_env = 50 end
  env_median = new_env
end

input[2].stream = process_time_change
input[2].mode("stream", 0.25)