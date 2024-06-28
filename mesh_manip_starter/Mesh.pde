
final class Vertex {
  float x, y, z;
  Vertex(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  void normalize() {
    float norm = sqrt(x*x + y*y + z*z);
    x /= norm;
    y /= norm;
    z /= norm;
  }

  Vertex clone() {
    return new Vertex(x, y, z);
  }
}

final Vertex lerp(Vertex a, Vertex b, float t) {
  return new Vertex(
    a.x + (b.x - a.x) * t,
    a.y + (b.y - a.y) * t,
    a.z + (b.z - a.z) * t
  );
}



final class DirectedEdge {
  int from;
  int to;
  DirectedEdge next;
  DirectedEdge oppo;
  DirectedEdge prev;


  Face face;

  DirectedEdge(int from, int to) {
    this.from = from;
    this.to = to;
  }

  DirectedEdge getSwing() {
    return oppo.next;
  }

  EdgeIndex getEdgeIndex() {
    return new EdgeIndex(from, to);
  }

}

final class Face {
  DirectedEdge edge;

  Face(DirectedEdge edge) {
    this.edge = edge;
  }

  ArrayList<DirectedEdge> getEdges() {
    var edges = new ArrayList<DirectedEdge>();
    DirectedEdge e = edge;
    do {
      edges.add(e);
      e = e.next;
    } while (e != edge);
    return edges;
  }
}

final class Mesh {
  public ArrayList<Vertex> vertices = new ArrayList<>();
  public ArrayList<DirectedEdge> edges = new ArrayList<>();
  public ArrayList<Face> faces = new ArrayList<>();
  private HashMap<EdgeIndex, DirectedEdge> edgeMap = new HashMap<>();
  // private HashMap<EdgeIndex, DirectedEdge> prevEdgeMap = new HashMap<>();

  DirectedEdge currentFocusedEdge = null;
  private HashMap<Face, PVector> faceColors = new HashMap<>();
  private HashMap<Vertex, PVector> perVertexNormals = new HashMap<>();

  void dump() {
    for (Vertex v : vertices) {
      println("v " + v.x + " " + v.y + " " + v.z);
    }
    for (DirectedEdge e : edges) {
      println("e " + e.from + " " + e.to);
    }
    for (Face f : faces) {
      var edges = f.getEdges();
      for (DirectedEdge e : edges) {
        print(e.from + " ");
      }
      println();
    }
  }

  void draw() {
    if (!isSealed) {
      throw new RuntimeException("Mesh is not sealed");
    }
    for (Face f : faces) {
      var edges = f.getEdges();
      if (W_randomlyColored) {
        fill (faceColors.get(f).x, faceColors.get(f).y, faceColors.get(f).z);
      }
      else {
        // fill(255, 255, 255);
      }
      
      beginShape();
      for (DirectedEdge e : edges) {
        Vertex v = vertices.get(e.from);
        if (F_perVetexNormal) {
          var normal = perVertexNormals.get(v);
          normal(normal.x, normal.y, normal.z);
        }
        vertex(v.x, v.y, v.z);
      }
      endShape(CLOSE);

    }
    if (V_visualizeDirectedEdge)
      drawFocusedEdge();
  }

  void drawFocusedEdge() {

      if (currentFocusedEdge != null) {
        DirectedEdge e = currentFocusedEdge;
        Vertex v1 = vertices.get(e.from);
        Vertex v2 = vertices.get(e.to);

        if (v1 == null || v2 == null) {
          return;
        }

        fill(200, 100, 150);
        // noStroke();
        // e.dump();
        sphereDetail(18);

        var cx = (v1.x + v2.x) / 2;
        var cy = (v1.y + v2.y) / 2;
        var cz = (v1.z + v2.z) / 2;

        var dx = v2.x - v1.x;
        var dy = v2.y - v1.y;
        var dz = v2.z - v1.z;

        var norm = sqrt(dx*dx + dy*dy + dz*dz);
        dx /= norm;
        dy /= norm;
        dz /= norm;


        var nextEdge = e.next;
        var v3 = vertices.get(nextEdge.to);
        var dx2 = v3.x - v1.x;
        var dy2 = v3.y - v1.y;
        var dz2 = v3.z - v1.z;
        var norm2 = sqrt(dx2*dx2 + dy2*dy2 + dz2*dz2);
        dx2 /= norm2;
        dy2 /= norm2;
        dz2 /= norm2;

        var cosineVec = dx*dx2 + dy*dy2 + dz*dz2;
        var dx3 = dx2 - cosineVec*dx;
        var dy3 = dy2 - cosineVec*dy;
        var dz3 = dz2 - cosineVec*dz;

        var norm3 = sqrt(dx3*dx3 + dy3*dy3 + dz3*dz3) * 20;
        dx3 /= norm3;
        dy3 /= norm3;
        dz3 /= norm3;

        translate(cx + dx3, cy + dy3, cz + dz3);
        sphere(0.05);
        translate(-0.12*dx, -0.12*dy, -0.12*dz);
        sphere(0.07);
        translate(0.2*dx, 0.2*dy, 0.2*dz);
        sphere(0.03);
        
      }
  }

  PVector getNormalizedNormal(Face f) {
    DirectedEdge e1 = f.edge;
    DirectedEdge e2 = e1.next;

    Vertex v1 = vertices.get(e1.from);
    Vertex v2 = vertices.get(e2.from);
    Vertex v3 = vertices.get(e2.to);

    PVector p1 = new PVector(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z);
    PVector p2 = new PVector(v3.x - v1.x, v3.y - v1.y, v3.z - v1.z);
    PVector normal = p1.cross(p2);
    normal.normalize();

    return normal;
  }

  Vertex getCentroid(Face f) {
    var edges = f.getEdges();
    var x = 0.0;
    var y = 0.0;
    var z = 0.0;

    for (DirectedEdge e : edges) {
      Vertex v = vertices.get(e.from);
      x += v.x;
      y += v.y;
      z += v.z;
    }

    x /= edges.size();
    y /= edges.size();
    z /= edges.size();

    return new Vertex((float)x, (float)y, (float)z);
  }
  
  void focusNextEdge() {
    if (currentFocusedEdge == null) {
      currentFocusedEdge = edges.get(0);
    } else {
      currentFocusedEdge = currentFocusedEdge.next;
    }
  }

  void focusPrevEdge() {
    if (currentFocusedEdge == null) {
      currentFocusedEdge = edges.get(0);
    } else {
      currentFocusedEdge = currentFocusedEdge.prev;
    }
  }

  void focusOppoEdge() {
    if (currentFocusedEdge == null) {
      currentFocusedEdge = edges.get(0);
    } else {
      currentFocusedEdge = currentFocusedEdge.oppo;
    }
  }

  void focusSwingEdge() {
    if (currentFocusedEdge == null) {
      currentFocusedEdge = edges.get(0);
    } else {
      currentFocusedEdge = currentFocusedEdge.oppo.next;
    }
  }

  void initializeRandomColor() {
    for (Face f : faces) {
      faceColors.put(f, new PVector(random(255), random(255), random(255)));
    }
  }

  void initializePerVertexNormals() {
    for (DirectedEdge e : edges) {
      Vertex v = vertices.get(e.from);
      if (!perVertexNormals.containsKey(v)) {
        var currEdge = e;
        var normal = new PVector(0, 0, 0);
        int count = 0;

        do {
          var f = currEdge.face;
          normal.add( getNormalizedNormal(f) );
          count++;
          currEdge = currEdge.oppo.next;

          // print("Edge " + e.from + " " + e.to + " ");
        } while((currEdge != e));


        normal.div(count);
        normal.normalize();

        perVertexNormals.put(v, normal);
      }
    }

    // for (Vertex v : vertices) {
    //   var normal = perVertexNormals.get(v);
    //   println("Vertex " + v.x + " " + v.y + " " + v.z + " normal " + normal.x + " " + normal.y + " " + normal.z);
    // }
  }

  boolean isSealed = false;
  void seal() {
    // if (isSealed) {
    //   return;
    // }
    // var accessFlag = new HashMap<EdgeIndex, Boolean>();
    
    // print edgemap 
    // println("=======");
    // for (EdgeIndex ei: edgeMap.keySet()) {
    //   var edge = edgeMap.get(ei);
    //   print("Edge " + edge.from + " " + edge.to + " ");
    // }
    // print("\n");
    
    // println("==================");

    for (DirectedEdge edge : edges) {
        var key = new EdgeIndex(edge.to, edge.from);
        var oppo = edgeMap.get(key);
        if (oppo != null) {
            edge.oppo = oppo;
            oppo.oppo = edge;
        }
        else {
          println("Orphan edge " + edge.from + " " + edge.to);
          edge.oppo = edge;
        }
    }
    currentFocusedEdge = edges.get(0);
    initializePerVertexNormals();
    initializeRandomColor();

    isSealed = true;
  }

  void addVertex(float x, float y, float z) {
    vertices.add(new Vertex(x, y, z));
    // return vertices.size() - 1;
  }

  void addVertex(Vertex v) {
    vertices.add(v);
  }

  void addFace(int[] indices) {
    DirectedEdge[] _edges = new DirectedEdge[indices.length];
    for (int j = 0; j < indices.length; j++) {
      var _e = new DirectedEdge(indices[j], indices[(j+1)%indices.length]);
      this.edges.add(_e);
      this.edgeMap.put(
        new EdgeIndex(indices[j], indices[(j+1)%indices.length]),
        _e
      );
      _edges[j] = _e;
    }

    for (int j = 0; j < indices.length; j++) {
      _edges[j].next = _edges[(j+1)%indices.length];
      _edges[j].prev = _edges[(j-1+indices.length)%indices.length];
    }

    var f = new Face(_edges[0]);
    for (int j = 0; j < indices.length; j++) {
      _edges[j].face = f;
    }
    this.faces.add(f);
  }


  void addFace(ArrayList<Integer> indices) {
    var sz = indices.size();
    DirectedEdge[] _edges = new DirectedEdge[sz];
    for (int j = 0; j < sz; j++) {
      var _e = new DirectedEdge(indices.get(j), indices.get((j+1)%sz));
      this.edges.add(_e);
      this.edgeMap.put(
        new EdgeIndex(indices.get(j), indices.get((j+1)%sz)),
        _e
      );
      _edges[j] = _e;
    }

    for (int j = 0; j < sz; j++) {
      _edges[j].next = _edges[(j+1)%sz];
      _edges[j].prev = _edges[(j-1+sz)%sz];
    }

    var f = new Face(_edges[0]);
    for (int j = 0; j < sz; j++) {
      _edges[j].face = f;
    }
    this.faces.add(f);
  }


  private Mesh cachedDual = null;




  void addNoiseOnDirectionOfNormal(
    float ratio
  ) {
    for (Vertex v : vertices) {
      float noiseMagnitude = random(-ratio, ratio);
      var normal = perVertexNormals.get(v);
      v.x += normal.x * noiseMagnitude;
      v.y += normal.y * noiseMagnitude;
      v.z += normal.z * noiseMagnitude;
    }

    initializePerVertexNormals();
  }
  
}
