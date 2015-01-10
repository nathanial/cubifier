
class FastCubifier
  constructor: (@renderCube) ->
    if !@renderCube
      throw "The RenderCube function is required"

  cubify: (@volume) ->
    {width,height,depth} = @volume.getDimensions()
    @vwidth = width
    @vheight = height
    @depth = depth

    @cube =
      width: 1
      height: 1
      depth: 1
      offset: @volume.startPosition()
    @renderCube(@cube)
    blockCount = width*height*depth
    i = 0
    while i < blockCount
      if not @insideCube(i)
        if not @expandCube(i)
          @newCube(i)
      i += 1

  insideCube: (i) ->
    {x,y,z} = @toCoordinates(i)
    return false unless x >= @cube.offset.x and x < @cube.width + @cube.offset.x
    return false unless y >= @cube.offset.y and y < @cube.height + @cube.offset.y
    return false unless z >= @cube.offset.z and z < @cube.depth + @cube.offset.z
    return true

  expandCube: (i) -> 
    false

  newCube: (i) ->
    coords = @toCoordinates(i)
    @renderCube
      width: 1
      height: 1
      depth: 1
      offset: coords

  toCoordinates: (i) ->
    x = i % @vwidth
    y = Math.floor(i / @vwidth) % @vheight
    z = Math.floor((i / (@vwidth * @vheight)))
    {x:x, y:y, z:z}


module.exports = FastCubifier
