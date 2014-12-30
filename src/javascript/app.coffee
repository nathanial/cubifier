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
  console.log(x,y,z)
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

#color = '#'+Math.floor(Math.random()*16777215).toString(16)

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

cubify = (volume) ->
  cursor = [0,0,0]
  x = 0
  while x++ < 10
    y = 0
    while y++ < 10
      z = 0
      while z++ < 10
        do ->
          cursor = [x-1,y-1,z-1]
          cube = findCube(cursor)
          setColor = ->
            cube.material.color.setHex(0xFF0000)
            cube.material.wireframe = false
            render()
          setTimeout(setColor, (x*y*z) * 10)

controls = new TrackballControls(camera)
controls.addEventListener('change', render)

volume = createCubeTestVolume()
renderVolume(volume)
render()
animate()
cubify(volume)
