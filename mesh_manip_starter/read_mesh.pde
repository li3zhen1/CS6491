// Read polygon mesh from .ply file
//
// You should modify this routine to store all of the mesh data
// into a mesh data structure instead of printing it to the screen.

Mesh stagedMesh;

void read_mesh(String filename) {
    String[] words;
    String lines[] = loadStrings(filename);
    Mesh mesh = new Mesh();

    words = split (lines[0], " ");
    int num_vertices = int(words[1]);
    println ("number of vertices = " + num_vertices);

    words = split (lines[1], " ");
    int num_faces = int(words[1]);
    println ("number of faces = " + num_faces);

    for (int i = 0; i < num_vertices; i++) {
        words = split (lines[i+2], " ");
        float x = float(words[0]);
        float y = float(words[1]);
        float z = float(words[2]);
        // println ("vertex = " + x + " " + y + " " + z);

        mesh.vertices.add(new Vertex(x, y, z));
    }

    for (int i = 0; i < num_faces; i++) {
        words = split (lines[i+2+num_vertices], " ");
        int num_edges = int(words[0]);
        // println ("face has " + num_edges + " edges");

        int[] edge_indices = new int[num_edges];
        for (int j = 0; j < num_edges; j++) {
            edge_indices[j] = int(words[j+1]);
        }

        mesh.addFace(edge_indices);

        // DirectedEdge[] edges = new DirectedEdge[num_edges];
        // for (int j = 0; j < num_edges; j++) {
        //     var _e = new DirectedEdge(edge_indices[j], edge_indices[(j+1)%num_edges]);

        //     mesh.edges.add(_e);

        //     mesh.edgeMap.put(
        //         new EdgeIndex(_e.from, _e.to),
        //         _e
        //     );
        //     edges[j] = _e;
        // }


        // for (int j = 0; j < num_edges; j++) {
        //     DirectedEdge edge = edges[j];
        //     edges[j].next = edges[(j+1)%num_edges];
        //     edges[j].prev = edges[(j-1+num_edges)%num_edges];
        // }

        // var face = new Face(edges[0]);
        // for (int j = 0; j < num_edges; j++) {
        //     edges[j].face = face;
        // }
        // mesh.faces.add(face);
    }

    // var accessFlag = new HashMap<EdgeIndex, Boolean>();

    mesh.seal();

    stagedMesh = mesh;


    draw();

  }