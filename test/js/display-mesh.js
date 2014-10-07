
  require.config({
    baseUrl: 'js',
    paths: {
      jquery: '//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery',
      json: '//cdnjs.cloudflare.com/ajax/libs/requirejs-plugins/1.0.3/json',
      threejs: '//cdnjs.cloudflare.com/ajax/libs/three.js/r68/three',
      text: '//cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text',
      data: '../data'
    },
    shim: {
      threejs: {
        exports: 'THREE'
      }
    }
  });
  require([
    'jquery',
    'threejs',
    'json!data/cube.3js.json'
  ], function($, THREE, cubeJSON){
    console.log($, THREE, cubeJSON);
    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
    var renderer = new THREE.WebGLRenderer();
    renderer.setSize(400,400);
    document.body.appendChild(renderer.domElement);

    var loader = new THREE.JSONLoader();

    var loaded = loader.parse(cubeJSON);
    var geometry = loaded.geometry;
    var material = loaded.materials || new THREE.MeshLambertMaterial({color: 0x00ff00});
    var cube = new THREE.Mesh(geometry, material);
    scene.add(cube);

    var light = new THREE.PointLight( 0x707070, 1, 100 );
    light.position.set( 5, 5, 10 );
    scene.add( light );
    light = new THREE.AmbientLight( 0x101010 ); // soft white light
    scene.add( light );

    camera.position.z = 5;

    var render = function () { requestAnimationFrame(render); cube.rotation.x += 0.01; cube.rotation.y += 0.01; renderer.render(scene, camera); }; render();
  });
