
	module.exports = 

Call the "interpolate" property with a number to interpolate from, a number to
interpolate to, and a number specifying the alpha (0 is from, 1 is to) to return
the linearly interpolated, or extrapolated number.

		interpolate: (from, to, alpha) -> from + (to - from) * alpha