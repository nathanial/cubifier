_ = require('underscore')
THREE = require('three')
TrackballControls = require('./TrackballControls')
Frontier = require('./cubifier/Frontier')
Mesh = require('./cubifier/Mesh')
Cubifier = require('./cubifier/Cubifier')
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
    console.log("Create Cube", x,y,z)
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
  volume.append(createVolume(10,10,1, {x:5,y:0,z:0}))

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
  setTimeout(doRender, 100 * (space++))


controls = new TrackballControls(camera)
controls.addEventListener('change', render)

#volume = createVolume(10,10,10, {x:5, y:0, z:0})
volume = createIrregularVolume()
renderVolume(volume)
render()
animate()
cubifier = new Cubifier(renderCube)
cubifier.cubify volume
