// Triangle Mesh

ArrayList<Vertex> verts;
ArrayList<Triangle> triangles;

class Vertex {
  PVector pos;     // position
  PVector normal;  // surface normal
  float r,g,b;     // color

  Vertex (float x, float y, float z) {
    pos = new PVector (x, y, z);
    normal = gradient_at(implicit_func, x, y, z);
    if (shader != null) {
      var _c = shader.getColor(x, y, z);
      r = _c.x;
      g = _c.y;
      b = _c.z;
    }
    else {
      r = 255;
      g = 255;
      b = 255;
    }
  }
}

class Triangle {
  int v1, v2, v3;
  
  Triangle (int i1, int i2, int i3) {
    v1 = i1;
    v2 = i2;
    v3 = i3;
  }
}

// initialize our list of triangles
void init_triangles()
{
  verts = new ArrayList<Vertex>();
  triangles = new ArrayList<Triangle>();
}

// create a new triangle with the given vertex indices
void add_triangle (int i1, int i2, int i3)
{
  Triangle tri = new Triangle (i1, i2, i3);
  triangles.add (tri);
}

// add a vertex to the vertex list
int add_vertex (PVector p)
{
  int index = verts.size();
  Vertex v = new Vertex (p.x, p.y, p.z);
  verts.add (v);
  return (index);
}

// draw the triangles of the surface
void draw_surface()
{
  for (int i = 0; i < triangles.size(); i++) {
    Triangle t = triangles.get(i);
    Vertex v1 = verts.get(t.v1);
    Vertex v2 = verts.get(t.v2);
    Vertex v3 = verts.get(t.v3);
    beginShape();
    // add "normal" command before each vertex to use per-vertex (smooth) normals
    if (normal_flag) {

      normal (v1.normal.x, v1.normal.y, v1.normal.z);
      fill(v1.r, v1.g, v1.b);
      vertex (v1.pos.x, v1.pos.y, v1.pos.z);

      normal (v2.normal.x, v2.normal.y, v2.normal.z);
      fill(v2.r, v2.g, v2.b);
      vertex (v2.pos.x, v2.pos.y, v2.pos.z);

      normal (v3.normal.x, v3.normal.y, v3.normal.z);
      fill(v3.r, v3.g, v3.b);
      vertex (v3.pos.x, v3.pos.y, v3.pos.z);
    }
    else {  
      fill(v1.r, v1.g, v1.b);
      vertex (v1.pos.x, v1.pos.y, v1.pos.z);
      fill(v2.r, v2.g, v2.b);
      vertex (v2.pos.x, v2.pos.y, v2.pos.z);
      fill(v3.r, v3.g, v3.b);
      vertex (v3.pos.x, v3.pos.y, v3.pos.z);
    }
    endShape(CLOSE);
  }
}

// write triangles to a text file
void write_triangles(String filename)
{
  PrintWriter out = createWriter (filename);

  for (int i = 0; i < triangles.size(); i++) {
    Triangle t = triangles.get(i);
    Vertex v1 = verts.get(t.v1);
    Vertex v2 = verts.get(t.v2);
    Vertex v3 = verts.get(t.v3);
    
    out.println();
    out.println ("begin");
    out.println ("vertex " + v1.pos.x + " " + v1.pos.y + " " + v1.pos.z);
    out.println ("vertex " + v2.pos.x + " " + v2.pos.y + " " + v2.pos.z);
    out.println ("vertex " + v3.pos.x + " " + v3.pos.y + " " + v3.pos.z);
    out.println ("end");
  }

  out.flush();
}
