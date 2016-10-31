<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Spring MVC 3D Viewer</title>
        <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <script src="js/jquery-3.1.1.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <style>
    /* Remove the navbar's default margin-bottom and rounded borders */
    .navbar {
      margin-bottom: 0;
      border-radius: 0;
    }
    
    /* Set height of the grid so .sidenav can be 100% (adjust as needed) */
    .row.content {height: 450px}
    
    /* Set gray background color and 100% height */
    .sidenav {
      padding-top: 20px;
      background-color: #f1f1f1;
      height: 100%;
    }
    
    /* Set black background color, white text and some padding */
    footer {
      background-color: #555;
      color: white;
      padding: 15px;
    }
    
    /* On small screens, set height to 'auto' for sidenav and grid */
    @media screen and (max-width: 767px) {
      .sidenav {
        height: auto;
        padding: 15px;
      }
      .row.content {height:auto;}
    }
  </style>
    </head>
    <body>
    <nav class="navbar navbar-inverse">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">Logo</a>
          </div>
          <div class="collapse navbar-collapse" id="myNavbar">
            <ul class="nav navbar-nav">
              <li class="active"><a href="#">Home</a></li>
              <li><a href="#">About</a></li>
              <li><button type="button" class="btn btn-info btn-sm" data-toggle="modal" data-target="#setParam">Parameters</button></li>
              <li><button type="button" class="btn btn-info btn-sm" data-toggle="modal" data-target="#myModal">Open Modal</button></li>
              <li><a href="#">Contact</a></li>
            </ul>
            <!--ul class="nav navbar-nav navbar-right">
              <li><a href="#"><span class="glyphicon glyphicon-log-in"></span> Login</a></li>
            </ul-->
          </div>
        </div>
    </nav>      
        <script src="js/three.js"></script>
        <script src="js/controls/TrackballControls.js"></script>
        <script>
            var container, stats;
            var camera, controls, scene, renderer;
            var objects = [];
            var plane = new THREE.Plane();
            var raycaster = new THREE.Raycaster();
            var mouse = new THREE.Vector2(),
            offset = new THREE.Vector3(),
            intersection = new THREE.Vector3(),
            INTERSECTED, SELECTED;

            init();
            animate();
            // ------ functions -------------
                function init() {
                    container = document.createElement( 'div' );
                    document.body.appendChild( container );
                    //container = document.getElementById("webgl");

                    //camera = new THREE.PerspectiveCamera( 70, container-.width / container-.height, 1, 10000 );
                    camera = new THREE.PerspectiveCamera( 70, window.innerWidth / window.innerHeight, 1, 10000 );
                    camera.position.z = 1000;

                    controls = new THREE.TrackballControls( camera );
                    controls.rotateSpeed = 1.0;
                    controls.zoomSpeed = 1.2;
                    controls.panSpeed = 0.8;
                    controls.noZoom = false;
                    controls.noPan = false;
                    controls.staticMoving = true;
                    controls.dynamicDampingFactor = 0.3;

                    scene = new THREE.Scene();

                    scene.add( new THREE.AmbientLight( 0x505050 ) );

                    var light = new THREE.SpotLight( 0xffffff, 1.5 );
                    light.position.set( 0, 500, 2000 );
                    light.castShadow = true;

                    light.shadow = new THREE.LightShadow( new THREE.PerspectiveCamera( 50, 1, 200, 10000 ) );
                    light.shadow.bias = - 0.00022;

                    light.shadow.mapSize.width = 2048;
                    light.shadow.mapSize.height = 2048;

                    scene.add( light );

                    var geometry = new THREE.BoxGeometry( 40, 40, 40 );

                    for ( var i = 0; i < 20; i ++ ) {

                            var object = new THREE.Mesh( geometry, new THREE.MeshLambertMaterial( { color: Math.random() * 0xffffff } ) );

                            object.position.x = Math.random() * 1000 - 500;
                            object.position.y = Math.random() * 600 - 300;
                            object.position.z = Math.random() * 800 - 400;

                            object.rotation.x = Math.random() * 2 * Math.PI;
                            object.rotation.y = Math.random() * 2 * Math.PI;
                            object.rotation.z = Math.random() * 2 * Math.PI;

                            object.scale.x = Math.random() * 2 + 1;
                            object.scale.y = Math.random() * 2 + 1;
                            object.scale.z = Math.random() * 2 + 1;

                            object.castShadow = true;
                            object.receiveShadow = true;

                            scene.add( object );

                            objects.push( object );
                    }

                    renderer = new THREE.WebGLRenderer( { antialias: true } );
                    renderer.setClearColor( 0xf0f0f0 );
                    renderer.setPixelRatio( window.devicePixelRatio );
                    renderer.setSize( window.innerWidth, window.innerHeight );
                    renderer.sortObjects = false;

                    renderer.shadowMap.enabled = true;
                    renderer.shadowMap.type = THREE.PCFShadowMap;

                    container.appendChild( renderer.domElement );

                    renderer.domElement.addEventListener( 'mousemove', onDocumentMouseMove, false );
                    renderer.domElement.addEventListener( 'mousedown', onDocumentMouseDown, false );
                    renderer.domElement.addEventListener( 'mouseup', onDocumentMouseUp, false );

                    window.addEventListener( 'resize', onWindowResize, false );
                }

            function onWindowResize() {
                camera.aspect = window.innerWidth / window.innerHeight;
                camera.updateProjectionMatrix();
                renderer.setSize( window.innerWidth, window.innerHeight );
            }
            function onDocumentMouseMove( event ) {
                event.preventDefault();
                mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1;
                mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;
                raycaster.setFromCamera( mouse, camera );

                if ( SELECTED ) {
                        if ( raycaster.ray.intersectPlane( plane, intersection ) ) {
                                SELECTED.position.copy( intersection.sub( offset ) );
                        }
                        return;
                }

                var intersects = raycaster.intersectObjects( objects );
                if ( intersects.length > 0 ) {
                        if ( INTERSECTED != intersects[ 0 ].object ) {
                                if ( INTERSECTED ) INTERSECTED.material.color.setHex( INTERSECTED.currentHex );

                                INTERSECTED = intersects[ 0 ].object;
                                INTERSECTED.currentHex = INTERSECTED.material.color.getHex();

                                plane.setFromNormalAndCoplanarPoint(
                                        camera.getWorldDirection( plane.normal ),
                                        INTERSECTED.position );
                        }
                        container.style.cursor = 'pointer';
                } else {
                        if ( INTERSECTED ) INTERSECTED.material.color.setHex( INTERSECTED.currentHex );
                        INTERSECTED = null;
                        container.style.cursor = 'auto';
                }
            }

            function onDocumentMouseDown( event ) {
                event.preventDefault();
                raycaster.setFromCamera( mouse, camera );
                var intersects = raycaster.intersectObjects( objects );
                if ( intersects.length > 0 ) {
                        controls.enabled = false;
                        SELECTED = intersects[ 0 ].object;
                        if ( raycaster.ray.intersectPlane( plane, intersection ) ) {
                                offset.copy( intersection ).sub( SELECTED.position );
                        }
                        container.style.cursor = 'move';
                }
            }

            function onDocumentMouseUp( event ) {
                event.preventDefault();
                controls.enabled = true;
                if ( INTERSECTED ) {
                        SELECTED = null;
                }
                container.style.cursor = 'auto';
            }

            function animate() {
                    requestAnimationFrame( animate );
                    render();
                    //stats.update();
            }

            function render() {
                    controls.update();
                    renderer.render( scene, camera );
            }

        </script>
        
        
        <!--------------------------------------------------------------->
        <div class="modal fade" id="myModal" role="dialog">
          <div class="modal-dialog">

            <!-- Modal content-->
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Modal Header</h4>
              </div>
              <div class="modal-body">
                <p>Some text in the modal.</p>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
              </div>
            </div>
          </div>
        </div>

        <!--------------------------------------------------------------->
        <form action="param" method="GET" id="formParam" >
            <div class="modal fade" id="setParam" role="dialog">
              <div class="modal-dialog">

                <!-- Modal content-->
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Set parameters</h4>
                  </div>
                  <div class="modal-body">
                    <div class="form-group">
                        <label for="usr">Name:</label>
                        <form:input type="text" class="form-control" id="usr" name="usr" >
                    </div>
                    <div class="form-group">
                        <label for="pwd">Password:</label>
                        <form:input type="password" class="form-control" id="pwd" name="pwd">
                    </div>
                  </div>
                  <div class="modal-footer">
                    <button type="submit" class="btn" >OK</button>
                    <button type="button" class="btn" data-dismiss="modal">Close</button>
                  </div>
                </div>
              </div>
            </div>            
        </form>
        
    </body>
</html>
