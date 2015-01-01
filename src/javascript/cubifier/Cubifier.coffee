_ = require 'underscore'
Frontier = require './Frontier'

ITERATION_LIMIT = 1000

class Cubifier
  constructor: (@renderCube) ->
    if !@renderCube
      throw "The RenderCube function is required"

  cubify: (@volume) ->
    @vwidth = @volume.getWidth()
    @vheight = @volume.getHeight()
    @vdepth = @volume.getDepth()

    @cube = {width:0,height:0,depth:0}
    iterations = 0
    while @cubeNeedsExpansion()
      if iterations++ > ITERATION_LIMIT
        throw "Iteration Limit Exceeded"
      @expandCube()

  cubeNeedsExpansion: ->
    (@cube.width < @vwidth or
     @cube.height < @vheight or
     @cube.depth < @vdepth)

  expandCube: ->
    for dim in ['x','y','z']
      if @canExpand(dim)
        @expand(dim)

  canExpand: (dimension) ->
    if dimension == 'x'
      return @cube.width < @vwidth
    else if dimension == 'y'
      return @cube.height < @vheight
    else if dimension == 'z'
      return @cube.depth < @vdepth
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
    @checkCubeFitsInVolume()
    @renderCube(@cube)

  checkCubeFitsInVolume: ->
    if (@cube.width > @vwidth or
        @cube.height > @vheight or
        @cube.depth > @vdepth)
      throw "Cube does not fit in volume #{@cube.width} #{@cube.height} #{@cube.depth}"


module.exports = Cubifier
