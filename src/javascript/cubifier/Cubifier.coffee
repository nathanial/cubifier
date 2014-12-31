_ = require 'underscore'
Frontier = require './Frontier'


class Cubifier
  constructor: (@mesh, @render) ->

  cubify: (state) ->
    {frontier,cube} = state
    cursor = frontier.shift()
    if !cursor
      return
    box = @mesh.findBox(cursor)
    console.log(cursor)

    newFrontier = new Frontier(frontier.queue, @mesh)

    if box.material.wireframe
      newFrontier.expand(cursor)
      color = '0x'+Math.floor(Math.random()*16777215).toString(16)
      box.material.color.setHex(color)
      box.material.wireframe = false
      @render()

    newFrontier.deduplicate()

    newState = _.extend({}, state, {frontier: newFrontier})
    setTimeout((=> @cubify(newState)), 10)

module.exports = Cubifier
