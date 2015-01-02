_ = require('underscore')

class Volume
  constructor: ->
    @blocks = {}

  append: (v) ->
    for position, value of v.blocks
      @blocks[position] = value

  firstX: ->
    xmin = Number.MAX_VALUE
    @forEach (x,y,z, value) ->
      if value
        if x < xmin
          xmin = x
    xmin

  firstY: ->
    ymin = Number.MAX_VALUE
    @forEach (x,y,z, value) ->
      if value
        if y < ymin
          ymin = y
    ymin

  firstZ: ->
    zmin = Number.MAX_VALUE
    @forEach (x,y,z, value) ->
      if value
        if z < zmin
          zmin = z
    zmin

  startPosition: ->
    xmin = Number.MAX_VALUE
    ymin = Number.MAX_VALUE
    zmin = Number.MAX_VALUE
    @forEach (x,y,z, value) ->
      if value
        if x <= xmin && y <= ymin && z <= zmin
          xmin = x
          ymin = y
          zmin = z
    {x:xmin,y:ymin,z:zmin}



  getWidth: ->
    xmin = Number.MAX_VALUE
    xmax = Number.MIN_VALUE
    @forEach (x,y,z, value) ->
      if value
        if x < xmin
          xmin = x
        if x > xmax
          xmax = x
    Math.abs(xmax - xmin) + 1

  getHeight: ->
    ymin = Number.MAX_VALUE
    ymax = Number.MIN_VALUE
    @forEach (x,y,z, value) ->
      if value
        if y < ymin
          ymin = y
        if y > ymax
          ymax = y
    Math.abs(ymax - ymin) + 1

  getDepth: ->
    zmin = Number.MAX_VALUE
    zmax = Number.MIN_VALUE
    @forEach (x,y,z, value) ->
      if value
        if z < zmin
          zmin = z
        if z > zmax
          zmax = z
    Math.abs(zmax - zmin) + 1

  setVoxel: (x,y,z, value) ->
    @blocks["#{x},#{y},#{z}"] = value

  getVoxel: (x,y,z) ->
    @blocks["#{x},#{y},#{z}"]

  forEach: (fn) ->
    for position,value of @blocks
      [x,y,z] = position.split(',')
      fn(parseInt(x),parseInt(y),parseInt(z), value)

  subtract: (cube) ->
    v = new Volume()
    inCount = 0
    outCount = 0
    @forEach (x,y,z, value) =>
      if value
        if not @insideCube(cube,x,y,z)
          outCount += 1
          v.setVoxel(x,y,z,value)
        else
          inCount += 1
    console.log("In Count", inCount, "Out Count", outCount)
    console.log("Block Count", _.keys(@blocks).length, _.keys(v.blocks).length)
    if inCount == 0
      console.log("Subtraction Failed", this, v, cube)
      throw "Subtraction failed"
    v

  insideCube: (cube, x, y, z) ->
    xWithin = cube.width + cube.offset.x > x >= cube.offset.x
    yWithin = cube.height + cube.offset.y > y >= cube.offset.y
    zWithin = cube.depth + cube.offset.z > z >= cube.offset.z

    return xWithin && yWithin && zWithin

module.exports = Volume
