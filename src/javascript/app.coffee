_ = require('underscore')
THREE = require('three')
TrackballControls = require('./TrackballControls')

scene = new THREE.Scene()
camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )

renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

cubes = {}

createCube = (x,y,z, color) ->
  geometry = new THREE.BoxGeometry( 1, 1, 1 )
  material = new THREE.MeshBasicMaterial( { color: color, wireframe: true } )
  cube = new THREE.Mesh( geometry, material )
  scene.add( cube )
  cube.position.x = x
  cube.position.y = y
  cube.position.z = z
  cubes["#{x},#{y},#{z}"] = cube

renderVolume = (volume) ->
  for location in _.keys(volume)
    [x,y,z] = location.split(',')
    createCube(x,y,z)

createCubeTestVolume = ->
  volume = {}
  x = 0
  while x++ < 10
    y = 0
    while y++ < 10
      z = 0
      while z++ < 10
        volume["#{x-1},#{y-1},#{z-1}"] = 1
  volume

camera.position.x = 5
camera.position.y = -10
camera.position.z = -10

animate = ->
  requestAnimationFrame(animate)
  controls.update()

render = ->
  renderer.render( scene, camera )

findBox = (cursor) ->
  cubes["#{cursor.x},#{cursor.y},#{cursor.z}"]


class Frontier
  constructor: (@queue)->

  append: (cursor) ->
    if cursor.x < 10 && cursor.y < 10 && cursor.z < 10
      cube = findBox(cursor)
      if cube.material.wireframe
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


cubify = (state) ->
  {frontier,cube} = state
  cursor = frontier.shift()
  if !cursor
    return
  box = findBox(cursor)
  console.log(cursor)

  newFrontier = new Frontier(frontier.queue)

  if box.material.wireframe
    newFrontier.expand(cursor)
    color = '0x'+Math.floor(Math.random()*16777215).toString(16)
    box.material.color.setHex(color)
    box.material.wireframe = false
    render()

  newFrontier.deduplicate()

  newState = _.extend({}, state, {frontier: newFrontier})
  setTimeout((-> cubify(newState)), 10)

controls = new TrackballControls(camera)
controls.addEventListener('change', render)

volume = createCubeTestVolume()
renderVolume(volume)
render()
animate()
cubify
  volume: volume,
  cursor: {x:0,y:0,z:0}
  frontier: new Frontier([{x:0,y:0,z:0}])
  cube: {width:0,height:0,depth:0}
