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

findCube = (cursor) ->
  cubes["#{cursor[0]},#{cursor[1]},#{cursor[2]}"]

deduplicate = (queue) ->
  _.filter queue, (item) ->
    if item[0] >= 10
      return false
    if item[1] >= 10
      return false
    if item[2] >= 10
      return false
    return true


appendToFrontier = (x,y,z,frontier) ->
  if x < 10 && y < 10 && z < 10
    cube = findCube([x,y,z])
    if cube.material.wireframe
      frontier.push([x,y,z])

createFrontier = (x,y,z,frontier) ->
  appendToFrontier(x+1,y,z,frontier)
  appendToFrontier(x,y+1,z,frontier)
  appendToFrontier(x,y,z+1,frontier)

  appendToFrontier(x+1,y+1,z, frontier)
  appendToFrontier(x+1,y,z+1, frontier)
  appendToFrontier(x,y+1,z+1, frontier)
  appendToFrontier(x+1,y+1,z+1, frontier)

cubify = (volume, frontier=[[0,0,0]]) ->
  cursor = frontier.shift()
  if !cursor
    return
  cube = findCube(cursor)

  if cube.material.wireframe
    createFrontier(cursor[0],cursor[1],cursor[2],frontier)
    frontier = deduplicate(frontier)

  console.log(cursor)

  color = '0x'+Math.floor(Math.random()*16777215).toString(16)
  cube.material.color.setHex(color)
  cube.material.wireframe = false
  render()
  setTimeout((-> cubify(volume,_.clone(frontier))), 10)

controls = new TrackballControls(camera)
controls.addEventListener('change', render)

volume = createCubeTestVolume()
renderVolume(volume)
render()
animate()
cubify(volume)
