// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

boolean debug_flag = false;

ParsingState pState = ParsingState.GLOBAL;
SceneGraph scene = new SceneGraph();

void setup() {
    size(300, 300);
    noStroke();
    background(0, 0, 0);
}

void keyPressed() {
    reset_scene();

    switch (key) {
        case '1':
            interpreter("s01.cli");
            break;
        case '2':
            interpreter("s02.cli");
            break;
        case '3':
            interpreter("s03.cli");
            break;
        case '4':
            interpreter("s04.cli");
            break;
        case '5':
            interpreter("s05.cli");
            break;
        case '6':
            interpreter("s06.cli");
            break;
        case '7':
            interpreter("s07.cli");
            break;
        case '8':
            interpreter("s08.cli");
            break;
        case '9':
            interpreter("s09.cli");
            break;
        case '0':
            interpreter("s10.cli");
            break;
            case 'a':
            interpreter("s11.cli");
            break;
        default:
            break;
    }
}


// this routine parses the text in a scene description file
void interpreter(String file) {

    println("Parsing '" + file + "'");
    String str[] = loadStrings(file);
    if (str == null) println("Error! Failed to read the file.");

    for (int i = 0; i < str.length; i++) {

        String[] token = splitTokens(str[i], " ");   // get a line and separate the tokens
        if (token.length == 0) continue;              // skip blank lines


        if (token[0].equals("fov")) {
            scene.fov = float(token[1]);
        } else if (token[0].equals("background")) {
            float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
            float g = float(token[2]);
            float b = float(token[3]);
            scene.background = new Color(r, g, b);
        } else if (token[0].equals("light")) {
            float x = float(token[1]);
            float y = float(token[2]);
            float z = float(token[3]);
            float r = float(token[4]);
            float g = float(token[5]);
            float b = float(token[6]);

            var light = new Light(new PVector(x, y, z), new Color(r, g, b));
            scene.lights.add(light);

        } else if (token[0].equals("surface")) {
            float r = float(token[1]);
            float g = float(token[2]);
            float b = float(token[3]);

            var sColor = new Color(r, g, b);
            var surface = new Surface(sColor);

            scene.surfaces.add(surface);
            scene.addObject(surface);

        } else if (token[0].equals("begin")) {
            if (pState != ParsingState.GLOBAL) {
                println("Error: 'begin' without 'surface'");
            } else {
                pState = ParsingState.TRIANGLE;
            }
        } else if (token[0].equals("vertex")) {

            if (pState != ParsingState.TRIANGLE) {
                println("Error: 'vertex' without 'surface'");
            } else {
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
        } else if (token[0].equals("end")) {
            if (pState != ParsingState.TRIANGLE) {
                println("Error: 'end' without 'surface'");
            } else {
                pState = ParsingState.GLOBAL;
            }
        } else if (token[0].equals("render")) {
            draw_scene();   // this is where you should perform the scene rendering
        } else if (token[0].equals("read")) {
            interpreter(token[1]);
        } else if (token[0].equals("translate")) {
            float x = float(token[1]);
            float y = float(token[2]);
            float z = float(token[3]);

            scene.translate(x, y, z);
        } else if (token[0].equals("scale")) {
            float x = float(token[1]);
            float y = float(token[2]);
            float z = float(token[3]);

            scene.scale(x, y, z);
        } else if (token[0].equals("rotate")) {
            float deg = float(token[1]);
            float rad = deg * PI / 180.0;
            var x = int(token[2]);
            var y = int(token[3]);
            var z = int(token[4]);

            if (x == 1) {
                scene.rotateX(rad);
            } else if (y == 1) {
                scene.rotateY(rad);
            } else if (z == 1) {
                scene.rotateZ(rad);
            }
        }
         // box  xmin ymin zmin  xmax ymax zmax
        else if (token[0].equals("box")) {
            float xmin = float(token[1]);
            float ymin = float(token[2]);
            float zmin = float(token[3]);
            float xmax = float(token[4]);
            float ymax = float(token[5]);
            float zmax = float(token[6]);

            var transform = scene.getCurrentTransformRef();

            var box = new Box(
                transform.applyTo(new PVector(xmin, ymin, zmin)), 
                transform.applyTo(new PVector(xmax, ymax, zmax))
            );
            
            box.diffuseColor = scene.getLatestObject().getColor();
            scene.replaceLatestObject(box);
            
        } 
        else if (token[0].equals("named_object")) {
            String name = token[1];
            scene.moveLatestObjectToLibraryWithName(name);
        }
        else if (token[0].equals("instance")) {
            String name = token[1];
            scene.instantiate(name);
        }
        else if (token[0].equals("begin_accel")) {


        } else if (token[0].equals("end_accel")) {

        }
        else if (token[0].equals("push")) {
            scene.push();

        } else if (token[0].equals("pop")) {
            scene.pop();
        } else if (token[0].equals("#")) {
            // comment (ignore)
        } else {
            println("unknown command: " + token[0]);
        }
    }
}

void reset_scene() {
    scene = new SceneGraph();
    pState = ParsingState.GLOBAL;
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene() {
    int timer = millis();
    println("\n\n============ Rendering ........ ============ ");
    PVector eye = new PVector(0, 0, 0);

    float widthFloat = (float) width;
    float heightFloat = (float) height;

    float fovRadians = scene.fov * PI / 180.0;
    float fovTan = tan(fovRadians / 2.0);

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {

            

            // Maybe set debug flag true for ONE pixel.
            // Have your routines (like ray/triangle intersection)
            // print information when this flag is set.
            debug_flag = false;
            if (x == 80 && y == 81)
                debug_flag = true;
            // if (x == 112 && y == 112)
            //     debug_flag = true;
            // if (x == 148 && y == 60)
            //     debug_flag = true;
            // if (x == 72 && y == 200)
            //     debug_flag = true;

            // create and cast an eye ray in order to calculate the pixel color
            float xFloat = (float) x + 0.5;
            float yFloat = (float) y + 0.5;


            float deltaScreenX = (xFloat - widthFloat / 2.0) / (widthFloat / 2.0) * fovTan;
            float deltaScreenY = (heightFloat / 2.0 - yFloat) / (heightFloat / 2.0) * fovTan;
            float deltaScreenZ = -1.0;

            var direction = new PVector(deltaScreenX, deltaScreenY, deltaScreenZ);

            var ray = new Ray(eye, direction);

            // ray.dump();
            // ray.mutatingTransformedBy(transform);
            // print("->");
            // ray.dump();
            // print("\n");


            Hit closestIntersection = null;

            for (int i = 0; i < scene.secneObjectInstances.size(); i++) {
                var object = scene.secneObjectInstances.get(i);
                var intersection = object.getIntersection(
                    ray, 
                    scene
                );
                if (intersection != null) {
                    if (closestIntersection == null || closestIntersection.position.z < intersection.position.z) {
                        closestIntersection = intersection;
                    }
                }
            }
            if (closestIntersection == null) {
                set(x, y, scene.background.asValue());
            } else {
                set(x, y, closestIntersection._color.asValue());
            }

            // for (int i = 0; i < scene.surfaces.size(); i++) {
            //     var surface = scene.surfaces.get(i);
            //     var intersection = ray.intersectWithShadow(surface, scene);
            //     if (intersection != null) {
            //         if (closestIntersection == null || closestIntersection.position.z < intersection.position.z) {
            //             closestIntersection = intersection;
            //         }
            //     }
            // }
            // if (closestIntersection == null) {
            //     set(x, y, scene.background.asValue());
            // } else {
            //     set(x, y, closestIntersection._color.asValue());
            // }

            if (debug_flag) {
                set(x, y, color(255, 0, 0));
            }
        }
    }
    println("============ Rendering finished ============ ");
    int new_timer = millis();
    int diff = new_timer - timer;
    float seconds = diff / 1000.0;
    println ("timer = " + seconds);
}

// prints mouse location clicks, for help in debugging
void mousePressed() {
    // set(mouseX, mouseY, color(0, 255, 255));
    println("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything in the "draw" function for this project
void draw() {
}

