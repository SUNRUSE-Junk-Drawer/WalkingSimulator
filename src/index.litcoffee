# index

This module is used to run the main event loop.  Please see the "game" module
for details.

    # Required for Webpack to include the stylesheet in the HTML.
    require "./index.sass"
    
    addEventListener "load", ->
        (require "./input/keyboard.litcoffee")()
    
        game = require "./game.litcoffee"
    
        game.load ->
            lastTimestamp = undefined
            tickProgress = 0
            
            # Ensures the game has ticked once before the first draw.
            game.tick()
            
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