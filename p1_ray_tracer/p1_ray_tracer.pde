// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

boolean debug_flag = false;

void setup() {
  size (300, 300);  
  noStroke();
  background (0, 0, 0);
}

void keyPressed() {
  reset_scene();
  switch(key) {
    case '1': interpreter("s1.cli"); break;
    case '2': interpreter("s2.cli"); break;
    case '3': interpreter("s3.cli"); break;
    case '4': interpreter("s4.cli"); break;
  }
}

class Color {
  float r;
  float g;
  float b;
  
  Color(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }

  color asValue() {
    return color(255*r, 255*g, 255*b);
  }
}

class Light {
  PVector position;
  Color _color;
  
  Light(PVector position, Color _color) {
    this.position = position;
    this._color = _color;
  }
}

class Surface {
  Color _color;
  ArrayList<PVector> vertices;

    Surface(Color _color) {
        this._color = _color;
        this.vertices = new ArrayList<PVector>();
    }
}

class Ray {
  PVector origin;
  PVector direction;
  
  Ray(PVector origin, PVector direction) {
    this.origin = origin;
    this.direction = direction;
  }

    void dump() {
        println("Ray");
        println("  origin: " + origin.x + " " + origin.y + " " + origin.z);
        println("  direction: " + direction.x + " " + direction.y + " " + direction.z);
    }

    PVector intersect(Surface surface) {
        var vertices = surface.vertices;
        var vertex1 = vertices.get(0);
        var vertex2 = vertices.get(1);
        var vertex3 = vertices.get(2);

        var edge1 = PVector.sub(vertex2, vertex1);
        var edge2 = PVector.sub(vertex3, vertex1);

        var h = direction.cross(edge2);
        var a = edge1.dot(h);

        if (a > -0.00001 && a < 0.00001) {
            return null;
        }

        var f = 1.0 / a;
        var s = PVector.sub(origin, vertex1);
        var u = f * s.dot(h);

        if (u < 0.0 || u > 1.0) {
            return null;
        }

        var q = s.cross(edge1);
        var v = f * PVector.dot(direction, q);

        if (v < 0.0 || u + v > 1.0) {
            return null;
        }

        var t = f * PVector.dot(edge2, q);

        if (t > 0.00001) {
            var point = PVector.add(origin, PVector.mult(direction, t));
            return point;
        }
        else {
            return null;
        }
    }
}

class SceneDescription {
  float fov;
  Color background;
  ArrayList<Light> lights;
  ArrayList<Surface> surfaces;
  

  SceneDescription() {
    this.fov = 0;
    this.background = new Color(0, 0, 0);
    this.lights = new ArrayList<Light>();
    this.surfaces = new ArrayList<Surface>();
  }


  void dump() {
    println("SceneDescription");
    println("  fov: " + fov);
    println("  background: " + background.r + " " + background.g + " " + background.b);
    println("  lights: " + lights.size());
    for (int i = 0; i < lights.size(); i++) {
      Light light = lights.get(i);
      println("    light: " + light.position.x + " " + light.position.y + " " + light.position.z + " " + light._color.r + " " + light._color.g + " " + light._color.b);
    }
    println("  surfaces: " + surfaces.size());
    for (int i = 0; i < surfaces.size(); i++) {
      Surface surface = surfaces.get(i);
      println("    surface: " + surface._color.r + " " + surface._color.g + " " + surface._color.b);
      println("      vertices: " + surface.vertices.size());
      for (int j = 0; j < surface.vertices.size(); j++) {
        PVector vertex = surface.vertices.get(j);
        println("        vertex: " + vertex.x + " " + vertex.y + " " + vertex.z);
      }
    }
  }
}

enum ParsingState {
  GLOBAL, SURFACE
}

SceneDescription scene = new SceneDescription();

// this routine parses the text in a scene description file
void interpreter(String file) {
  
  println("Parsing '" + file + "'");
  String str[] = loadStrings (file);
  if (str == null) println ("Error! Failed to read the file.");

  var pState = ParsingState.GLOBAL;
  

  for (int i = 0; i < str.length; i++) {
    
    String[] token = splitTokens (str[i], " ");   // get a line and separate the tokens
    if (token.length == 0) continue;              // skip blank lines

    if (token[0].equals("fov")) {
    }
    else if (token[0].equals("background")) {
      float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
      float g = float(token[2]);
      float b = float(token[3]);

      scene.background = new Color(r, g, b);

    }
    else if (token[0].equals("light")) {
        float x = float(token[1]);
        float y = float(token[2]);
        float z = float(token[3]);
        float r = float(token[4]);
        float g = float(token[5]);
        float b = float(token[6]);
    
        var light = new Light(new PVector(x, y, z), new Color(r, g, b));
        scene.lights.add(light);
        
    }
    else if (token[0].equals("surface")) {
        
        float r = float(token[1]);
        float g = float(token[2]);
        float b = float(token[3]);
        
        var sColor = new Color(r, g, b);
        
        pState = ParsingState.SURFACE;

        scene.surfaces.add(new Surface(sColor));

    }    
    else if (token[0].equals("begin")) {

        if (pState != ParsingState.SURFACE) {
            println("Error! 'begin' without 'surface'");
        }
    }
    else if (token[0].equals("vertex")) {

        if (pState != ParsingState.SURFACE) {
            println("Error! 'vertex' without 'surface'");
        }
        else {
            float x = float(token[1]);
            float y = float(token[2]);
            float z = float(token[3]);
            
            var vertex = new PVector(x, y, z);

            var surface = scene.surfaces.get(scene.surfaces.size() - 1);

            surface.vertices.add(vertex);
        }
    }
    else if (token[0].equals("end")) {
            
            if (pState != ParsingState.SURFACE) {
                println("Error! 'end' without 'surface'");
            }
            else {
                pState = ParsingState.GLOBAL;
            }
    }
    else if (token[0].equals("render")) {
        scene.dump();
      draw_scene();   // this is where you should perform the scene rendering
    }
    else if (token[0].equals("#")) {
      // comment (ignore)
    }
    else {
      println ("unknown command: " + token[0]);
    }
  }
}

void reset_scene() {
    scene = new SceneDescription();
  // reset your scene variables here
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene() {
    PVector eye = new PVector(0, 0, 0);

    float widthFloat = (float)width;
    float heightFloat = (float)height;
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      
      // Maybe set debug flag true for ONE pixel.
      // Have your routines (like ray/triangle intersection) 
      // print information when this flag is set.
      debug_flag = false;
      if (x == 150 && y == 150)
        debug_flag = true;

      // create and cast an eye ray in order to calculate the pixel color
      float xFloat = (float)x;
        float yFloat = (float)y;

      float deltaScreenX = (xFloat - widthFloat / 2.0) / (widthFloat / 2.0);
      float deltaScreenY = (yFloat - heightFloat / 2.0) / (heightFloat / 2.0);
      float deltaScreenZ = -1.0;

      var direction = new PVector(deltaScreenX, deltaScreenY, deltaScreenZ);

      var ray = new Ray(eye, direction);
      
      for (int i = 0; i < scene.surfaces.size(); i++) {
          var surface = scene.surfaces.get(i);
          var point = ray.intersect(surface);
          if (point != null) {
              set(x, y, surface._color.asValue());
          }
          else {
                set(x, y, scene.background.asValue());
          }
      }
      
      
      // set the pixel color
    //   color c = color(150, 150, 250);  // you should use the correct pixel color here
    //   set (x, y, c);                   // make a tiny rectangle to fill the pixel
    }
  }
}

// prints mouse location clicks, for help in debugging
void mousePressed() {
  println ("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything in the "draw" function for this project
void draw() {
}
