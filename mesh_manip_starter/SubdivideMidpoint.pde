
Mesh createMidpointSubdivision(Mesh original) {
    if (original == null) {
        println("Error: createMidpointSubdivision called with null mesh");
        return null;
    }
    var subdivisionMesh = new Mesh();
    // var strides = new float[steps];

    // for (var i = 1; i < steps+1; i++) {
    //     strides[i] = float(i)/(steps+1);
    // }

    var midpointsMap = new HashMap<EdgeIndex, Integer>();
    var vertexIDs = new HashMap<Vertex, Integer>();
    for (Vertex v: original.vertices) {
        subdivisionMesh.addVertex(v.x, v.y, v.z);
        vertexIDs.put(v, subdivisionMesh.vertices.size()-1);
    }
    for (DirectedEdge de: original.edges) {
        if (midpointsMap.containsKey(
            new EdgeIndex(de.to, de.from)
        )) {
            continue;
        }
        var fromV = original.vertices.get(de.from);
        var toV = original.vertices.get(de.to);

        var midpoint = lerp(fromV, toV, 0.5);
        midpoint.normalize();

        var mID = subdivisionMesh.vertices.size();
        subdivisionMesh.addVertex(midpoint);

        // midpointsMap.put(de, mID);
        vertexIDs.put(midpoint, mID);
        midpointsMap.put(
            de.getEdgeIndex(),
            mID
        );
    }

    for (Face f: original.faces) {
        var curr = f.edge;

        ArrayList<Integer> innerIndices = new ArrayList<Integer>();
        do {
            var currEi = curr.getEdgeIndex();
            var mid1 = midpointsMap.get(currEi);
            if (mid1 == null) {
                mid1 = midpointsMap.get(currEi.getReversed());
            }

            innerIndices.add(mid1);

            var nextEi = curr.next.getEdgeIndex();
            var mid2 = midpointsMap.get(nextEi);
            if (mid2 == null) {
                mid2 = midpointsMap.get(nextEi.getReversed());
            }
            var v2 = curr.to;

            // println("mid1: " + mid1 + " mid2: " + mid2 + " v2: " + v2);
            subdivisionMesh.addFace(new int[] {mid1, v2, mid2});

            curr = curr.next;
        } while (curr != f.edge);

        int[] innerIndicesArray = new int[innerIndices.size()];
        for (int i = 0; i < innerIndices.size(); i++) {
            innerIndicesArray[i] = innerIndices.get(i);
        }
        subdivisionMesh.addFace(innerIndicesArray);
    }

    subdivisionMesh.seal();
    
    return subdivisionMesh;

}