# track

A track definition is an object containing:

- navmesh: The require'd filename of a MSN file to load as a navmesh.
- spawns: An array of objects representing spawn points for players, containing:

+ transform: An initial transform to apply to characters spawning here.
+ section: A string specifying the name of the section containing the spawn.

- sections: An object, where keys name sections of the track and values are
            objects describing them containing:
            
+ clouds: An array of (require'd) filenames of MSC files to show in this 
          section, in order.  If fillrate becomes an issue, move mostly-obscured
          clouds to the end of the array.
          
A track instance is an object containing:

- navmesh: The navmesh instance.
- definition: The track definition this instance was created from.
          
    navmesh = require "./../navmesh.litcoffee"
    cloud = require "./../rendering/cloud.litcoffee"

## load

- A track definition.
- A callback executed with the track instance as an argument on success.

    load = (definition, callback) ->
        navmesh.load definition.navmesh, (navmeshInstance) ->
            clouds = {}
            for name, section of definition.sections
                for cloudPath in section.clouds
                    clouds[cloudPath] = null
            remainingClouds = (cloudPath for cloudPath, unused of clouds)
            
            loadNext = ->
                if remainingClouds.length
                    nextCloud = remainingClouds.shift()
                    cloud.load nextCloud, (cloudInstance) ->
                        clouds[nextCloud] = cloudInstance
                        loadNext()
                else
                    callback
                        navmesh: navmeshInstance
                        definition: definition
                        clouds: clouds      
                return
                        
            loadNext()
            return
        return

## tick

- A track instance.

    tick = (instance) ->
        return
    
## preDraw

- A track instance.
- The progress through the current frame, where 0 is the start and 1 is the end.

This should be called once per draw frame, before calling "draw" for this 
character instance.

    preDraw = (instance) ->
        return

## draw

- A track instance.
- A string specifying the name of the section containing the camera.

This can be called multiple times per frame to draw the character in multiple
viewports.  Call "preDraw" first.

    draw = (instance, section) ->
        for sectionCloud in instance.definition.sections[section].clouds
            cloud.draw instance.clouds[sectionCloud]
        return

    module.exports = { load, tick, preDraw, draw }