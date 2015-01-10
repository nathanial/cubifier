class FastCubifier
  constructor: (@renderCube) ->
    if !@renderCube
      throw "The RenderCube function is required"

  cubify: (@volume) ->
    {width,height,depth} = @volume.getDimensions()
    @vwidth = width
    @vheight = height
    @vdepth = depth

    @cube =
      width: 1
      height: 1
      depth: 1
      offset: @volume.startPosition()
    @renderCube(@cube)
    blockCount = width*height*depth
    i = 0

    xcolumn = 0
    while i < blockCount
      {x,y,z} = @toCoordinates(i)
      if not @volume.getVoxel(x,y,z)
         
        throw "Break"
      @expandCube(x,y,z)
      @renderCube(@cube)
      i += 1
    @renderCube(@cube)

  insideCube: (i) ->
    {x,y,z} = @toCoordinates(i)
    return false unless x >= @cube.offset.x and x < @cube.width + @cube.offset.x
    return false unless y >= @cube.offset.y and y < @cube.height + @cube.offset.y
    return false unless z >= @cube.offset.z and z < @cube.depth + @cube.offset.z
    return true

  expandCube: (x,y,z) ->
    @cube.width = x + 1
    @cube.height = y + 1
    @cube.depth = z + 1

  newCube: (i) ->
    coords = @toCoordinates(i)
    @renderCube @cube
    throw "Not Implemented"



  toCoordinates: (i) ->
    x = i % @vwidth
    y = Math.floor(i / @vwidth) % @vheight
    z = Math.floor((i / (@vwidth * @vheight)))
    {x:x, y:y, z:z}


module.exports = FastCubifier
