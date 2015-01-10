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

    @cubes = []

    @cube =
      width: 1
      height: 1
      depth: 1
      expandable:
        x: true
        y: true
        z: true
      offset: @volume.startPosition()
    @cubes.push(@cube)


    while not @complete()
      if not @expandCurrentCube()
        if @complete()
          break
        @createNewCube()
    for cube in @cubes
      @renderCube(cube)

  toCoordinates: (i) ->
    x = i % @vwidth
    y = Math.floor(i / @vwidth) % @vheight
    z = Math.floor((i / (@vwidth * @vheight)))
    {x:x, y:y, z:z}

  complete: ->
    @updateCubeDimensions()
    (@totalCubeWidth >= @vwidth and
     @totalCubeHeight >=  @vheight and
     @totalCubeDepth >= @vdepth)

  expandCurrentCube: ->
    expanded = false
    for dim in ['x','y','z']
      if @cube.expandable[dim] and @canExpand(dim)
        @expand(dim)
        expanded = true
      else
        @cube.expandable[dim] = false
    expanded

  renderCurrentCube: ->
    @renderCube(@cube)

  createNewCube: ->
    throw "Not Implemented"

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
      canExpand = @cube.width < @vwidth and @fullFrontier('x')
    else if dimension == 'y'
      canExpand = @cube.height < @vheight and @fullFrontier('y')
    else if dimension == 'z'
      canExpand = @cube.depth < @vdepth and @fullFrontier('z')
    else
      throw "Unrecognized dimension #{dimension}"
    return canExpand

  updateCubeDimensions: ->
    width = 0
    height = 0
    depth = 0

    for cube in @cubes
      width += cube.width
      height += cube.height
      depth += cube.depth

    @totalCubeWidth = width
    @totalCubeHeight = height
    @totalCubeDepth = depth

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
    x = @cube.width + @cube.offset.x
    for y in [0...@cube.height]
      for z in [0...@cube.depth]
        if not @volume.getVoxel(x,y,z)
          return false
    return true

  fullYPlane:  ->
    y = @cube.height + @cube.offset.y
    for x in [0...@cube.width]
      for z in [0...@cube.depth]
        if not @volume.getVoxel(x,y,z)
          return false
    return true

  fullZPlane:  ->
    z = @cube.depth + @cube.offset.z
    for x in [0...@cube.width]
      for y in [0...@cube.depth]
        if not @volume.getVoxel(x,y,z)
          return false
    return true

module.exports = FastCubifier
