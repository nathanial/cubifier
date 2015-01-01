_ = require('underscore')

class Mesh
  constructor: () ->
    @boxes = {}

  add: (x,y,z,box) ->
    @boxes["#{x},#{y},#{z}"] = box

  findBox: (cursor) ->
    @boxes["#{cursor.x},#{cursor.y},#{cursor.z}"]

  colorizeCube: (cube) ->
    color = '0x'+Math.floor(Math.random()*16777215).toString(16)
    for x in _.range(0, cube.width+1)
      for y in _.range(0, cube.height+1)
        for z in _.range(0, cube.depth+1)
          box = @findBox({x:x,y:y,z:z})
          if box.material.wireframe
            box.material.color.setHex(color)
            box.material.wireframe = false

module.exports = Mesh
