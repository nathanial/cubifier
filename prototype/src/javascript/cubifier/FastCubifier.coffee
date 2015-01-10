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

    #
    #@renderCube(copy(@cube))
    blockCount = width*height*depth

    i = 0

    strips = []
    buffer = []
    while i < blockCount
      {x,y,z} = @toCoordinates(i)
      if x == 0 && buffer.length > 0
        strips.push
          origin: @toCoordinates(buffer[0])
          length: buffer.length
        buffer = []
        @renderStrip(_.last(strips))
      buffer.push(i)
      i += 1
    if buffer.length > 0
      strips.push
        origin: @toCoordinates(buffer[0])
        length: buffer.length
      @renderStrip(_.last(strips))


  toCoordinates: (i) ->
    x = i % @vwidth
    y = Math.floor(i / @vwidth) % @vheight
    z = Math.floor((i / (@vwidth * @vheight)))
    {x:x, y:y, z:z}

  renderStrip: (strip) ->
    @renderCube
      width: strip.length
      height: 1
      depth: 1
      offset: strip.origin




module.exports = FastCubifier
