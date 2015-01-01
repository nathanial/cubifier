class Volume
  constructor: ->
    @blocks = {}

  append: (v) ->
    for position, value of v.blocks
      @blocks[position] = value

  startX: ->
    xmin = Number.MAX_VALUE
    @forEach (x,y,z) ->
      if x < xmin
        xmin = x
    xmin

  startY: ->
    ymin = Number.MAX_VALUE
    @forEach (x,y,z) ->
      if y < ymin
        ymin = y
    ymin

  startZ: ->
    zmin = Number.MAX_VALUE
    @forEach (x,y,z) ->
      if z < zmin
        zmin = z
    zmin

  getWidth: ->
    xmin = Number.MAX_VALUE
    xmax = Number.MIN_VALUE
    @forEach (x,y,z) ->
      if x < xmin
        xmin = x
      if x > xmax
        xmax = x
    Math.abs(xmax - xmin) + 1

  getHeight: ->
    ymin = Number.MAX_VALUE
    ymax = Number.MIN_VALUE
    @forEach (x,y,z) ->
      if y < ymin
        ymin = y
      if y > ymax
        ymax = y
    Math.abs(ymax - ymin) + 1

  getDepth: ->
    zmin = Number.MAX_VALUE
    zmax = Number.MIN_VALUE
    @forEach (x,y,z) ->
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
    @forEach (x,y,z, value) =>
      if not @insideCube(cube,x,y,z)
        v.setVoxel(x,y,z,value)
    v

  insideCube: (cube, x, y, z) ->
    return false if x >= cube.width + cube.offset.x or x < cube.offset.x
    return false if y >= cube.height + cube.offset.y or y < cube.offset.y
    return false if z >= cube.depth + cube.offset.z or z < cube.offset.z
    return true

module.exports = Volume
