// Polygon mesh manipulation starter code.

// for object rotation by mouse
int mouseX_old = 0;
int mouseY_old = 0;
PMatrix3D rot_mat;

// camera parameters
float camera_default = 6.0;
float camera_distance = camera_default;

void setup()
{ 
  size (800, 800, OPENGL);
  rot_mat = (PMatrix3D) getMatrix();
  rot_mat.reset();
}

void draw()
{
  noLights();
  background (130, 130, 220);    // clear the screen to black

  perspective (PI*0.2, 1.0, 0.01, 1000.0);
  camera (0, 0, camera_distance, 0, 0, 0, 0, 1, 0);   // place the camera in the scene
  
  // create an ambient light source
  ambientLight (52, 52, 52);

  // create two directional light sources
  lightSpecular (0, 0, 0);
  directionalLight (150, 150, 150, -0.7, 0.7, -1);
  directionalLight (152, 152, 152, 0, 0, -1);
  
  pushMatrix();
  if (E_showBlackMeshEdges) {
    stroke (0);                    // draw polygons with black edges
  }
  else {
    noStroke();
  } 
  fill (200, 200, 200);          // set the polygon color to white
  
  ambient (200, 200, 200);
  specular (0, 0, 0);            // turn off specular highlights
  shininess (1.0);
  
  applyMatrix (rot_mat);   // rotate the object using the global rotation matrix
  
  // THIS IS WHERE YOU SHOULD DRAW YOUR MESH



  if (stagedMesh != null) {
    stagedMesh.draw();
  }
  // else {
  //   print("No mesh to draw");
  // // beginShape();
  // // vertex (-1.0,  1.0, 0.0);
  // // vertex ( 1.0,  1.0, 0.0);
  // // vertex ( 0.0, -1.0, 0.0);
  // // endShape(CLOSE);
  // }
  // normal(); fill();
    
  popMatrix();
}

// remember where the user clicked
void mousePressed()
{
  mouseX_old = mouseX;
  mouseY_old = mouseY;
}

// change the object rotation matrix while the mouse is being dragged
void mouseDragged()
{
  if (!mousePressed)
    return;

  float dx = mouseX - mouseX_old;
  float dy = mouseY - mouseY_old;
  dy *= -1;

  float len = sqrt (dx*dx + dy*dy);
  if (len == 0)
    len = 1;

  dx /= len;
  dy /= len;
  PMatrix3D rmat = (PMatrix3D) getMatrix();
  rmat.reset();
  rmat.rotate (len * 0.005, dy, dx, 0);
  rot_mat.preApply (rmat);

  mouseX_old = mouseX;
  mouseY_old = mouseY;
}


// handle keystrokes
void keyPressed()
{
  if (key == CODED) {
    if (keyCode == UP) {         // zoom in
      camera_distance *= 0.9;
    }
    else if (keyCode == DOWN) {  // zoom out
      camera_distance /= 0.9;
    }
    return;
  }
  
  if (key == 'R') {
    rot_mat.reset();
    camera_distance = camera_default;
  }
  else if (key == '1') {
    read_mesh ("octa.ply");
  }
  else if (key == '2') {
    read_mesh ("cube.ply");
  }
  else if (key == '3') {
    read_mesh ("icos.ply");
  }
  else if (key == '4') {
    read_mesh ("dodeca.ply");
  }
  else if (key == '5') {
    read_mesh ("star.ply");
  }
  else if (key == '6') {
    read_mesh ("torus.ply");
  }
  else if (key == '7') {      
    read_mesh ("s.ply");
  }

  else if (key == 'f') {
    F_perVetexNormal = !F_perVetexNormal;
  }
  else if (key == 'w') {
    W_randomlyColored = !W_randomlyColored;
  }
  else if (key == 'e') {
    E_showBlackMeshEdges = !E_showBlackMeshEdges;
  }
  else if (key == 'v') {
    V_visualizeDirectedEdge = !V_visualizeDirectedEdge;
  }

  else if (key == 'n') {
    V_visualizeDirectedEdge = true;
    stagedMesh.focusNextEdge();
  }
  else if (key == 'p') {
    V_visualizeDirectedEdge = true;
    stagedMesh.focusPrevEdge();
  }
  else if (key == 'o') {
    V_visualizeDirectedEdge = true;
    stagedMesh.focusOppoEdge();
  }
  else if (key == 's') {
    V_visualizeDirectedEdge = true;
    stagedMesh.focusSwingEdge();
  }

  else if (key == 'd') {
    stagedMesh = createDual(stagedMesh);
  }
  else if (key == 'g') {
    stagedMesh = createMidpointSubdivision(stagedMesh);
  }
  else if (key == 'c') {
    stagedMesh = createCatmullClarkSubdivision(stagedMesh);
  }
  else if (key == 'r') {
    stagedMesh = addNoiseOnDirectionOfNormal(stagedMesh, 0.1);
  }
  else if (key == 'l') {
    stagedMesh = createLaplacianSmooth(stagedMesh, 0.6, 40);
  }
  else if (key == 't') {
    stagedMesh = createTaubinSmooth(stagedMesh, 40);
  }


// f: Toggle between per-face and per-vertex normals.

// w: Toggle between white and randomly colored faces.

// e: Toggle between not showing and showing the mesh edges in black.

// v: Toggle visualization of a directed edge on / off

// n: Change the current edge using the "next" operator.

// p: Change the current edge using the "previous" operator.

// o: Change the current edge using the "opposite" operator.

// s: Change the current edge using the "swing" operator.

// d: Create and display the dual of the mesh (you should be able to do this an unlimited number of times).

// g: Perform midpoint subdivision of the mesh and project vertices to sphere (you should be able to do this an unlimited number of times).

// c: Perform Catmull-Clark subdivision (you should also be able to do this an unlimited number of times).

// r: Add random noise to the mesh by moving the vertices in the normal direction (both in and out).

// l (lower case "L"): Perform Laplacian smoothing (40 iterations).

// t: Perform Taubin smoothing (40 iterations).
}
