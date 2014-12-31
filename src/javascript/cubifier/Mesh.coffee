class Mesh
  constructor: () ->
    @cubes = {}

  add: (x,y,z,cube) ->
    @cubes["#{x},#{y},#{z}"] = cube

  findBox: (cursor) ->
    @cubes["#{cursor.x},#{cursor.y},#{cursor.z}"]

module.exports = Mesh
