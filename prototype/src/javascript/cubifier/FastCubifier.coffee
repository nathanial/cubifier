_ = require 'underscore'

class FastCubifier
  constructor: (@renderCube) ->
    if !@renderCube
      throw "The RenderCube function is required"

  cubify: (@volume) ->
    {width,height,depth} = @volume.getDimensions()
    @vwidth = width
    @vheight = height
    @vdepth = depth

    copy = (x) -> JSON.parse(JSON.stringify(x))

    @cube =
      width: 1
      height: 1
      depth: 1
      offset: @volume.startPosition()
      buffer: []

    @renderCube(copy(@cube))
    blockCount = width*height*depth
    i = 0

    xcolumn = 0


    while i < blockCount
      {x,y,z} = @toCoordinates(i)
      if @volume.getVoxel(x,y,z)
        @appendToCube(i)
      else
        @renderCube(copy(@cube))
        while i < blockCount
          {x,y,z} = @toCoordinates(i)
          if @volume.getVoxel(x,y,z)
            break
          i += 1
        @cube =
          width: 1
          heigth: 1
          depth: 1
          offset:
            x:x
            y:y
            z:z
          buffer: _.clone(@cube.buffer)
      if @cube.width < 0 or @cube.height < 0 or @cube.depth < 0
        throw "Invalid Cube #{JSON.stringify(@cube)} #{x} #{y} #{z}"

      i += 1
    @renderCube(copy(@cube))

  insideCube: (i) ->
    {x,y,z} = @toCoordinates(i)
    return false unless x >= @cube.offset.x and x < @cube.width + @cube.offset.x
    return false unless y >= @cube.offset.y and y < @cube.height + @cube.offset.y
    return false unless z >= @cube.offset.z and z < @cube.depth + @cube.offset.z
    return true

  toCoordinates: (i) ->
    x = i % @vwidth
    y = Math.floor(i / @vwidth) % @vheight
    z = Math.floor((i / (@vwidth * @vheight)))
    {x:x, y:y, z:z}

  appendToCube: (i) ->
    {x,y,z} = @toCoordinates(i)
    if x == 0 and @cube.buffer.length > 0
      @finalizeBuffer()
    @cube.buffer.push(@toCoordinates(i))

  finalizeBuffer: ->
    xmin = Number.MAX_VALUE
    xmax = Number.MIN_VALUE
    ymin = Number.MAX_VALUE
    ymax = Number.MIN_VALUE
    zmin = Number.MAX_VALUE
    zmax = Number.MIN_VALUE

    originX = Number.MAX_VALUE
    originY = Number.MAX_VALUE
    originZ = Number.MAX_VALUE

    for {x,y,z} in @cube.buffer
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

      if x <= originX && y <= originY && z <= originZ
        originX = x
        originY = y
        originZ = z

    @cube.width = Math.abs(xmin - xmax) + 1
    @cube.height = Math.abs(ymin - ymax) + 1
    @cube.depth = Math.abs(zmin - zmax) + 1
    @cube.offset =
      x: originX
      y: originY
      z: originZ






module.exports = FastCubifier
