--- Crell
-- https://github.com/dansimco/crell
-- Dan Sim 2020.07.30
-- Krell in Crow
-- in1: Attack time (0V - 10V)
-- in2: Decay time (0V - 10V)
-- out1: Envelope
-- out2: Random voltages (-2V - 2V)
-- out3: Random voltages (0V - 10V)
-- out4: Clock pulse

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

function attack_max_time(v)
  local new_env = math.abs(v*1000)
  if new_env < 50 then new_env = 50 end
  attack_max = new_env
end

input[1].stream = attack_max_time
input[1].mode("stream", 0.25)


function decay_max_time(v)
  local new_env = math.abs(v*1000)
  if new_env < 50 then new_env = 50 end
  decay_max = new_env
end

input[2].stream = decay_max_time
input[2].mode("stream", 0.25)