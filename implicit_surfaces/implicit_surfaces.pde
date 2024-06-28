// Create polygonalized implicit surfaces.

// for object rotation by mouse
int mouseX_old = 0;
int mouseY_old = 0;
float k_morphing = 0;
PMatrix3D rot_mat;

// camera parameters
float camera_default = 6.0;
float camera_distance = camera_default;

boolean edge_flag = false;      // draw the polygon edges?
boolean normal_flag = true;   // use smooth normals during shading?

// iso-surface threshold
float threshold = 1.0;  

int timer;  // used to time parts of the code

void setup()
{
  size (750, 750, OPENGL);
  
  // set up the rotation matrix
  rot_mat = (PMatrix3D) getMatrix();
  rot_mat.reset();
  
  // specify our implicit function is that of a sphere, then do isosurface extraction
  set_implicit (a_sphere);
  set_threshold (1.0);
  isosurface();
}

void draw()
{
  background (100, 100, 180);    // clear the screen

  perspective (PI*0.2, 1.0, 0.01, 1000.0);
  camera (0, 0, camera_distance, 0, 0, 0, 0, 1, 0);   // place the camera in the scene

  // create two directional light sources
  directionalLight (100, 100, 100, -0.7, 0.7, -1);
  directionalLight (182, 182, 182, 0, 0, -1);
  
  pushMatrix();

  // decide if we are going to draw the polygon edges
  if (edge_flag)
    stroke (0);  // black edges
  else
    noStroke();  // no edges

  fill (250, 250, 250);          // set the polygon color to white
  ambient (200, 200, 200);
  specular (0, 0, 0);            // turn off specular highlights
  shininess (1.0);
  
  applyMatrix (rot_mat);   // rotate the object using the global rotation matrix

  // draw the polygons from the implicit surface
  draw_surface();
  
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

  // print(rmat.m00 + " " + rmat.m01 + " " + rmat.m02 + " " + rmat.m03 + "\n");
  // print(rmat.m10 + " " + rmat.m11 + " " + rmat.m12 + " " + rmat.m13 + "\n");
  // print(rmat.m20 + " " + rmat.m21 + " " + rmat.m22 + " " + rmat.m23 + "\n");
  // print(rmat.m30 + " " + rmat.m31 + " " + rmat.m32 + " " + rmat.m33 + "\n");

  mouseX_old = mouseX;
  mouseY_old = mouseY;
}

// handle keystrokes
void keyPressed()
{
  if (key == CODED) {
    if (keyCode == UP) {
      camera_distance *= 0.9;
    }
    else if (keyCode == DOWN) {
      camera_distance /= 0.9;
    }
    return;
  }
  
  if (key == 'e') {
    edge_flag = !edge_flag;
  }
  if (key == 'n') {
    normal_flag = !normal_flag;
  }
  if (key == 'r') {  // reset camera view and rotation
    rot_mat.reset();
    camera_distance = camera_default;
  }
  if (key == 'w') {  // write triangles to a file
    String filename = "implicit_mesh.cli";
    write_triangles (filename);
    println ("wrote triangles to file: " + filename);
  }
  if (key == ',') {  // decrease the grid resolution
    if (gsize > 10) {
      gsize -= 10;
      isosurface();
    }
  }
  if (key == '.') {  // increase the grid resolution
    gsize += 10;
    isosurface();
  }
  if (key == '1') {
    set_threshold (1.0);
    set_implicit (a_sphere);
    isosurface();
  }
  if (key == '!') {
    
    set_threshold (1.0);
    set_implicit (b_saucer);
    isosurface();
  }
  if (key == '2') {
    
    set_threshold (0.3);
    var blobbyGenerator = new BlobbyGenerator();
    blobbyGenerator.add(1, 0.55, -1.0, 0.0);
    blobbyGenerator.add(1, -0.5, -1.0, 0.0);

    blobbyGenerator.add(1, 0.65, 1.0, 0.0);
    blobbyGenerator.add(1, -0.65, 1.0, 0.0);

    set_implicit (blobbyGenerator.generate());
    set_shader (blobbyGenerator.generateColor());
    isosurface();
  }
  if (key == '@') {
    
    set_threshold (0.3);
    var blobbyGenerator = new BlobbyGenerator();
    for (var i = 0; i < 10; i++) {
      blobbyGenerator.add(
        0.8, 
        random(-1.5, 1.5), 
        random(-1.5, 1.5), 
        random(-1.5, 1.5), 
        new PVector(random(0.4, 1), random(0.4, 1), random(0.4, 1))
      );
    }
    set_implicit (blobbyGenerator.generate());
    shader = blobbyGenerator.generateColor();
    isosurface();
  }
  if (key == '3') {
    
    set_threshold (0.5);
    var line = new LineSegmentGenerator(
      new PVector(-1, 0, 0),
      new PVector(1, 0, 0)
    );
    set_implicit (line.generate());
    isosurface();
  }
  if (key == '#') {
    
    set_threshold (0.3);
    var surfaceBlobbyGenerator = new ImplicitInterfaceBlobbyGenerator();
    surfaceBlobbyGenerator.add(
      new LineSegmentGenerator(
        new PVector(-0.8, -0.8, 0),
        new PVector(0.8, -0.8, 0)
      ).generate(),
      0.6
    );
    surfaceBlobbyGenerator.add(
      new LineSegmentGenerator(
        new PVector(-0.8, 0.8, 0),
        new PVector(0.8, 0.8, 0)
      ).generate(),
      0.6
    );
    surfaceBlobbyGenerator.add(
      new LineSegmentGenerator(
        new PVector(-0.8, -0.8, 0),
        new PVector(-0.8, 0.8, 0)
      ).generate(),
      0.6
    );
    surfaceBlobbyGenerator.add(
      new LineSegmentGenerator(
        new PVector(0.8, -0.8, 0),
        new PVector(0.8, 0.8, 0)
      ).generate(),
      0.6
    );

    set_implicit (surfaceBlobbyGenerator.generate());
    isosurface();

  }
  if (key == '4') {
    set_threshold (0);
    var torus = new TorusGenerator(1.0, 0.5).generate();
    set_implicit (torus);
    isosurface();
  }
  if (key == '$') {
    set_threshold (0.4);
    float r = 0.0;
    float R = 0.5;

    var m1 = new PMatrix3D();
    m1.rotateX(-PI/4);
    m1.translate(-2*R, 0, 0);
    var torus1 = transform(new TorusGenerator(R, r).generate(), m1);

    var m2 = new PMatrix3D();
    var torus2 = transform(new TorusGenerator(R, r).generate(), m2);

    var m3 = new PMatrix3D();
    m3.rotateX(PI/4);
    m3.translate(2*R, 0, 0);
    var torus3 = transform(new TorusGenerator(R, r).generate(), m3);
    
    set_implicit (
      (x, y, z) -> (
        blobby(torus1.getValue(x,y,z) * 20) +
        blobby(torus3.getValue(x,y,z) * 20) +
        blobby(torus2.getValue(x,y,z) * 20)
      )
    );
    
    isosurface();
  }


  if (key == '5') {
    set_threshold (0.28);
    float offset = 0.;
    var line = new LineSegmentGenerator(
        new PVector(-1.5, offset, 0),
        new PVector(1.5, offset, 0)
    );
    PMatrix3D m = new PMatrix3D();
    m.translate(0, -0.4, 0);
    set_implicit (
      transform(
        line.generate(),
        m
      )
    );
    isosurface();
  }
  if (key == '%') {
    set_threshold (0.28);
    float offset = 0.;
    var line = new LineSegmentGenerator(
        new PVector(-1.5, offset, 0),
        new PVector(1.5, offset, 0)
    );
    PMatrix3D m = new PMatrix3D();
    m.translate(0, -0.4, 0);
    set_implicit (
      twistOnX(transform(
        line.generate(),
        m
      ),6)
    );
    isosurface();
  }
  if (key == '6') {
    set_threshold (0.28);

    float offset = 0.;
    var line = new LineSegmentGenerator(
        new PVector(-1.5, offset, 0),
        new PVector(1.5, offset, 0)
    );
    set_implicit (
      taperOnX(
        line.generate(),
        -1.5,
        1.7,
        0.5,
        1.2
      )
    );
    isosurface();
  }
  if (key == '^') {
    PMatrix3D m = new PMatrix3D();
    m.translate(0, -0.3, 0);
    set_threshold (0.3);
    float offset = 0.;
    var line = new LineSegmentGenerator(
        new PVector(-1.5, offset, 0),
        new PVector(1.5, offset, 0)
    );
    set_implicit (
      taperOnX(
        twistOnX(
          transform(
            line.generate(),
            m
          ),
          8
        ),
        -1.5,
        1.7,
        0.3,
        1.2
      )
    );
    isosurface();
  }
  if (key == '7') {
    set_threshold (0.0);
    set_implicit (
      intersectionOf(
        sphereAt(0, 1.0, 0, 1.5),
        sphereAt(0, -1.0, 0, 1.5)
      )
    );
    isosurface();
  }
  if (key == '&') {
    set_threshold (0.0);
    var l = new LineSegmentGenerator(
          new PVector(0.4, 0, 1.5),
          new PVector(-0.4, 0, -1.5)
    ).generate(0.5);
    set_implicit (
      substractionOf(
        sphereAt(0, 0, 0, 1.2),
        l
      )
    );
    isosurface();
  }
  if (key == '8') {
    k_morphing -= 0.1;
    if (k_morphing<1e-2) {
      k_morphing = 0;
    }
    render_for_morphing();
  }
  if (key == '9') {
    k_morphing += 0.1;
    if (k_morphing>1-1e-2) {
      k_morphing = 1;
    }
    render_for_morphing();
  }
  if (key == '0') {
    var old_gsize = gsize;
    gsize = old_gsize > 70 ? old_gsize : 100;
    println ("Starting rendering pikachu, this might take a long time, and probably better with gsizes of 200 or more...");
    set_threshold (0.8);
    var p = new PikachuGenerator();
    set_implicit (
      p.generate()
    );
    set_shader (
      p.generateColor()
    );
    isosurface();

    gsize = old_gsize;
  }
}

void reset_timer()
{
  timer = millis();
}

void print_timer()
{
  int new_timer = millis();
  int diff = new_timer - timer;
  float seconds = diff / 1000.0;
  println ("timer = " + seconds);
}


void render_for_morphing() {
    float offset = 1.2;
    float tl = 0.2;
    float sl = 3;

    var sphere = a_sphere;

    PMatrix3D m = new PMatrix3D();
    m.rotateX(PI/6);
    m.rotateY(PI/6);
    m.rotateZ(-PI/6);

    var l1 = new LineSegmentGenerator(
          new PVector(0, 0, -offset),
          new PVector(0, 0, offset)
    ).generate();

    var l2 = new LineSegmentGenerator(
          new PVector(0, -offset, 0),
          new PVector(0, offset, 0)
    ).generate();

    var l3 = new LineSegmentGenerator(
          new PVector(-offset, 0, 0),
          new PVector(offset, 0, 0)
    ).generate();

    ImplicitInterface l = (x, y, z) -> (
      (1-k_morphing)*(blobby(sphere.getValue(x, y, z) - 0.6))+
      (k_morphing) * (
        blobby((l1.getValue(x, y, z) - tl)*sl) +
        blobby((l2.getValue(x, y, z) - tl)*sl) +
        blobby((l3.getValue(x, y, z) - tl)*sl) - 0.2
      )
    );

    set_threshold (0.1);
    set_implicit( transform(l, m) );
    isosurface();
}