--- Remainders (version 0.2-draft)
-- https://llllllll.co/t/remainders-a-modulo-gesture-generator-for-crow/40084
-- modulo gesture generator/cv divider
-- Input a voltage and get 4 folded outputs based on a simple modulo operation. Perfect for your one knob to rule them all.

-- in 1: Gesture (CV) in (Great for knobs/joysticks)
-- in 2: Rotate in (Rotates the outputs based on incoming cv, momentary)
-- out 1-4: Voltages being folded 1 to 4 times, top to bottom.

-- Comment next line (with two hyphens) if you don't have a Disting EX.
disting = true
disting_algorithm = 1
disting_param_offset = 6

param1 = 0.0
param2 = 0.0
param1_min = 0.0
param1_max = 0.0
param2_min = 0.0
param2_max = 0.0
param1_normalized = 0.0
param2_normalized = 0.0

-- Configure divisions per port
outputs_folds = {3,5,8,13}
disting_folds = {4,6,7,10}

-- Configure input voltage range
voltage_range = 10

ii.disting.event = function(event, value)
    if event.name == 'parameter' then
        if (event.arg == 1) then
            param1 = value
        elseif (event.arg == 2) then
            param2 = value
        end
    end
    if event.name == 'parameter_min' then
        if (event.arg == 1) then
            param1_min = value
        elseif (event.arg == 2) then
            param2_min = value
        end
    end
    if event.name == 'parameter_max' then
        if (event.arg == 1) then
            param1_max = value
        elseif (event.arg == 2) then
            param2_max = value
        end
    end
end

function init()
    input[1].mode('stream', 0.005)
    input[2].mode('stream', 0.005)
    for n=1,4 do output[n].slew = 0.005 end
    if disting then
        ii.fastmode(true)
        ii.disting.algorithm(disting_algorithm)
        ii.disting.get( 'parameter_min', 1 )
        ii.disting.get( 'parameter_max', 1 )
        ii.disting.get( 'parameter_min', 2 )
        ii.disting.get( 'parameter_max', 2 )
    end
end

map_range = function(a1, a2, b1, b2, s)
    return b1 + (s - a1) * (b2 - b1) / (a2 - a1)
end

rotate = function(rotation, n)
    return (n + math.abs(rotation) - 1) % 4 + 1
end

calc_remainder = function(v, folds)
    fold_voltage = voltage_range / folds
    remainder = (v % fold_voltage) * folds
    return remainder
end

input[1].stream = function(v)
    if disting then
        ii.disting.get('parameter', 1)
        ii.disting.get('parameter', 2)
        param1_normalized = map_range(param1_min, param1_max, 0, 10, param1)
        param2_normalized = map_range(param2_min, param2_max, 0, 10, param2)
        v = v + param1_normalized
    end

    rotation = math.ceil(input[2].volts + param2_normalized / 2)

    for n=1,4 do
        p = rotate(rotation, n)

        folds = outputs_folds[n]
        remainder = calc_remainder(v, folds)
        output[p].volts = remainder

        if disting then
            folds = disting_folds[n]
            remainder = calc_remainder(v, folds)
            ii.disting.parameter(p + disting_param_offset, remainder)
        end
    end
end