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

  empty: ->
    {width,height,depth} = @getDimensions()
    return width == 0 || height == 0 || depth == 0


  getDimensions: ->
    noBlocks = true
    zmin = ymin = xmin = Number.MAX_VALUE
    zmax = ymax = xmax = Number.MIN_VALUE
    @forEach (x,y,z, value) ->
      if value
        noBlocks = false
        if x < xmin
          xmin = x
        if x > xmax
          xmax = x
        if y < ymin
          ymin = y
        if y > ymax
          ymax = y
        if z < zmin
          zmin = z
        if z > zmax
          zmax = z
    if noBlocks
      return {
        width: 0
        height: 0
        depth: 0
      }
    return {
      width: Math.abs(xmax - xmin) + 1,
      height: Math.abs(ymax - ymin) + 1,
      depth: Math.abs(zmax - zmin) + 1
    }

  setVoxel: (x,y,z, value) ->
    @blocks["#{x},#{y},#{z}"] = value

  getVoxel: (x,y,z) ->
    @blocks["#{x},#{y},#{z}"]

  forEach: (fn) ->
    for position,value of @blocks
      [x,y,z] = position.split(',')
      fn(parseInt(x),parseInt(y),parseInt(z), value)

  subtract: (cube) ->
    @forEach (x,y,z, value) =>
      if @insideCube(cube,x,y,z)
        @setVoxel(x,y,z,0)

  insideCube: (cube, x, y, z) ->
    xWithin = cube.width + cube.offset.x > x >= cube.offset.x
    yWithin = cube.height + cube.offset.y > y >= cube.offset.y
    zWithin = cube.depth + cube.offset.z > z >= cube.offset.z

    return xWithin && yWithin && zWithin

module.exports = Volume
