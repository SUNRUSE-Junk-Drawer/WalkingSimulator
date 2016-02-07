Required by Webpack to include resources in the HTML.

	require "./index.sass"

Main event loop.
The gameplay logic runs at a constant 20Hz "tick" rate, with linear 
interpolation for rendering.
	
	addEventListener "load", ->
		game = require "./game.litcoffee"
	
		game.load ->
            lastTimestamp = undefined
            tickProgress = 0
            
            run = (timestamp) ->
                if lastTimestamp isnt undefined
                    tickProgress += (timestamp - lastTimestamp) * 20 / 1000   
                
                lastTimestamp = timestamp
                
                # If more than a quarter second of ticks have occurred, don't
                # process any more than that, as the game was likely suspended.
                tickProgress = Math.min 5, tickProgress
            
                while tickProgress >= 1
                    game.tick()
                    tickProgress--

                game.draw tickProgress
                
                requestAnimationFrame run
                
                return
            
            requestAnimationFrame run
            
            return
            
        return