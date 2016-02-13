# file

This is a module which abstracts reading files.  It should be used when they are
impractical to embed into the JavaScript.

While at present this performs AJAX, this module could be replaced to access
local files for non-web distribution.

    handleError = require "./handleError.litcoffee"

## arrayBuffer

- filename: The "real" location of the binary file to load.  (i.e. already 
            "require"-d)
- callback: A callback to execute with the ArrayBuffer loaded from the file on
            success.
            
    arrayBuffer = (path, callback) ->
        request = new XMLHttpRequest()
        request.open "GET", path, true
        request.responseType = "arraybuffer"
        request.onreadystatechange = ->
            if request.readyState is 4
                if request.status is 200                   
                    callback request.response
                else
                    handleError "Failed to load binary file " + path
            return
        request.send null
        return

    module.exports = { arrayBuffer }