_ = require 'underscore'
Frontier = require './Frontier'

ITERATION_LIMIT = 20

class Cubifier
  constructor: (@renderCube) ->
    if !@renderCube
      throw "The RenderCube function is required"

  cubify: (@volume) ->
    @vwidth = @volume.getWidth()
    @vheight = @volume.getHeight()
    @vdepth = @volume.getDepth()

    @cube =
      width:1
      height:1
      depth:1
      offset:
        x: @volume.startX()
        y: @volume.startY()
        z: @volume.startZ()

    @checkCubeFitsInVolume(@cube)
    @renderCube(@cube)
    iterations = 0
    while @cubeNeedsExpansion()
      if iterations++ > ITERATION_LIMIT
        throw "Iteration Limit Exceeded"
      if not @expandCube()
        @newCube(@uncoveredDimension())
    if not @allOfVolumeIsCovered()
      throw "Missed some volume"

  newCube: (dimension) ->
    @volume = @volume.subtract(@cube)
    @cube = {width:1,height:1,depth:1, offset: {x:@volume.startX(), y:@volume.startY(), z: @volume.startZ()}}
    @vwidth = @volume.getWidth()
    @vheight = @volume.getHeight()
    @vdepth = @volume.getDepth()
    console.log("New Cube", @cube)
    console.log("New Volume", @vwidth, @vheight, @vdepth, JSON.parse(JSON.stringify(@volume)))

  uncoveredDimension: ->
    return 'x' if @cube.width < @vwidth
    return 'y' if @cube.height < @vheight
    return 'z' if @cube.depth < @vdepth
    throw "All dimensions are covered"

  cubeNeedsExpansion: ->
    (@cube.width < @vwidth or
     @cube.height < @vheight or
     @cube.depth < @vdepth)

  expandCube: ->
    expanded = false
    for dim in ['x','y','z']
      if @canExpand(dim)
        @expand(dim)
        expanded = true
    expanded

  canExpand: (dimension) ->
    if dimension == 'x'
      return @cube.width < @vwidth and @checkExpandedCube('x', 1)
    else if dimension == 'y'
      return @cube.height < @vheight and @checkExpandedCube('y',1)
    else if dimension == 'z'
      return @cube.depth < @vdepth and @checkExpandedCube('z',1)
    else
      throw "Unrecognized dimension #{dimension}"

  expand: (dimension) ->
    if dimension == 'x'
      @cube.width += 1
    else if dimension == 'y'
      @cube.height += 1
    else if dimension == 'z'
      @cube.depth += 1
    else
      throw "Unrecognized dimension #{dimension}"
    if not @checkCubeFitsInVolume(@cube)
      throw "Overexpanded"
    @renderCube(@cube)

  checkCubeFitsInVolume: (cube)->
    if (cube.width > @vwidth or
        cube.height > @vheight or
        cube.depth > @vdepth)
      return false
    for x in [0...cube.width]
      for y in [0...cube.height]
        for z in [0...cube.depth]
          if not @volume.getVoxel(x+cube.offset.x,y+cube.offset.y,z+cube.offset.z)
            console.log(x + cube.offset.x,y + cube.offset.y,z + cube.offset.z, "Doesn't fit", @volume.blocks)
            return false
    return true

  checkExpandedCube: (dim, amount) ->
    expandedCube = _.clone(@cube)
    if dim == 'x'
      _.extend(expandedCube, {width: expandedCube.width+1})
    if dim == 'y'
      _.extend(expandedCube, {height: expandedCube.height+1})
    if dim == 'z'
      _.extend(expandedCube, {depth: expandedCube.depth+1})
    @checkCubeFitsInVolume(expandedCube)

  allOfVolumeIsCovered: ->
    cube = @cube
    for position,value of @volume.blocks
      [x,y,z] = position.split(',')
      if value and not @withinCube(cube, parseInt(x), parseInt(y), parseInt(z))
        console.log("Missing", x,y,z)
        return false
    return true

  withinCube: (cube, x,y,z) ->
    return false unless x >= cube.offset.x and x < cube.width + cube.offset.x
    return false unless y >= cube.offset.y and y < cube.height + cube.offset.y
    return false unless z >= cube.offset.z and z < cube.depth + cube.offset.z
    return true

module.exports = Cubifier
