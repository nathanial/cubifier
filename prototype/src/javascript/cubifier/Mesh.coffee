_ = require('underscore')

class Mesh
  constructor: () ->
    @boxes = {}

  add: (x,y,z,box) ->
    @boxes["#{x},#{y},#{z}"] = box

  findBox: (cursor) ->
    @boxes["#{cursor.x},#{cursor.y},#{cursor.z}"]

  colorizeCube: (cube) ->
    console.log("Colorize", cube)
    color = '0x'+Math.floor(Math.random()*16777215).toString(16)
    for x in [0...cube.width]
      for y in [0...cube.height]
        for z in [0...cube.depth]
          box = @findBox({x:x+cube.offset.x,y:y+cube.offset.y,z:z+cube.offset.z})
          if not box
            console.log("Bad Cube", cube)
            continue
            #throw "Could not find box: #{x}, #{y}, #{z}"
          # if box.material.wireframe
          box.material.color.setHex(color)
          box.material.wireframe = false

module.exports = Mesh
