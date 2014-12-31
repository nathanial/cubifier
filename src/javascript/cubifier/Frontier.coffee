_ = require('underscore')

class Frontier
  constructor: (@queue, @mesh)->

  append: (cursor) ->
    if cursor.x < 10 && cursor.y < 10 && cursor.z < 10
      box = @mesh.findBox(cursor)
      if box.material.wireframe
        @queue.push(cursor)

  expand: ({x,y,z}) ->
    @append {x:x+1, y:y, z:z}
    @append {x:x, y:y+1, z:z}
    @append {x:x, y:y, z:z+1}

    @append {x:x+1, y:y+1, z:z}
    @append {x:x+1, y:y, z:z+1}
    @append {x:x, y:y+1, z:z+1}
    @append {x:x+1, y:y+1, z:z+1}

  shift: ->
    @queue.shift()

  deduplicate: () ->
    @queue = _.filter @queue, (item) ->
      if item[0] >= 10
        return false
      if item[1] >= 10
        return false
      if item[2] >= 10
        return false
      return true

module.exports = Frontier
