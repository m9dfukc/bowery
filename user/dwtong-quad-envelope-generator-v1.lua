---- https://llllllll.co/t/crow-ideas/25867/139
--- quad envelope generator
--
-- input[1] controls sequence of envelope triggers
-- input[2] controls env release
-- arp rate is based on distance between the values of both inputs

s = sequins

offset = 0.5
outputs = s{1,2,3,4}

function init()
    input[1].mode('stream', 0.01)
    input[1].stream = macro_changes

    -- starting attack and release values
    att = 0.01
    rel = 0.8

    output[1].action = ar(dyn{att=att}, dyn{rel=rel})
    output[2].action = ar(dyn{att=att}, dyn{rel=rel})
    output[3].action = ar(dyn{att=att}, dyn{rel=rel})
    output[4].action = ar(dyn{att=att}, dyn{rel=rel})

    clock.run(trigger_env)
end

function trigger_env()
    while true do
        for i=1,4 do
            output[outputs()]()
            -- when note timing gets too close, play them together
            if offset > 0.01 then clock.sleep(offset) end
        end

        -- when playing notes together, put time between chords
        if offset <= 0.01 then clock.sleep(offset*10) end
    end
end

function clamp(v, min, max)
    if v > max then return max
    elseif v < min then return min
    else return v end
end

function macro_changes()
    in1 = input[1].volts
    in2 = input[2].volts

    -- set release of all voices to input[2].volts
    local rel = clamp(in2*2, 0.1, 10)
    output[1].dyn.rel = rel
    output[2].dyn.rel = rel
    output[3].dyn.rel = rel
    output[4].dyn.rel = rel

    -- gap between notes is the distance between the values of input 1 and 2
    -- divide by 5 to get closer to something rhythmic
    offset = math.abs((in2-in1)/5)

    -- set steps between envelope trig sequence based on input 1
    local step = math.ceil(in1+0.5)
    -- add interest if the step count is 4, otherwise it gets stuck because #outputs == 4
    if step == 4 then step = math.ceil(math.random(12)) end
    outputs:step(step)
end