# misc

## interpolate

- from: A number to interpolate from.
- to: A number to interpolate to.
- alpha: A number, where "0" is "from" and "1" is "to".

Returns the linear interpolation or extrapolation from "from" to "to".

    interpolate = (from, to, alpha) -> from + (to - from) * alpha
    
## wrapAngle

- radians: A number of radians to wrap.

Returns the input wrapped to the 0...2PI range.

    wrapAngle = (radians) -> radians - (Math.PI * 2 * Math.floor (radians / (Math.PI * 2)))
    
## interpolateAngle

- from: A number of radians to interpolate from.
- to: A number of radians to interpolate to.
- alpha: A number, where "0" is "from" and "1" is "to".

Returns the linear interpolation or extrapolation from "from" to "to".  Can
shortcut over the 0/2PI boundary.

    interpolateAngle = (from, to, alpha) -> 
        from = wrapAngle from
        to = wrapAngle to
        if from < Math.PI / 2 and to > Math.PI * 1.5
            to -= Math.PI * 2
        else if to < Math.PI / 2 and from > Math.PI * 1.5
            to += Math.PI * 2
        wrapAngle (from + (to - from) * alpha)
        
    module.exports = { interpolate, wrapAngle, interpolateAngle }