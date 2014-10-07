define([
  'jquery',
  'threejs',
  'trackball'
], function($, THREE){

  function original(json, elementID){
    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
    var renderer = new THREE.WebGLRenderer();
    renderer.setSize(400,400);


		var controls = new THREE.TrackballControls( camera );

		controls.rotateSpeed = 1.0;
		controls.zoomSpeed = 1.2;
		controls.panSpeed = 0.8;

		controls.noZoom = false;
		controls.noPan = false;

    controls.staticMoving = true;
    controls.dynamicDampingFactor = 0.3;

    $('#'+elementID)[0].appendChild(renderer.domElement);

    var loader = new THREE.JSONLoader();

    var loaded = loader.parse(json);
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

    function render () {
      requestAnimationFrame(render);
      controls.update();
      //renderer.render(scene, camera);
    }


    controls.addEventListener( 'change', render );

    render();
  }

  return function(json, elementID){
    var container, stats;

  	var camera, controls, scene, renderer;

  	var cross;

  	init();
  	animate();

    function positionCameraForBestView(sphere, camera){
      var fov = camera.fov;
      var diameter = 2.1*sphere.radius;
      var distance = diameter / (2*Math.tan(Math.PI*fov/360));
      var delta = new THREE.Vector3(1,1,1).setLength(distance);
      camera.position = sphere.center.clone().add(delta);
      camera.lookAt(sphere.center);
    }

  	function init() {

  		camera = new THREE.PerspectiveCamera( 60, 1, 1, 1000 );
  		camera.position.z = 50;

      container = document.getElementById( elementID );



  		// world

  		scene = new THREE.Scene();
  		//scene.fog = new THREE.FogExp2( 0xcccccc, 0.002 );

  		//var geometry = new THREE.CylinderGeometry( 0, 10, 30, 4, 1 );
      var loader = new THREE.JSONLoader();

      var loaded = loader.parse(json);
      var geometry = loaded.geometry;
      geometry.computeBoundingSphere();
      positionCameraForBestView(geometry.boundingSphere, camera);
  		var material =  new THREE.MeshLambertMaterial( { color:0xffffff, shading: THREE.FlatShading } );

			var mesh = new THREE.Mesh( geometry, material );
			scene.add( mesh );

  		// lights

  		light = new THREE.DirectionalLight( 0xffffff );
  		light.position.set( 1, 2, 3 );
  		scene.add( light );

  		light = new THREE.DirectionalLight( 0x002288 );
  		light.position.set( -3, -2, -1 );
  		scene.add( light );

  		light = new THREE.AmbientLight( 0x222222 );
  		scene.add( light );


  		// renderer

  		renderer = new THREE.WebGLRenderer( { antialias: false } );
  		renderer.setSize( 500, 500 );

      $(renderer.domElement).width(500).height(500).css({
        'z-index': 1000
      });

  		container.appendChild( renderer.domElement );
      //*
      controls = new THREE.TrackballControls( camera, renderer.domElement );

      controls.rotateSpeed = 1.0;
      controls.zoomSpeed = 1.2;
      controls.panSpeed = 0.8;

      controls.noZoom = false;
      controls.noPan = false;

      controls.staticMoving = true;
      controls.dynamicDampingFactor = 0.3;

      controls.addEventListener( 'change', render );

      $('#notebook').scroll(function(){
        controls.handleResize();
      });
//*/

  		render();

  	}

  	function animate() {

  		requestAnimationFrame( animate );
  		if(controls) controls.update();

  	}

  	function render() {

  		renderer.render( scene, camera );

  	}
  };

});
