Mesh createLaplacianSmooth(Mesh original, float lambda, int iteration) {
    if (original == null) {
        println("Error: createLaplacianSubdivision called with null mesh");
        return null;
    }
    var m = original;
    for (var i = 0; i < iteration; i++) {
        m = _createLaplacianSmooth(m, lambda);
    }
    m.seal();
    return m;
}


Mesh _createLaplacianSmooth(Mesh original, float lambda) {
    // if (original == null) {
    //     println("Error: createLaplacianSubdivision called with null mesh");
    //     return null;
    // }
    var subdivisionMesh = new Mesh();


    var deltaV = new HashMap<Integer, Vertex>();
    // float lambda = 0.6;


    float count = 0;
    float dx = 0;
    float dy = 0;
    float dz = 0;

    for (DirectedEdge de: original.edges) {
        if (deltaV.containsKey(de.from)) {
            continue;
        }
        // var vOrig = original.vertices.get(de.from);
        dx = dy = dz = 0;
        count = 0;

        var curr = de;
        do {
            var toV = original.vertices.get(curr.to);
            dx += toV.x;
            dy += toV.y;
            dz += toV.z;
            count += 1;
            curr = curr.getSwing();
        } while (curr != de);

        var delta = new Vertex(
            dx / count,
            dy / count,
            dz / count
        );

        deltaV.put(de.from, delta);
    }


    int sz = original.vertices.size();

    for (var i = 0; i < sz; i++) {
        var v = original.vertices.get(i);
        var delta = deltaV.get(i);
        v.x = v.x + lambda * (delta.x - v.x);
        v.y = v.y + lambda * (delta.y - v.y);
        v.z = v.z + lambda * (delta.z - v.z);
    }

    return original;
}