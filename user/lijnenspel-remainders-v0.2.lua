---- https://llllllll.co/t/remainders-a-modulo-gesture-generator-for-crow/40084
--- Remainders (version 0.2-draft)
-- modulo gesture generator/cv divider
-- Input a voltage and get 4 folded outputs based on a simple modulo operation. Perfect for your one knob to rule them all.

-- in 1: Gesture (CV) in (Great for knobs/joysticks)
-- in 2: Rotate in (Rotates the outputs based on incoming cv, momentary)
-- out 1-4: Voltages being folded 1 to 4 times, top to bottom.

-- Comment next two lines (with two hyphens) if you don't have TXi or TXo.
-- txi = true
-- txo = true

-- Configure divisions per port
outputs_folds = {3,5,8,13}
txo_folds = {4,6,7,10}

param1 = 0.0
param2 = 0.0

function init()
    input[1].mode( 'stream', 0.02 )
    for n=1,4 do output[n].slew = 0.01 end
end

ii.txi.event = function(event, value)
    if event.name == 'param' then
        if (event.arg == 1) then
            param1 = value
        elseif (event.arg == 2) then
            param2 = value
        end
    end
end

rotate = function(rotation, n)
    return (n + rotation - 1) % 4 + 1
end

calc_remainder = function(v, folds)
    fold_voltage = 10 / folds
    remainder = (v % fold_voltage) * folds
    return remainder
end

input[1].stream = function(v)
    if txi then
        ii.txi[1].get('param', 1)
        ii.txi[1].get('param', 2)
        v = v + param1
    end

    rotation = math.ceil(input[2].volts + param2 / 2.5)

    for n=1,4 do
        p = rotate(rotation, n)

        folds = outputs_folds[n]
        remainder = calc_remainder(v, folds)
        output[p].volts = remainder

        if txo then
            folds = txo_folds[n]
            remainder = calc_remainder(v, folds)
            ii.txo[1].cv_set(p, remainder)
        end
    end
end