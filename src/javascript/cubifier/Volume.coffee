class Volume
  constructor: ->
    @blocks = {}

  getWidth: ->
    xmin = Number.MAX_VALUE
    xmax = Number.MIN_VALUE
    @forEach (x,y,z) ->
      if x < xmin
        xmin = x
      if x > xmax
        xmax = x
    console.log("XMIN,XMAX",xmin,xmax)
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
    console.log("BLocks", @blocks)
    for position,value of @blocks
      [x,y,z] = position.split(',')
      fn(x,y,z, value)

module.exports = Volume
