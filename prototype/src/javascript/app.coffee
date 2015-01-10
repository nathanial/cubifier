_ = require('underscore')
THREE = require('three')
TrackballControls = require('./TrackballControls')
Mesh = require('./cubifier/Mesh')
Cubifier = require('./cubifier/Cubifier')
FastCubifier = require('./cubifier/FastCubifier')
Volume = require('./cubifier/Volume')

scene = new THREE.Scene()
camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )

renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

mesh = new Mesh

createCube = (x,y,z, color) ->
  geometry = new THREE.BoxGeometry( 1, 1, 1 )
  material = new THREE.MeshBasicMaterial( { color: color, wireframe: true } )
  cube = new THREE.Mesh( geometry, material )
  scene.add( cube )
  cube.position.x = x
  cube.position.y = y
  cube.position.z = z
  mesh.add(x,y,z,cube)

renderVolume = (volume) ->
  volume.forEach (x,y,z,value) ->
    createCube(x,y,z)

createVolume = (xw, yw, zw, offset={x:0,y:0,z:0}) ->
  volume = new Volume()
  for x in [0...xw]
    for y in [0...yw]
      for z in [0...zw]
        volume.setVoxel(x+offset.x,y+offset.y,z+offset.z, true)
  volume

createIrregularVolume = ->
  volume = new Volume()
  volume.append(createVolume(5,5,5))
  volume.append(createVolume(5,10,10, {x:5,y:0,z:0}))
  volume.append(createVolume(5,10,1, {x:1,y:0,z:0}))
  volume.append(createVolume(10,1,1,{x:-10,y:1,z:1}))
  volume.append(createVolume(1,1,100, {x:20,y:1,z:1}))
  volume

createDonutVolume = ->
  volume = new Volume()
  volume.append(createVolume(20,5,5, {x:0,y:0,z:0}))
  volume.append(createVolume(5,20,5, {x:15,y:5,z:0}))
  volume.append(createVolume(20,5,5, {x:0,y:20,z:0}))
  volume.append(createVolume(5,20,5, {x:0,y:0,z:0}))
  volume.append(createVolume(20,25,1, {x:0,y:0,z:5}))
  volume

createGiantSurface = ->
  volume = new Volume()
  for x in [0..100]
    for y in [0..100]
      volume.append(createVolume(1,1,1, {x:x,y:y, z:0}))
  volume


createSprinkles = ->
  volume = new Volume()
  volume.append(createVolume(1,1,1, {x:0,y:0,z:-1}))
  volume.append(createVolume(1,1,1, {x:1,y:1,z:-1}))
  volume.append(createVolume(1,1,2, {x:19,y:0,z:-2}))
  volume.append(createVolume(1,1,2, {x:19,y:6,z:-2}))
  volume

createDonutWithSprinkles = ->
  volume = new Volume()
  volume.append(createDonutVolume())
  volume.append(createSprinkles())
  volume

createRandomShape = ->
  volume = new Volume()
  for x in [0..40]
    for y in [0..40]
      z = Math.round(Math.random() * 5)
      volume.append(createVolume(1,1,1, {x:x, y:y, z:z}))
  volume


camera.position.x = 5
camera.position.y = -10
camera.position.z = -10

animate = ->
  requestAnimationFrame(animate)
  controls.update()

render = ->
  renderer.render( scene, camera )

space = 0
renderCube = (cube) ->
  cubeCopy = _.clone(cube)
  doRender = ->
    mesh.colorizeCube(cubeCopy)
    render()
  setTimeout(doRender, 10 * (space++))


controls = new TrackballControls(camera)
controls.addEventListener('change', render)

volume = createVolume(20,20,10, {x:0, y:0, z:0})
#volume = createDonutVolume()
#volume = createRandomShape()
#volume = createGiantSurface()
renderVolume(volume)
render()
animate()
cubifier = new FastCubifier(renderCube)
cubifier.cubify volume
