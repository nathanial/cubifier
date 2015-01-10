_ = require 'underscore'

ITERATION_LIMIT = 1000

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

    @cubes = []

    {x,y,z} = @volume.startPosition()
    @cube =
      width: 1
      height: 1
      depth: 1
      expandable:
        x: true
        y: true
        z: true
      offsetX: x
      offsetY: y
      offsetZ: z
    @cubes.push(@cube)
    @updateCubeDimensions()
    @totalVoxels = @computeTotalVoxels()

    i = 0
    while not @complete()
      if not @expandCurrentCube()
        if @complete()
          break
        @createNewCube()
      i += 1
      if i >= ITERATION_LIMIT
        throw "ITERATION LIMIT EXCEEDED"
    for cube in @cubes
      @renderCube(cube)
    console.log("Cubes", @cubes)

  toCoordinates: (i) ->
    x = i % @vwidth
    y = Math.floor(i / @vwidth) % @vheight
    z = Math.floor((i / (@vwidth * @vheight)))
    {x:x, y:y, z:z}

  complete: ->
    @updateCubeDimensions()
    if @totalBlocks == @totalVoxels
      console.log("Total Blocks", @totalBlocks, @totalVoxels)
      return true
    return false

  expandCurrentCube: ->
    expanded = false
    for dim in ['x','y','z']
      if @cube.expandable[dim] and @canExpand(dim)
        @expand(dim)
        expanded = true
      else
        @cube.expandable[dim] = false
    if not expanded
      console.log("Failed To Expand", @cube)
    expanded


  createNewCube: ->
    @updateCubeDimensions()
    @cube = @newCube(@newStartPosition())
    @cubes.push(@cube)

  expand: (dimension) ->
    if dimension == 'x'
      @cube.width += 1
    else if dimension == 'y'
      @cube.height += 1
    else if dimension == 'z'
      @cube.depth += 1
    else
      throw "Unrecognized dimension #{dimension}"

  canExpand: (dimension) ->
    if dimension == 'x'
      canExpand = @cube.width < @vwidth and @fullFrontier('x') and not @taken('x')
    else if dimension == 'y'
      canExpand = @cube.height < @vheight and @fullFrontier('y') and not @taken('y')
    else if dimension == 'z'
      canExpand = @cube.depth < @vdepth and @fullFrontier('z') and not @taken('z')
    else
      throw "Unrecognized dimension #{dimension}"
    return canExpand

  updateCubeDimensions: ->
    @totalBlocks = 0
    for cube in @cubes
      @totalBlocks += (cube.width * cube.height * cube.depth)

  fullFrontier: (dimension) ->
    if dimension == 'x'
      return @fullXPlane()
    else if dimension == 'y'
      return @fullYPlane()
    else if dimension == 'z'
      return @fullZPlane()
    else
      throw "Not Recognized Dimension: #{dimension}"

  fullXPlane: ->
    x = @cube.width + @cube.offsetX
    for y in [0...@cube.height]
      for z in [0...@cube.depth]
        if not @volume.getVoxel(x, y + @cube.offsetY, z + @cube.offsetZ)
          return false
    return true

  fullYPlane:  ->
    y = @cube.height + @cube.offsetY
    for x in [0...@cube.width]
      for z in [0...@cube.depth]
        if not @volume.getVoxel(x + @cube.offsetX, y, z + @cube.offsetZ)
          return false
    return true

  fullZPlane:  ->
    z = @cube.depth + @cube.offsetZ
    for x in [0...@cube.width]
      for y in [0...@cube.depth]
        if not @volume.getVoxel(x + @cube.offsetX, y + @cube.offsetY, z)
          return false
    return true

  newCube: (startPosition) ->
    width: 1
    height: 1
    depth: 1
    expandable: {x: true, y: true, z: true}
    offsetX: startPosition.x
    offsetY: startPosition.y
    offsetZ: startPosition.z

  newStartPosition: ->
    lastCube = _.last(@cubes)
    x = 0
    while x < @vwidth
      y = 0
      while y < @vheight
        z = 0
        while z < @vdepth
          if @volume.getVoxel(x,y,z) and !_.any(@cubes, (c) => @insideCube(c, x,y,z))
            console.log("NEW START POSITION", x,y,z)
            return {x:x,y:y,z:z}
          z += 1
        y += 1
      x += 1
    throw "Couldn't find a new start position"

  insideCube: (cube, x,y,z) ->
    return false unless x >= cube.offsetX and x < cube.width + cube.offsetX
    return false unless y >= cube.offsetY and y < cube.height + cube.offsetY
    return false unless z >= cube.offsetZ and z < cube.depth + cube.offsetZ
    return true

  computeTotalVoxels: ->
    total = 0
    for blockKey in _.keys(@volume.blocks)
      block = @volume.blocks[blockKey]
      if block
        total += 1
    return total

  taken: (dimension) ->
    if dimension == 'x'
      x = @cube.width + @cube.offsetX
      for y in [0...@cube.height]
        for z in [0...@cube.depth]
          if _.any(@cubes, (c) => @insideCube(c, x, y + @cube.offsetY, z + @cube.offsetZ))
            return true
      return false
    else if dimension == 'y'
      y = @cube.height + @cube.offsetY
      for x in [0...@cube.width]
        for z in [0...@cube.depth]
          if _.any(@cubes, (c) => @insideCube(c, x + @cube.offsetX, y, z + @cube.offsetZ))
            return true
      return false
    else if dimension == 'z'
      z = @cube.depth + @cube.offsetZ
      for x in [0...@cube.width]
        for y in [0...@cube.depth]
          if _.any(@cubes, (c) => @insideCube(c, x + @cube.offsetX, y + @cube.offsetY, z))
            return true
      return false
    else
      throw "Not Implemented"




module.exports = FastCubifier
