import java.util.HashSet;

Mesh createDual(Mesh original) {
    if (original == null) {
        println("Error: createDual called with null mesh");
        return null;
    }
    if (original.cachedDual != null) {
      return original.cachedDual;
    }

    var faceCentroids = new HashMap<Face, Vertex>();
    var faceIndices = new HashMap<Face, Integer>();
    var dualMesh = new Mesh();
    for (Face f: original.faces) {
        var c = original.getCentroid(f);
        faceCentroids.put(f, c);
        faceIndices.put(f, faceIndices.size());
        dualMesh.addVertex(c);
    }
    var mappedVertexSet = new HashSet<Integer>();
    DirectedEdge curr = null;
    
    for (DirectedEdge e: original.edges) {
        var v = e.from;
        if (mappedVertexSet.contains(v)) {
            continue;
        }
        mappedVertexSet.add(v);

        curr = e;
        ArrayList<Integer> indices = new ArrayList<Integer>();
        do {
            var _f = curr.face;
            var _vIdx = faceIndices.get(_f);
            indices.add(_vIdx);
            curr = curr.getSwing();
        } while (curr != e);

        dualMesh.addFace(indices);
        
    }

    dualMesh.seal();

    original.cachedDual = dualMesh;
    dualMesh.cachedDual = original;

    return dualMesh;
    
}