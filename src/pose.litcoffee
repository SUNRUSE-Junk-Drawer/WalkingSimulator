# pose

A pose is an object where the keys are names of bones, and the values are
matrices positioning those bones.

    matrix = require "./matrix.litcoffee"

## create

- A skeletal .msc file's .coffee file.

Returns a new pose object containing the original "idle" pose of the cloud.

    create = (cloud) ->
        output = {}
        for bone in cloud.bones
            output[bone.name] = []
            matrix.copy bone.transform, output[bone.name]
        output
        
## copy

- A pose to copy from.
- A pose to copy to.

Copies all matrices from the input pose to the output pose.  Assumes all bone
names are the same.

    copy = (input, output) ->
        for key, value of input
            matrix.copy value, output[key]
        return
        
    module.exports = { create, copy }