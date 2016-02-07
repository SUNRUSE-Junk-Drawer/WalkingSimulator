Function called with a string describing an error when one occurs.
Should halt the application and display the error.

	module.exports = (description) ->
		console.error description
		alert description
		throw new Error description