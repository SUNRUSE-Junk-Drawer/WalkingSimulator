
    matrix = require "./../../matrix.litcoffee"
    
    spawnATransform = []
    matrix.identity spawnATransform

    module.exports = 
        spawns: [
            transform: spawnATransform
            section: "grid"
        ]

        navmesh: require "./navmesh.msn"
        
        sections:
            grid:
                clouds: [
                    require "./tunnel.msc"
                    require "./geometry.msc"
                    require "./sky.msc"
                ]
            hairpin:
                clouds: [
                    require "./tunnel.msc"
                    require "./geometry.msc"
                    require "./sky.msc"
                ]
            river: 
                clouds: [
                    require "./tunnel.msc"
                    require "./geometry.msc"
                    require "./sky.msc"                
                ]
            tunnel:
                clouds: [
                    require "./tunnel.msc"
                    require "./geometry.msc"
                    require "./sky.msc"
                ]
            tube:
                clouds: [
                    require "./tunnel.msc"
                    require "./geometry.msc"
                    require "./sky.msc"
                ]
            climb:
                clouds: [
                    require "./tunnel.msc"
                    require "./geometry.msc"
                    require "./sky.msc"
                ]
            bridge:
                clouds: [
                    require "./tunnel.msc"
                    require "./geometry.msc"
                    require "./sky.msc"
                ]
        