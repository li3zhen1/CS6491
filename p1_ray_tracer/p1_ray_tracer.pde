// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

boolean debug_flag = true;

ParsingState pState = ParsingState.GLOBAL;
SceneGraph scene = new SceneGraph();

void setup() {
  size (300, 300);
  noStroke();
  background (0, 0, 0);
}

void keyPressed() {
  reset_scene();

  interpreter("s" + key + ".cli");
}



// this routine parses the text in a scene description file
void interpreter(String file) {

  println("Parsing '" + file + "'");
  String str[] = loadStrings (file);
  if (str == null) println ("Error! Failed to read the file.");

  for (int i = 0; i < str.length; i++) {

    String[] token = splitTokens (str[i], " ");   // get a line and separate the tokens
    if (token.length == 0) continue;              // skip blank lines


    if (token[0].equals("fov")) {
        scene.fov = float(token[1]);
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

        scene.surfaces.add(new Surface(sColor));

    }
    else if (token[0].equals("begin")) {
        if (pState != ParsingState.GLOBAL) {
            println("Error: 'begin' without 'surface'");
        }
        else {
            pState = ParsingState.TRIANGLE;
        }
    }
    else if (token[0].equals("vertex")) {

        if (pState != ParsingState.TRIANGLE) {
            println("Error: 'vertex' without 'surface'");
        }
        else {
            float x = float(token[1]);
            float y = float(token[2]);
            float z = float(token[3]);

            // var vertex = new PVector(x, y, z);

            
            var currentTransform = scene.getCurrentTransformRef();

            if (debug_flag) {
                currentTransform.dump();
            }

            var vertex = currentTransform.applyTo(new PVector(x, y, z));
            var surface = scene.surfaces.get(scene.surfaces.size() - 1);

            surface.mesh.addVertex(vertex);
        }
    }
    else if (token[0].equals("end")) {

            if (pState != ParsingState.TRIANGLE) {
                println("Error: 'end' without 'surface'");
            }
            else {
                pState = ParsingState.GLOBAL;
            }
    }
    else if (token[0].equals("render")) {
      if (debug_flag)
        scene.dump();
      draw_scene();   // this is where you should perform the scene rendering
    }
    else if (token[0].equals("read")) {
        interpreter (token[1]);
    }
    else if (token[0].equals("translate")) {
        float x = float(token[1]);
        float y = float(token[2]);
        float z = float(token[3]);

        scene.translate(x, y, z);
    }
    else if (token[0].equals("scale")) {
        float x = float(token[1]);
        float y = float(token[2]);
        float z = float(token[3]);
        
        scene.scale(x, y, z);
    }
    else if (token[0].equals("rotate")) {
        float deg = float(token[1]);
        float rad = deg * PI / 180.0;
        var x = int(token[2]);
        var y = int(token[3]);
        var z = int(token[4]);

        if (x == 1) {
            scene.rotateX(rad);
        }
        else if (y == 1) {
            scene.rotateY(rad);
        }
        else if (z == 1) {
            scene.rotateZ(rad);
        }
        
    }
    else if (token[0].equals("push")) {
        scene.push();
    }
    else if (token[0].equals("pop")) {
        scene.pop();
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
    scene = new SceneGraph();
    pState = ParsingState.GLOBAL;
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene() {
    PVector eye = new PVector(0, 0, 0);

    float widthFloat = (float)width;
    float heightFloat = (float)height;

    float fovRadians = scene.fov * PI / 180.0;

    println("fovRadians: " + fovRadians);

  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {

      // Maybe set debug flag true for ONE pixel.
      // Have your routines (like ray/triangle intersection)
      // print information when this flag is set.
      debug_flag = false;
      if (x == 150 && y == 150)
        debug_flag = true;

      // create and cast an eye ray in order to calculate the pixel color
      float xFloat = (float)x + 0.5;
      float yFloat = (float)y + 0.5;

      

      float deltaScreenX = (xFloat - widthFloat / 2.0) / (widthFloat / 2.0) * tan(fovRadians / 2.0);
      float deltaScreenY = (heightFloat / 2.0 - yFloat) / (heightFloat / 2.0) * tan(fovRadians / 2.0);
      float deltaScreenZ = -1.0;

      var direction = new PVector(deltaScreenX, deltaScreenY, deltaScreenZ);

      var ray = new Ray(eye, direction);

      Hit closestIntersection = null;

      for (int i = 0; i < scene.surfaces.size(); i++) {
          var surface = scene.surfaces.get(i);
          var intersection = ray.intersectWithShadow(surface, scene);
          if (intersection != null) {
              if (closestIntersection == null || closestIntersection.position.z < intersection.position.z) {
                  closestIntersection = intersection;
              }
          }
      }
      if (closestIntersection == null) {
          set(x, y, scene.background.asValue());
      }
      else {
        
        //   var _color = new Color(0, 0, 0);
        //   for (int i = 0; i < scene.lights.size(); i++) {
        //       var light = scene.lights.get(i);
        //       var lightDirection = PVector.sub(light.position, closestIntersection.position);
        //       lightDirection.normalize();

        //       var diffuse = PVector.dot(closestIntersection.normal, lightDirection);

        //       if (diffuse < 0) {
        //           diffuse = 0;
        //       }
        //       _color.r += diffuse * light._color.r * closestIntersection._color.r;
        //       _color.g += diffuse * light._color.g * closestIntersection._color.g;
        //       _color.b += diffuse * light._color.b * closestIntersection._color.b;
        //   }
          set(x, y, closestIntersection._color.asValue());
      }

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
