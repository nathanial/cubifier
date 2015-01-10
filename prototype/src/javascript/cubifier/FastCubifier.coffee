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
    if not expanded
      console.log("Failed To Expand", @cube)
    expanded

  renderCurrentCube: ->
    @renderCube(@cube)

  createNewCube: ->
    @updateCubeDimensions()
    @renderCube(@cube)
    if @totalCubeWidth < @vwidth
      @createNewCubeOnXPlane()
    else if @totalCubeHeight < @vheight
      @createNewCubeOnYPlane()
    else if @totalCubeDepth < @vdepth
      @createNewCubeOnZPlane()
    else
      throw "Couldn't find a place to create a new cube"

  expand: (dimension) ->
    if dimension == 'x'
      @cube.width += 1
    else if dimension == 'y'
      @cube.height += 1
    else if dimension == 'z'
      @cube.depth += 1
    else
      throw "Unrecognized dimension #{dimension}"

  createNewCubeOnXPlane: ->
    newCube =
      width: 1
      height: 1
      depth: 1
      expandable:
        x: true
        y: true
        z: true
      offsetX: @cube.width + @cube.offsetX
      offsetY: 0
      offsetZ: 0
    @cube = newCube
    console.log("X Plane", newCube)
    @cubes.push(@cube)

  createNewCubeOnYPlane: ->
    newCube =
      width: 1
      height: 1
      depth: 1
      expandable: {x: true, y: true, z: true}
      offsetX: 0
      offsetY: @cube.height + @cube.offsetY
      offsetZ: 0
    @cube = newCube
    console.log("Y Plane", newCube)
    @cubes.push(@cube)

  createNewCubeOnZPlane: ->
    newCube =
      width: 1
      height: 1
      depth: 1
      expandable: {x: true, y: true, z: true}
      offsetX: 0
      offsetY: 0
      offsetZ: @cube.depth + @cube.offsetZ
    @cube = newCube
    console.log("Z Plane", newCube)
    @cubes.push(@cube)

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

module.exports = FastCubifier
